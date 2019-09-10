# -*- coding: binary -*-
#

require 'rex/java/serialization/payloads'

module Rex
  module Java
    module Serialization
      module Probe
        class ExceptionProbeStrategy < ProbeStrategy
          def initialize(t)
            super(t)
          end

          def init(ctx)
            pmodel = nil
            @@probeModels.each do |model|
              reg = Rex::Java::Serialization::Metamodel::Registry.new()
              reg.load('model/base-java9.json')
              reg.load(model)

              p = Rex::Java::Serialization::Payloads::Probe.make_probe_test(nil)

              r = @test.call(p, reg, ctx.params)
              next if r == 'java.io.InvalidClassException'

              pmodel = model
              break
            end

            raise 'No support for remote java version' if pmodel.nil?

            ctx.reg.load(pmodel)
          end

          def run(probe, ctx)
            obj, handler = probe.make(self)
            reg = ctx.reg
            reg = probe.reg unless probe.reg.nil?
            if !handler.nil?
              r = @test.call(obj, reg, ctx.params)
              r = handler.call(r)
            else
              r = !@test.call(obj, reg, ctx.params).nil?
            end

            if r
              probe.true(ctx)
            else
              probe.false(ctx)
            end
            r
          end

          def make_exists(cname)
            [
              Rex::Java::Serialization::Payloads::Probe.make_eventlistenerlist_probe(cname, nil, nil),
              ->(r) { r == 'java.lang.NullPointerException' }
            ]
          end

          def make_deser(obj)
            [
              Rex::Java::Serialization::Metamodel::JavaArray.new('Ljava/lang/Object;', [obj, Rex::Java::Serialization::Metamodel::JavaCustomObject.new('LDoesnotexist;', {}, 'typeString' => 'LDoesnotexist;')]),
              lambda do |r|
                return true if r == 'java.lang.ClassNotFoundException'
              end
            ]
          end
        end
      end
    end
  end
end
