# -*- coding: binary -*-
P = Rex::Java::Serialization::Probe
P::register [

  P::ExistsProbe.new('org.hibernate.property.BasicPropertyAccessor$BasicGetter',
                                t: ->(ctx) { ctx.gadget('hibernate') }),

  P::ExistsProbe.new('org.hibernate.property.access.spi.GetterMethodImpl',
                                t: ->(ctx) { ctx.gadget('hibernate') }),

  P::ExistsProbe.new('org.hibernate.validator.internal.util.annotationfactory.AnnotationProxy',
                                t: ->(ctx) { ctx.gadget('hibernate-validator') }),

  P::ExistsProbe.new('org.hibernate.validator.internal.util.annotation.AnnotationProxy',
                                t: ->(ctx) { ctx.gadget('hibernate-validator') })

]
