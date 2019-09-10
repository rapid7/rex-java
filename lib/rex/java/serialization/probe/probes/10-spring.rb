# -*- coding: binary -*-
P = Rex::Java::Serialization::Probe
P::register [

  P::ExistsProbe.new('org.springframework.core.SerializableTypeWrapper$MethodInvokeTypeProvider',
                                t: ->(ctx) { ctx.gadget('spring-typeprov') }),

  P::ExistsProbe.new('org.springframework.transaction.jta.JtaTransactionManager',
                                t: ->(ctx) { ctx.gadget('spring-jta') })

]
