#!/usr/bin/env ruby
# encoding: utf-8
<<FILES.split(/\n/).each do |name|
finkgo/core
finkgo/formats/ar
finkgo/formats/7zwrapper
FILES
	eval ar["#{name}.rb"], TOPLEVEL_BINDING, name, 1
end
