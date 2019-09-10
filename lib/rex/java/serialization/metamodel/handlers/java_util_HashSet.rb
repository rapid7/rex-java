# -*- coding: binary -*-
class Java_util_HashSet < Rex::Java::Serialization::Metamodel::ObjectHandlers
  def writeObject(stream, obj, desc)
    elems = obj.fields.fetch('elements', [])

    stream.defaultWriteObject(obj, desc)

    # map.capacility
    stream.writeBytes([0].pack('i>'))
    # map.loadFactor
    stream.writeBytes([0.5].pack('f'))

    # size
    stream.writeBytes([elems.length].pack('i>'))

    elems.each do |elem|
      stream.writeObject(elem)
    end
  end

  def readObject(stream, desc)
    fields = stream.defaultReadObject(desc)
    block = stream.read_blockdata

    nelems = block[8, 4].unpack('i>')[0]
    elems = []
    for i in 0..nelems - 1
      elems.push(stream.read_object)
    end
    fields['elements'] = elems
    fields
  end
end
