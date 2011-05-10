
# Command is used to execute the basic commands for interaction with
# fluttrly.com
#
#
module Fluttrly
  class Command
    class << self

      # Takes arguments from command line
      #
      # args - The list of arguments passed in. If they are
      #        in the wrong order, the proper command will not be
      #        executed correctly when passed to parse_arguments()
      #
      def execute(*args)
        command = args.shift
        list = args.shift
        message = args.empty? ? nil : args.join(' ')

        parse_arguments(command, list, message)
      end

      # Receives arguments and delegates them appropriately
      #
      # command - First argument used to decide what additional method 
      #           to call.
      # list    - The list to use execute the command on.
      # message - Used to post to a list.
      #
      # Returns output based on the method called.
      def parse_arguments(command, list, message)
        return list(list) if command == 'list' || command == 'l'
        return post(list, message) if command == 'post' || command == 'p'
        return update(list) if command == 'update' || command == 'c'
        return delete(list) if command == 'delete' || command == 'd'
        return help if command == 'help' || command == '-h'  
      end

      # Command used to delete one or all items in a list
      #
      # list - List to delete items from.
      # 
      # Returns a refreshed list showing the changes
      def delete(list)
        response = form_response(list)[1]
        page = list(list)
        if page
          puts "Which item would you like to delete?"
          num = STDIN.gets.chomp.to_i
          id = page[num-1]["task"]["id"]
          delete_task(id, response)
        list(list)
        end
      end

      # Command used if wanting to mark an item to edit
      #
      # list - List to update
      # 
      # Returns the list with its items to show the change.
      def update(list)
        response = form_response(list)[1]
        page = list(list)
        if page
          puts 'Which item would you like to edit?'
          num = STDIN.gets.chomp.to_i
          id = page[num-1]["task"]["id"]
          update_task(id,response) 
          list(list)
        end
      end

      # Command used to list the items within a list
      #
      # list - List to show contents of.
      #
      # Returns a list of tasks for the given list.
      def list(list)
        response = form_response(list, true)[1]
        if Net::HTTPSuccess === response
          i = 1
          page = JSON.parse(response.body)
          puts ""
          page.each do |task|
            puts("#{i}: Task => \"#{task["task"]["content"]}\" at => #{Time.parse(task["task"]["created_at"]).strftime("%m-%d-%Y %H:%M %p")} (Completed? #{task["task"]["completed"]})") 
            i = i+1
          end
          if page.empty? 
            puts "Oops, that list doesn't have any items yet!"
            puts "Try: fluttrly post #{list} <message> first."
            return false
          end
          page
        else 
          response.error! 
        end
      end

      # Used to post a message to a given list.
      #
      # list    - List to send a message to.
      # message - Message to pass to the list.
      #
      # Returns a newly updated list.
      def post(list, message)
        http, response = form_response(list)
        if Net::HTTPSuccess === response
          response = post_request(list, message, response,http)
        else
          response.error!
        end
        list(list)
      end

      # Command used to print out some helpful hints!
      #
      #
      # Returns nothing.
      def help
        text = %{
          Fluttrly is a nice web app to help you collaborate to-do lists
          with your friends, this is the 'help' for its command line
          interpreter.

          Usage:
            fluttrly -h/help
            fluttrly <command> <list> <message for posting>

          Examples:
            fluttrly list bouverdafs             Output the list "Bouverdafs"
            fluttrly post bouverdafs "winning"   Add to the list bouverdafs the message
                                                 "winning"
            fluttrly update bouverdafs           Presents the user with a prompt to
                                                 allow them to update a specific item
                                                 on that list.
            fluttrly delete bouverdafs           Just like `update`,except allows user
                                                 to delete a specific item from list. 

          For more information please go to:
          http://github.com/brntbeer/fluttrly-gem

        }.gsub(/^ {8}/, '') #to strip 8 lines of whitespace
        puts text
      end

      private

      # Private: Gathers the appropriate response based upon what kind
      #          of argument needs to be done.
      #
      # list - List to gather the response from.
      # get  - Optional flag to pass for if we're simply getting a
      #        refresh view of the list.
      #
      # Returns a Net::HTTP object for the given url, and a response.
      def form_response(list, get=nil)

        #refactors are welcome here =\
        if get.nil?
          uri = URI.parse("http://fluttrly.com/#{list}")
        else
          uri = URI.parse("http://fluttrly.com/#{list}.json")
        end

        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        [http, response]
      end


      # Private: Used to set the actual post message.
      #
      # list     - List to perform the post on.
      # message  - Message to post on the list.
      # response - Response from a previous http request, used to 
      #            get cookie and csrf token.
      # http     - Net::HTTP object used to post the actual data.
      #
      # Returns nothing.
      def post_request(list, message, response, http)
        auth_token = $1 if response.body =~ /"authenticity_token".*value="(.+)"/ or nil
        raise "Not authenticated to perform this action." if auth_token.nil?

        #COOKIE COOKIE COOKIE COOKIE COOKIE COOKIE
        cookie = response['set-cookie'].split('; ')[0]

        uri = URI.parse('http://fluttrly.com/tasks.js')
        request = Net::HTTP::Post.new(uri.request_uri)
        params = {
                  'authenticity_token' => auth_token,
                  'task[name]' => "#{list}",
                  'task[content]' => "#{message}"
        }
        request["Cookie"] = cookie
        request.set_form_data(params)
        response = http.request(request)
      end

      # Private: Performs the PUT method to update a given task.
      #
      # id       - The ID of the task we're updating.
      # response - Response from a previous http request, used to
      #            get cookie and csrf token.
      #
      # Returns nothing.
      def update_task(id, response)
        auth_token = $1 if response.body =~ /"csrf-token".*content="(.+)"/ or nil
        raise "Not authenticated to perform this action." if auth_token.nil?

        #COOKIE COOKIE COOKIE COOKIE COOKIE COOKIE
        cookie = response['set-cookie'].split('; ')[0]

        uri = URI.parse("http://fluttrly.com/tasks/#{id}")
        http = Net::HTTP.new(uri.host, uri.port) 
        request = Net::HTTP::Put.new(uri.request_uri)
        params = {
                  'authenticity_token' => auth_token,
                  'completed' => "true"
        }
        request["Cookie"] = cookie
        request.set_form_data(params)
        response = http.request(request)
      end

      # Private: Performs the DELETE method to delete task(s)
      #
      # id       - The ID or ids of the task(s) we're updating
      # response - The response from a previous http request, used to
      #            get cookie and csrf token.
      #
      # Returns nothing.
      def delete_task(id, response)
        auth_token = $1 if response.body =~ /"csrf-token".*content="(.+)"/ or nil
        raise "Not authenticated to perform this action." if auth_token.nil?

        cookie = response['set-cookie'].split('; ')[0]

        uri = URI.parse("http://fluttrly.com/tasks/#{id}")
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Delete.new(uri.request_uri)
        params = {
                  'authenticity_token' => auth_token,
        }
        request["Cookie"] = cookie
        request.set_form_data(params)
        response = http.request(request)
      end
    end
  end
end
