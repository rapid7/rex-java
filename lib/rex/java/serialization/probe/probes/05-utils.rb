# -*- coding: binary -*-
P = Rex::Java::Serialization::Probe
Model = Rex::Java::Serialization::Metamodel
P::register [
  P::ExistsProbe.new('com.sun.org.apache.xalan.internal.xsltc.trax.TemplatesImpl',
                     t: lambda do |ctx|
    ctx.reg.load('model/jdk-templates.json')
    ctx.pushf(P::DeserProbe.new(
      'com.sun.org.apache.xalan.internal.xsltc.trax.TemplatesImpl',
      reg: ctx.reg,
      f: lambda do |ctx|
        ctx.flag('secmgr')
        ctx.flag('nojdktemplates')
      end
    ))
  end),

  P::ExistsProbe.new('org.apache.xalan.xsltc.trax.TemplatesImpl'),

  P::ExistsProbe.new('com.sun.rowset.JdbcRowSetImpl'),

  P::ExistsProbe.new('sun.reflect.annotation.AnnotationInvocationHandler',
                     t: lambda do |ctx|
    ctx.pushf(P::DeserProbe.new(
      'sun.reflect.annotation.AnnotationInvocationHandler',
      reg: ctx.reg,
      fields: {
        'type' => Model::JavaClass.new('java.lang.annotation.Retention'),
        'memberValues' => Model::JavaObject.new('Ljava/util/HashMap;', {})
      },
      t: lambda do |ctx|
        ctx.pushf(P::DeserProbe.new(
          'sun.reflect.annotation.AnnotationInvocationHandler',
          reg: ctx.reg,
          fields: {
            'type' => Model::JavaClass.new('java.lang.Object'),
            'memberValues' => Model::JavaObject.new('Ljava/util/HashMap;', {})
          },
          t: ->(ctx) { ctx.flag('anninvh-universal') }
        ))
      end
    ))
  end),

  P::ExistsProbe.new('org.springframework.aop.framework.JdkDynamicAopProxy')
]
