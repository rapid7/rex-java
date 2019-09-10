# -*- coding: binary -*-
class Org_mozilla_javascript_IdScriptableObject < Rex::Java::Serialization::Metamodel::ObjectHandlers
  def writeObject(stream, obj, desc)
    stream.defaultWriteObject(obj, desc)

    stream.writeBytes([0].pack('i>')) # maxPrototypeId
    end
end
