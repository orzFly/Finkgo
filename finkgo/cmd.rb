#!/usr/bin/env ruby
# encoding: utf8
require 'rubygems' rescue nil
require 'ap'

class Array
	def expand_abbr s
		return nil if s.length == 0
		return s if self.index(s)
		re = self.flatten.sort.find_all do |i| i[0...s.length] == s end
		return re[0] if re.length == 1
		return nil if re.length == 0
		return re
	end
end

class File
	RELATIVE_PARENTDIR = '..'
	RELATIVE_SAMEDIR = '.'

	def self.relative_path(from, to)
		from = expand_path(from).split(SEPARATOR)
		to = expand_path(to).split(SEPARATOR)
		from.length.times do
			break if from[0] != to[0]
			from.shift; to.shift
		end
		fname = from.pop
		join(*(from.map { RELATIVE_PARENTDIR } + to))
	end

	def self.cleanpath(path)
		path = path.split(SEPARATOR)
		path = path.inject([]) do |acc, comp|
			next acc if comp == RELATIVE_SAMEDIR
			if comp == RELATIVE_PARENTDIR && acc.size > 0 && acc.last != RELATIVE_PARENTDIR
				acc.pop
				next acc
			end
			acc << comp
		end
		File.join(*path)
	end
end

module Finkgo
	module CommandLine; end
end

Finkgo::KNOWN_OPTS.push 'nologo'

class << Finkgo::CommandLine
	REAL = Finkgo::CommandLine
	
	COMMAND_HANDLER = {}

	def run
		parse_argv
		logo unless @session[:opts]['nologo']
		if @session[:command].nil? || COMMAND_HANDLER[@session[:command]].nil?
			usage
			exit 1
		else
			COMMAND_HANDLER[@session[:command]].call
		end
	end
	
	def fail msg, exitcode = 1
		STDERR.puts "finkgo(#{exitcode}): #{msg}"
		exit 1
	end
	
	def parse_argv
		@session = {
			:opts => {},
			:command => nil,
			:archive => nil,
			:files => nil
		}
		
		@session[:command] = ARGV.shift
		while arg = ARGV.shift
			if arg[/^(--|-|\/)([^= ]*?)(=(.*))?$/] && @session[:files].nil?
				name = ($1 == "-" || $1 == "/") ? Finkgo::KNOWN_OPTS.expand_abbr($2) : $2
				if name
					if @session[:opts][name].nil?
						@session[:opts][name] = $4 ? $4 : true
					elsif @session[:opts][name].is_a? Array
						@session[:opts][name].push $4 ? $4 : true
					else
						@session[:opts][name] = [@session[:opts][name]]
						@session[:opts][name].push $4 ? $4 : true
					end
				else
					fail "unknown option: #{arg}"
				end
			elsif @session[:archive].nil?
				@session[:archive] = arg
			else
				name, base = arg.split /\t/
				base ||= File.expand_path(File.dirname(name))
				if File.exist?(name)
					if File.directory?(name)
						Dir["#{name}#{!name.end_with?('/') ? '/' : nil}*"].each do |i|
							pushfile File.expand_path(i), base
						end
					else
						rea = File.relative_path(base, File.expand_path(name))
						(@session[:files] ||= []).push [rea, File.expand_path(name)]
					end
				else
					fail "no such file: #{name}"
				end
			end
		end
		@session
	end
	
	def pushfile name, base
		ARGV.insert(0, name + "\t" + base)
	end
	
	def usage
		puts <<EOF
Usage: finkgo <command> [<options>...] <archive_name> [<file_names>...]
              [<@listfiles...>]

<Commands>
	c: Create archive
	x: eXtract files
	l: List contents of archive

<Options>
EOF
	end
	
	def logo
		puts
		puts "#{Finkgo::DESCRIPTION}"
		puts "  running on #{RUBY_DESCRIPTION}"
		puts
	end

	def command_create
		Finkgo.pack(
			@session[:archive],
			@session[:files],
			@session[:opts]
		) do |i| puts i end
	end
	COMMAND_HANDLER["c"] = instance_method(:command_create).bind REAL
	
	def command_extract
		Finkgo.unpack(
			@session[:archive],
			@session[:opts]
		) do |i| puts i end
	end
	COMMAND_HANDLER["x"] = instance_method(:command_extract).bind REAL
	
	def command_info
		Finkgo.info(
			@session[:archive],
			@session[:opts]
		) do |i| puts i end
	end
	COMMAND_HANDLER["l"] = instance_method(:command_info).bind REAL
end