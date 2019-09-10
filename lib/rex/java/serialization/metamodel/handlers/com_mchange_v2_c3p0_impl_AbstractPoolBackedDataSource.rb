# -*- coding: binary -*-
class Com_mchange_v2_c3p0_impl_AbstractPoolBackedDataSource < Rex::Java::Serialization::Metamodel::ObjectHandlers
  def writeObject(stream, _obj, _desc)
    stream.writeBytes([1].pack('s>')) # VERSION
  end
end
