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
      end


      def list(list)
        uri = URI.parse("http://fluttrly.com/#{list}.json")
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))

        page = JSON.parse(response.body)
        page.each do |task|
          puts("Task => \"#{task["task"]["content"]}\" at => #{Time.parse(task["task"]["created_at"]).strftime("%m-%d-%Y %H:%M %p")} ") 
        end
      end

      #Posting requires getting COOKIE om nom nom and a csrf token..
      def post(list, message)
        uri = URI.parse("http://fluttrly.com/#{list}")
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request(Net::HTTP::Get.new(uri.request_uri))

        #get the csrf-token, really wanna use hpricot here but...
        auth_token = $1 if response.body =~ /"authenticity_token".*value="(.+)"/ or nil
        raise "No authenticity token found :(" if auth_token.nil?

        #COOKIE COOKIE COOKIE COOKIE COOKIE COOKIE
        cookie = response['set-cookie'].split('; ')[0]

        #ok ok, now send that post data
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

    end
  end
end
