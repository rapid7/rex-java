# -*- coding: binary -*-
class Org_mozilla_javascript_NativeJavaObject < Rex::Java::Serialization::Metamodel::ObjectHandlers
  def writeObject(stream, obj, desc)
    stream.defaultWriteObject(obj, desc)

    if obj.fields.fetch('isAdapter', false)
      stream.writeByte(1) # isAdapter

      stream.writeObject('java.lang.Object')
      stream.writeObject(Java::Serialize::JavaArray.new('Ljava/lang/String;', []))
      stream.writeObject(obj.fields.fetch('scriptable', nil))
    else
      stream.writeByte(0) # isAdapter
      stream.writeObject(obj.fields.fetch('javaObject', nil))
    end
    stream.writeObject(nil) # staticType
    end
end
