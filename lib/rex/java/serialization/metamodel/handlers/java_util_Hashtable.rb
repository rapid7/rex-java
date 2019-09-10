# -*- coding: binary -*-
class Java_util_Hashtable < Rex::Java::Serialization::Metamodel::ObjectHandlers
  def writeObject(stream, obj, desc)
    elems = obj.fields.fetch('elements', {})
    size = elems.length

    # ensure loadFactor > 0.0
    obj.fields['loadFactor'] = obj.fields.fetch('loadFactor', 0.5)

    stream.defaultWriteObject(obj, desc)
    stream.writeBytes([size].pack('i>'))
    stream.writeBytes([size].pack('i>'))

    elems.each do |key, val|
      stream.writeObject(key)
      stream.writeObject(val)
    end
  end
end
