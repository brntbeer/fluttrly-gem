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

			def post(list=nil, message=nil)
				puts "bouverdafs"
			end

		end
	end
end
