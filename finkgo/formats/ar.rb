#!/usr/bin/env ruby
# encoding: utf8
require 'zlib'
require 'fileutils'

class AR

	def initialize
		puts "Artoria Package v1.0"
	end

	def pack(archive, files, opts)
		ar = {}
		
		ar[:$opt]={}
		opts["opt"].nil? || opts["opt"].each do |x|
			if x[/([^=]+)=(.+)/]
				ar[:$opt][$1] = $2
				yield "adding option: #{$1} = #{$2.inspect} ..."
			end
		end
		
		yield "adding entry: #{files[0][0]}..."
		ar[:$entry] = open(files.shift[1], "rb"){|f| f.read}
		
		files.each do |k, v|
			yield "adding file: #{v} as #{k}..."
			ar[k] = open(v, "rb"){|f| f.read}
		end
		
		open(archive, "wb") do |f|
			f.write Zlib::Deflate.deflate Marshal.dump ar
		end
	end
	
	def unpack(archive, opts)
		ar = open(archive, "rb") do |f|
			Marshal.load Zlib::Inflate.inflate f.read
		end
		
		ar.keys.each do |k|
			yield "writing #{k}..."
			if k == :$opt
				File.open("$opt", "wb") do |f| f.write Marshal.dump ar[k] end
			elsif k == :$entry
				File.open("$entry", "wb") do |f| f.write ar[k] end
			else
				FileUtils.mkdir_p File.dirname k
				File.open(k, "wb") do |f| f.write ar[k] end
			end
		end
	end
	
	def info(archive, opts)
		ar = open(archive, "rb") do |f|
			Marshal.load Zlib::Inflate.inflate f.read
		end
		
		ar.keys.each do |k|
			yield "#{k}"
		end
	end
end

Finkgo::KNOWN_FORMATS[".ar"] = AR