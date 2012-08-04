#!/usr/bin/env ruby
# encoding: utf-8
require 'zlib'
require 'fileutils'

class NekoKunArchive

	def initialize
		puts "NekoKun Archive Package v1.0"
	end

	def pack(archive, files, opts)
		ar = {}
		
		yield "adding manifest: #{files[0][0]}..."
		manifest = open(files.shift[1], "rb"){|f| f.read}
		
		files.each do |k, v|
			yield "adding file: #{v} as #{k}..."
			ar[k] = open(v, "rb"){|f| f.read}
		end
		
		open(archive, "wb") do |f|
			f.write Marshal.dump manifest
			f.write Marshal.dump ar.keys
			f.write Marshal.dump Zlib::Deflate.deflate Marshal.dump ar
		end
	end
	
	def unpack(archive, opts)
		manifest = nil
		ar = nil
		open(archive, "rb") do |f|
			manifest = Marshal.load f
			Marshal.load f
			ar = Marshal.load Zlib::Inflate.inflate Marshal.load f
		end
		
		File.open("manifest", "wb") do |f| f.write manifest end
		
		ar.keys.each do |k|
			yield "writing #{k}..."
			FileUtils.mkdir_p File.dirname k
			File.open(k, "wb") do |f| f.write ar[k] end
		end
	end
	
	def info(archive, opts)
		manifest = nil
		arkeys = nil
		open(archive, "rb") do |f|
			manifest = Marshal.load f
			arkeys = Marshal.load f
		end
		
		yield "manifest: "
		yield manifest
		yield ""
		yield "files:"
		arkeys.each do |k|
			yield "#{k}"
		end
	end
end

Finkgo::KNOWN_FORMATS[".nkar"] = NekoKunArchive
