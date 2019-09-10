# -*- coding: binary -*-
class Java_util_concurrent_ConcurrentHashMap < Rex::Java::Serialization::Metamodel::ObjectHandlers
  def writeObject(stream, obj, desc)
    elems = obj.fields.fetch('elements', [])
    stream.defaultWriteObject(obj, desc)

    elems.each do |key, value|
      stream.writeObject(key)
      stream.writeObject(value)
    end

    stream.writeObject(nil)
    stream.writeObject(nil)
    end
end
