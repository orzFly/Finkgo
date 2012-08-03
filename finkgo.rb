#!/usr/bin/env ruby
# encoding: utf8
require "#{File.dirname($0)}/finkgo/core"
require "#{File.dirname($0)}/finkgo/formats/ar"
require "#{File.dirname($0)}/finkgo/formats/nkar"
require "#{File.dirname($0)}/finkgo/formats/7zwrapper"
require "#{File.dirname($0)}/finkgo/cmd"

Finkgo::CommandLine.run