# -*- coding: binary -*-
class Java_net_URL < Rex::Java::Serialization::Metamodel::ObjectHandlers
  def writeObject(stream, obj, desc)
    stream.defaultWriteObject(obj, desc)
  end
end
