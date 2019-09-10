# -*- coding: binary -*-
P = Rex::Java::Serialization::Probe
P::register [
  P::ExistsProbe.new('org.apache.commons.beanutils.BeanComparator',
                                t: lambda do |ctx|
                                  ctx.pushf(P::DeserProbe.new('org.apache.commons.beanutils.BeanComparator',
                                                                         suid: -3_490_850_999_041_592_962,
                                                                         t: lambda do |ctx|
                                                                           ctx.flag('beanutils18')
                                                                           ctx.gadget('beanutils')
                                                                         end))

                                  ctx.pushf(P::DeserProbe.new('org.apache.commons.beanutils.BeanComparator',
                                                                         suid: -2_044_202_215_314_119_608,
                                                                         t: lambda do |ctx|
                                                                           ctx.gadget('beanutils')
                                                                           ctx.flag('beanutils19')
                                                                         end))

                                  # TODO: Adobe
                                end)
]
