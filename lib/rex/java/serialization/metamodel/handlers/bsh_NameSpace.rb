# -*- coding: binary -*-
class Bsh_NameSpace < Rex::Java::Serialization::Metamodel::ObjectHandlers
  def writeObject(stream, obj, desc)
    stream.defaultWriteObject(obj, desc)
  end
end
