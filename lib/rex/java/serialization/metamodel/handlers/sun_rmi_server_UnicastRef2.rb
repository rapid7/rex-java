# -*- coding: binary -*-
class Sun_rmi_server_UnicastRef2 < Rex::Java::Serialization::Metamodel::ObjectHandlers
  def writeExternal(out, obj, _desc)
    isResultStream = false
    useNewFormat = true

    lref = obj.fields['ref']
    ep = lref.fields['ep']
    id = lref.fields['id']
    space = id.fields['space']

    csf = ep.fields['csf']
    host = ep.fields['host']
    port = ep.fields['port']

    if useNewFormat
      if csf.nil?
        out.writeByte(0)
        out.writeUTF(host)
        out.writeBytes([port].pack('i>'))
      else
        out.writeByte(1)
        out.writeUTF(host)
        out.writeBytes([port].pack('i>'))
        out.writeObject(csf)
      end
    else
      raise unless csf.nil?
      out.writeUTF(host)
      out.writeBytes([port].pack('i>'))
    end
    out.writeBytes([id.fields['objNum']].pack('Q>'))

    if !space.nil?
      out.writeBytes([space.fields['unique']].pack('I>'))
      out.writeBytes([space.fields['time']].pack('Q>'))
      out.writeBytes([space.fields['count']].pack('S>'))
    else
      otu.writeBytes([0] * 14)
    end
    out.writeByte(isResultStream ? 0 : 1)
  end
end
