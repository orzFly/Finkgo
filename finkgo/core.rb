#!/usr/bin/env ruby
# encoding: utf8

module Finkgo
	VERSION = "0.1.0.0"
	RELEASE_DATE = "2012-08-01"
	COPYRIGHT = "finkgo - Copyright (C) 2012 Yeechan Lu"
	DESCRIPTION = "finkgo #{VERSION} (#{RELEASE_DATE})"
	KNOWN_OPTS = ["format"]
	KNOWN_FORMATS = {}
end

class << Finkgo
	def decide_format(archive, opts)
		Finkgo::KNOWN_FORMATS[File.extname(archive).downcase] ||
		(
			!opts["format"].nil? &&
			Finkgo::KNOWN_FORMATS[".#{opts["format"].downcase}"]
		) ||
		raise("cannot decide format: #{File.extname(archive).downcase}, .#{opts["format"]}")
	end

	def pack(archive, files, opts, &callback)
		yield "creating package: #{archive}..."
		format = decide_format(archive, opts).new
		format.pack archive, files, opts, &callback
	end
	
	def unpack(archive, opts, &callback)
		yield "extracting package: #{archive}..."
		format = decide_format(archive, opts).new
		format.unpack archive, opts, &callback
	end
	
	def info(archive, opts, &callback)
		yield "reading package: #{archive}..."
		format = decide_format(archive, opts).new
		format.info archive, opts, &callback
	end
end