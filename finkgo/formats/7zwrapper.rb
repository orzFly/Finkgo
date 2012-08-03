#!/usr/bin/env ruby
# encoding: utf8

class SevenZWrapper
	def initialize
		@bin = File.expand_path(__FILE__).gsub(/\.rb$/){} + "/7za.exe"
	end

	def pack(archive, files, opts)
		files.each do |file|
			`#{@bin} a #{archive} -si#{file[0]} < #{file[1]}`
			yield "adding file: #{file[1]} as #{file[0]}..."
		end
	end
	
	def unpack(archive, opts)
		puts `#{@bin} x #{archive}`
	end
	
	def info(archive, opts)
		puts `#{@bin} l #{archive}`
	end
end

Finkgo::KNOWN_FORMATS[".7z"] = SevenZWrapper
Finkgo::KNOWN_FORMATS[".zip"] = SevenZWrapper