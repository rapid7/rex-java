# -*- coding: binary -*-
class Com_mchange_v2_c3p0_impl_PoolBackedDataSourceBase < Rex::Java::Serialization::Metamodel::ObjectHandlers
  def writeObject(stream, obj, desc)
    stream.writeBytes([1].pack('s>')) # VERSION

    stream.writeObject(obj.fields.fetch('connectionPoolDataSource', nil))
    stream.writeObject(obj.fields.fetch('dataSourceName', nil))

    haveext = false
    desc['fields'].each do |f|
      haveext = true if f['name'] == 'extensions'
    end

    stream.writeObject(obj.fields.fetch('extensions', nil)) if haveext
    stream.writeObject(obj.fields.fetch('factoryClassLocation', nil))
    stream.writeObject(obj.fields.fetch('identityToken', nil))
    stream.writeBytes([obj.fields.fetch('numHelperThreads', 0)].pack('i>'))
  end
end
