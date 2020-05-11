# -*- coding: binary -*-
class Java_util_Vector < Rex::Java::Serialization::Metamodel::ObjectHandlers
  def writeObject(stream, obj, desc)
    elems = obj.fields.fetch('elements', [])
    stream.defaultWriteObject(obj, desc)
  end

  def readObject(stream, desc)
    fields = stream.defaultReadObject(desc)
    fields
  end
end
