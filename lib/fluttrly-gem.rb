require 'rubygems'
require 'net/http'
require 'JSON'
require 'Time'


#require 'fluttrly-gem/command'
module Fluttrly
  # Your code goes here...
  class Command
    class << self
      def execute(*args)
        command = args.shift
        list = args.shift
        message = args.empty? ? nil : args.join(' ')

        parse_arguments(command, list, message)

      end

      def parse_arguments(command, list, message)
        return list(list) if command == 'list'
        return post(list, message) if command == 'post'
        return update(list) if command == 'update'
      end

      def update(list)
        response = form_response(list)[1]
        page = list(list)
        if page
          puts 'Which item would you like to edit?'
          num = STDIN.gets.chomp.to_i
          id = page[num-1]["task"]["id"]
          update_task(id,response) 
        end
      end

      def list(list)
        response = form_response(list, true)[1]
        if Net::HTTPSuccess === response
          i = 1
          page = JSON.parse(response.body)
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

      #Posting requires getting COOKIE om nom nom and a csrf token..
      def post(list, message)
        http, response = form_response(list)
        if Net::HTTPSuccess === response
          response = post_request(list, message, response,http)
        else
          response.error!
        end
      end

      private

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

      def post_request(list, message, response, http)
        #get the csrf-token, really wanna use hpricot here but...
        auth_token = $1 if response.body =~ /"authenticity_token".*value="(.+)"/ or nil
        raise "No authenticity token found :(" if auth_token.nil?

        #COOKIE COOKIE COOKIE COOKIE COOKIE COOKIE
        cookie = response['set-cookie'].split('; ')[0]

        #ok ok, NOW send that post data
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

      def update_task(id, response)
        auth_token = $1 if response.body =~ /"csrf-token".*content="(.+)"/ or nil
        raise "No authenticity token found :(" if auth_token.nil?

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

    end
  end
end
