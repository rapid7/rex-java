# -*- coding: binary -*-

require 'rex/java/serialization/metamodel'

module Rex
  module Java
    module Serialization
      module Probe
        Model = Rex::Java::Serialization::Metamodel

        class ProbeContext
          attr_accessor :probes, :reg, :models, :params, :gadgets, :classes, :flags

          def initialize(probes, reg, params: [])
            @probes = probes
            @reg = reg
            @models = Set[]
            @classes = Set[]
            @gadgets = Set[]
            @flags = Set[]
            @params = params
          end

          def push(probe)
            @probes.push(probe)
          end

          def pushf(probe)
            @probes.unshift(probe)
          end

          def flag(f)
#            debug 'Setting flags ' + f
            @flags.add(f)
          end

          def flag?(f)
            @flags.include?(f)
          end

          def model(model)
            @models.add(model)
          end

          def class(cls)
            @classes.add(cls)
          end

          def class?(cls)
            @classes.include?(cls)
          end

          def gadget(g)
            @gadgets.add(g)
          end

          def gadget?(g)
            @gadgets.include?(g)
          end

          def report
            @gadgets.each do |gadget|
#              vuln 'Found gadget: ' + gadget
            end
          end

          def run(strategy)
            until @probes.empty?
              probe = @probes.shift
              begin
                if strategy.run(probe, self)
#                  debug '[+] ' + probe.to_s
                else
#                  debug '[-] ' + probe.to_s
                end
              rescue Exception => e
                raise
              end
            end
            !@gadgets.empty?
          end
        end

        class Probe
          attr_accessor :true, :false, :reg

          def initialize(t: nil, f: nil)
            @true = t
            @false = f
          end

          def invert
            false
          end

          def make(_strategy)
            raise
          end

          def false(ctx)
            @false.call(ctx) unless @false.nil?
          end

          def true(ctx)
            @true.call(ctx) unless @true.nil?
          end
        end

        class ExistsProbe < Probe
          def initialize(cname, t: nil, f: nil)
            super(t: t, f: f)
            @cname = cname
          end

          def make(strategy)
            strategy.make_exists(@cname)
          end

          def true(ctx)
            ctx.class(@cname)
            super
          end

          def to_s
            'Exists? ' + @cname
          end
        end

        class DeserProbe < Probe
          def initialize(cname, desc: nil, suid: 0, t: nil, f: nil, reg: nil, fields: {})
            super(t: t, f: f)

            @regular = false
            @fields = fields
            @cname = cname.tr('.', '/')

            ts = 'L' + cname.tr('.', '/') + ';'

            @reg = reg
            unless reg.nil?
              @regular = true
              return
            end

            desc = { 'hasWriteObject' => false, 'serialVersion' => suid } if desc.nil?
            desc['typeString'] = ts
            @desc = desc
          end

          def invert
            true
          end

          def make(strategy)
            if @regular
              strategy.make_deser(Model::JavaObject.new('L' + @cname + ';', @fields))
            else
              strategy.make_deser(Model::JavaCustomObject.new(@cname, @fields, @desc))
            end
          end

          def to_s
            'Deser? ' + @cname.tr('/', '.')
          end
        end

        class ProbeStrategy
          @@probeModels = ['model/probe-java9.json', 'model/probe-java10.json']

          def initialize(t)
            @test = t
          end

          def init(ctx); end

          def run(_probe, _ctx)
            raise
          end
        end
      end
    end
  end
end
