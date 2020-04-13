# This file is used by Rack-based servers to start the application.
#$:.unshift(File.expand_path("../jets/lib", __FILE__))

require "jets"
Jets.boot
run Jets.application
