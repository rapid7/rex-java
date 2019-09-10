# -*- coding: binary -*-
class Org_apache_commons_collections4_map_LazyMap < Rex::Java::Serialization::Metamodel::ObjectHandlers
  def writeObject(stream, obj, desc)
    stream.defaultWriteObject(obj, desc)
    stream.writeObject(obj.fields.fetch('map'))
  end
end
