require 'rubygems'
require 'net/http'
require 'JSON'
require 'Time'
require 'Hpricot'


#require 'fluttrly-gem/command'
module Fluttrly
	# Your code goes here...
	class Command
		class << self
			command = ARGV[0]
			list = ARGV[1]
			message ||= ARGV[2]
			puts command
			puts list
			#
			#	@uri = URI.parse("http://fluttrly.com/#{list}")
			#
			#
			#	#possibly do the actions like @holman does .execute for command?
			#	# or case statement for quick hackery
			#	def show(list)
			#		page.each do |task|
			#			puts("#{task["task"]["content"]},
			#					 #{Time.parse(task["task"]["created_at"]).strftime("%m-%d-%Y %H:%M %p")} ") }
			#		end
			#	end
			#
			def post
			end
		end
	end
end
