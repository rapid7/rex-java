# -*- coding: binary -*-

require "rex/java/version"
require 'rex/java/serialization'

module Rex
  module Java
    def datadir
      File.expand_path '../..', File.dirname(__FILE__)
    end

    module_function :datadir
  end
end


