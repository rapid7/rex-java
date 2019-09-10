# -*- coding: binary -*-
class Com_sun_org_apache_xalan_internal_xsltc_trax_TemplatesImpl < Rex::Java::Serialization::Metamodel::ObjectHandlers
  def writeObject(stream, obj, desc)
    stream.defaultWriteObject(obj, desc)
    stream.writeByte(0)
  end
end
