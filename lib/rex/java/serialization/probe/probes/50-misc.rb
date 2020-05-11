# -*- coding: binary -*-
P = Rex::Java::Serialization::Probe
P::register [

  P::ExistsProbe.new('bsh.XThis',
                                t: ->(ctx) { ctx.gadget('beanshell') }),

  P::ExistsProbe.new('com.mchange.v2.c3p0.PoolBackedDataSource',
                                t: lambda do |ctx|
                                  areg = ctx.reg.dup
                                  areg.load('model/c3p0.json')

                                  ctx.pushf(P::DeserProbe.new(
                                              'com.mchange.v2.c3p0.PoolBackedDataSource',
                                              reg: areg,
                                              fields: { 'identityToken' => 'foobar' },
                                              t: ->(ctx) { ctx.gadget('c3p0') },
                                              f: lambda do |ctx|
                                                # check legacy
                                                breg = ctx.reg.dup
                                                breg.load('model/c3p0-legacy.json')
                                                ctx.pushf(P::DeserProbe.new(
                                                            'com.mchange.v2.c3p0.PoolBackedDataSource',
                                                            reg: breg,
                                                            fields: { 'identityToken' => 'foobar' },
                                                            t: lambda do |ctx|
                                                              ctx.gadget('c3p0')
                                                              ctx.flag('c3p0-legacy')
                                                            end,
                                                            f: ->(_ctx) { _ctx.error('Incompatible C3P0') }
                                                ))
                                              end
                                  ))
                                end),

  P::ExistsProbe.new('org.apache.commons.fileupload.disk.DiskFileItem',
                                t: lambda { |ctx|
                                     ctx.pushf(P::DeserProbe.new(
                                                 'org.apache.commons.fileupload.disk.DiskFileItem',
                                                 desc: { 'serialVersion' => -8_653_385_846_894_047_688 },
                                                 t: ->(ctx) { ctx.gadget('fileupload') },
                                                 f: ->(_ctx) { _ctx.error('Incompatible commons-fileupload') }
                                     ))
                                   }),

  P::ExistsProbe.new('org.apache.wicket.util.upload.DiskFileItem',
                                t: ->(ctx) { ctx.gadget('wicket-fileupload') }),

  P::ExistsProbe.new('org.codehaus.groovy.runtime.MethodClosure',
                                t: lambda do |ctx|
                                  ctx.pushf(P::DeserProbe.new(
                                              'org.codehaus.groovy.runtime.MethodClosure',
                                              desc: { 'serialVersion' => 1_228_988_487_386_910_280 },
                                              t: ->(ctx) { ctx.gadget('groovy') }
                                  ))
                                end),

  P::ExistsProbe.new('net.sf.json.JSONObject',
                                t: ->(ctx) { ctx.gadget('json') }),

  P::ExistsProbe.new('org.python.core.PyFunction',
                                t: ->(ctx) { ctx.gadget('jython') }),

  P::ExistsProbe.new('org.apache.myfaces.view.facelets.el.ValueExpressionMethodExpression',
                                t: lambda { |ctx|
                                  ctx.push(P::ExistsProbe.new('org.apache.el.ExpressionFactoryImpl'))
                                  ctx.push(P::ExistsProbe.new('de.odysseus.el.ExpressionFactoryImpl'))
                                  ctx.push(P::ExistsProbe.new('com.sun.el.ExpressionFactoryImpl'))
                                  ctx.gadget('myfaces')
                                }),

  P::ExistsProbe.new('com.sun.syndication.feed.impl.ObjectBean',
                                t: ->(ctx) { ctx.gadget('rome') }),
  P::ExistsProbe.new('com.rometools.rome.feed.impl.ObjectBean',
                                t: ->(ctx) { ctx.gadget('rome') }),

  P::ExistsProbe.new('org.jboss.interceptor.proxy.InterceptorMethodHandler',
                                t: ->(ctx) { ctx.gadget('jboss') }),
  P::ExistsProbe.new('org.jboss.weld.interceptor.proxy.InterceptorMethodHandler',
                                t: ->(ctx) { ctx.gadget('jboss') }),

  P::ExistsProbe.new('org.mozilla.javascript.NativeJavaObject',
                                t: ->(ctx) { ctx.gadget('rhino') }),

  P::ExistsProbe.new('clojure.main$eval_opt',
                                t: ->(ctx) { ctx.gadget('clojure') }),

  P::ExistsProbe.new('com.vaadin.data.util.NestedMethodProperty',
                                t: ->(ctx) { ctx.gadget('vaadin') })

]
