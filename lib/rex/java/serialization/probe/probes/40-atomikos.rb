# -*- coding: binary -*-
P = Rex::Java::Serialization::Probe
P::register [
  P::ExistsProbe.new('com.atomikos.icatch.jta.RemoteClientUserTransaction',
                     t: lambda do |ctx|
    ctx.pushf(P::DeserProbe.new('com.atomikos.icatch.jta.RemoteClientUserTransaction',
                                desc: {
      'typeString' => 'Lcom/atomikos/icatch/jta/RemoteClientUserTransaction;',
      'serialVersion' => -2_275_872_570_956_387_075,
      'externalizable' => true,
      'fields' => []
    },
    t: lambda do |ctx|
      ctx.flag('atomikos3')
      ctx.gadget('atomikos')
    end))

    ctx.pushf(P::DeserProbe.new('com.atomikos.icatch.jta.RemoteClientUserTransaction',
                                desc: {
      'typeString' => 'Lcom/atomikos/icatch/jta/RemoteClientUserTransaction;',
      'serialVersion' => -5_852_363_838_666_148_201,
      'externalizable' => true,
      'fields' => []
    },
    t: lambda do |ctx|
      ctx.gadget('atomikos')
      ctx.flag('atomikos4')
    end))
  end)
]
