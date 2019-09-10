# -*- coding: binary -*-
class Java_lang_Throwable < Rex::Java::Serialization::Metamodel::ObjectHandlers
  def writeObject(stream, obj, desc)
    stream.defaultWriteObject(obj, desc)
  end
end
