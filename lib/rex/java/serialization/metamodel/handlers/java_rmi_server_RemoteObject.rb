# -*- coding: binary -*-
class Java_rmi_server_RemoteObject < Rex::Java::Serialization::Metamodel::ObjectHandlers
  def writeObject(stream, obj, _desc)
    stream.writeBytes([0].pack('S>'))
    stream.writeObject(obj.fields.fetch('ref'))
  end

  def readObject(stream, _desc)
    block = stream.read_blockdata
    factory = false
    factoryobj = nil

    pos = 0
    refn = read_string(block, pos)
    pos += 2 + refn.length

    if refn == 'UnicastRef'
    elsif refn == 'UnicastRef2'
      t = block[pos, 1]
      pos += 1
      if t == "\1"
        factory = true
      elsif t == "\0"
      else
          raise 'Unsupported reference'
      end
    else
      raise 'Unsupported reference type ' + refn
    end

    host = read_string(block, pos)
    pos += 2 + host.length
    port = block[pos, 4].unpack('L>')[0]
    pos += 4

    if factory
      factoryobj = stream.read_object
      block = stream.read_blockdata
      pos = 0
    end

    objid = block[pos, 8].unpack('q>')[0]
    pos += 8

    uidu, uidt, uidc = block[pos, 14].unpack('l>q>s>')
    pos += 14

    { 'host' => host, 'port' => port, 'objid' => objid, 'uid' => [uidu, uidt, uidc], 'factory' => factoryobj }
  end

  def read_string(block, pos)
    refnlen = block[pos, 2].unpack('S>')[0]
    block[pos + 2, refnlen]
  end
end
