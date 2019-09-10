# -*- coding: binary -*-
class Org_apache_xalan_xsltc_trax_TemplatesImpl < Rex::Java::Serialization::Metamodel::ObjectHandlers
  def writeObject(stream, obj, desc)
    stream.defaultWriteObject(obj, desc)
    stream.writeByte(0)
  end
end
