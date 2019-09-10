# -*- coding: binary -*-
P = Rex::Java::Serialization::Probe
P::register [
  P::ExistsProbe.new('java.util.HashSet', f: ->(_ctx) { raise 'Failed to find HashSet' },
                                                     t: lambda { |ctx|
      ctx.pushf(P::DeserProbe.new('java.util.HashSet', desc: {
                                               'serialVersion' => -5_024_744_406_713_321_676,
                                               'hasWriteObject' => true,
                                               'fields' => [],
                                               'superType' => 'Ljava/util/AbstractSet;'
                                             }, t: ->(ctx) { ctx.gadget('hashdos') }))}),

  P::ExistsProbe.new('doesnotexist', t: ->(_ctx) { raise 'Should not exist' }),

  P::ExistsProbe.new('java.lang.String', f: ->(_ctx) { raise 'Failed to find String' })

]
