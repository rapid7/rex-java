# -*- coding: binary -*-
class Org_mozilla_javascript_ScriptableObject < Rex::Java::Serialization::Metamodel::ObjectHandlers
  def writeObject(stream, obj, desc)
    proto = obj.fields.fetch('thePrototypeInstance', nil)

    obj.fields['thePrototypeInstance'] = obj if proto.nil?
    slots = obj.fields.fetch('slots', [])
    obj.fields['count'] = slots.length

    stream.defaultWriteObject(obj, desc)
    stream.writeBytes([slots.length].pack('i>'))

    slots.each do |slot|
      stream.writeObject(slot)
    end
    end
end
