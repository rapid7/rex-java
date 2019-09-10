# -*- coding: binary -*-
class Com_vaadin_data_util_NestedMethodProperty < Rex::Java::Serialization::Metamodel::ObjectHandlers
  def writeObject(stream, obj, desc)
    stream.defaultWriteObject(obj, desc)
  end
end
