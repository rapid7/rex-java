# -*- coding: binary -*-
P = Rex::Java::Serialization::Probe
P::register [

  P::ExistsProbe.new('org.apache.commons.collections.functors.InvokerTransformer',
                                t: lambda { |ctx|
                                     ctx.pushf(P::DeserProbe.new(
                                                 'org.apache.commons.collections.functors.InvokerTransformer',
                                                 desc: { 'serialVersion' => -8_653_385_846_894_047_688 },
                                                 t: ->(ctx) { ctx.gadget('collections') }
                                     ))
                                   }),

  P::ExistsProbe.new('org.apache.commons.collections4.functors.InvokerTransformer',
                                t: lambda { |ctx|
                                     ctx.pushf(P::DeserProbe.new(
                                                 'org.apache.commons.collections4.functors.InvokerTransformer',
                                                 desc: { 'serialVersion' => -8_653_385_846_894_047_688 },
                                                 t: ->(ctx) { ctx.gadget('collections') }
                                     ))
                                   })

]
