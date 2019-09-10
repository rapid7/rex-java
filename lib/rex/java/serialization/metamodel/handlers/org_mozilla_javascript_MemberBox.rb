# -*- coding: binary -*-
class Org_mozilla_javascript_MemberBox < Rex::Java::Serialization::Metamodel::ObjectHandlers
  def writeObject(stream, obj, desc)
    stream.defaultWriteObject(obj, desc)

    stream.writeByte(1)
    stream.writeByte(1) # method
    stream.writeObject(obj.fields.fetch('name', nil))
    stream.writeObject(obj.fields.fetch('class', nil))

    params = obj.fields.fetch('params', [])

    stream.writeBytes([params.length].pack('s>'))
    end
end
