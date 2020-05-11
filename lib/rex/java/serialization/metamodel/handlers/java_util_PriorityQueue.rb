# -*- coding: binary -*-
class Java_util_PriorityQueue < Rex::Java::Serialization::Metamodel::ObjectHandlers
  def writeObject(stream, obj, desc)
    elems = obj.fields.fetch('elements', [])
    # update size from elements
    size = elems.length
    obj.fields['size'] = size

    stream.defaultWriteObject(obj, desc)
    stream.writeBytes([[2, size + 1].max].pack('i>'))
    elems.each do |elem|
      stream.writeObject(elem)
    end
  end

  def readObject(stream, desc)
    fields = stream.defaultReadObject(desc)

    nelems = fields['size'].unpack('i>')[0]
    elems = []
    stream.read_blockdata()
    for i in 0..nelems-1
      elems.push(stream.read_object)
    end
    fields['elements'] = elems
    fields
  end
end
