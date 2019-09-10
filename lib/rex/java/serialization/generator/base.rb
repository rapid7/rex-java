# -*- coding: binary -*-
module Rex
  module Java
    module Serialization
      module Generator

        def register(gadget)
          BuiltinGadgets.register(gadget)
        end
        module_function :register

        class GeneratorConfig

          def gadgets
            nil
          end

          def useGadget?(g)
            gs = gadgets
            return g.auto? if gs.nil? || gs.empty?
            gs.include?(g.id)
          end
        end

        class BuiltinGadgets
          @@gadgets = []

          def initialize
            Dir[File.dirname(__FILE__) + '/gadgets/*.rb'].sort.each do |file|
              Kernel.load file, wrap: true
            end
          end

          def self.register(g)
            @@gadgets.push(g) unless @@gadgets.include?(g)
          end

          def get(id)
            @@gadgets.each do |gadget|
              return gadget if gadget.id == id
            end
            nil
          end

          def find(ctx, params: {}, rc: GeneratorConfig.new)
            matches = []

            @@gadgets.each do |gadget|
              unless rc.useGadget?(gadget)
                next
              end
              if gadget.usable(ctx, params: params)
                matches.push(gadget)
              end
            end

            matches
          end
        end

        class Gadget
          def id
            raise
          end

          def usable(_ctx, params: {})
            false
          end

          def priority
            0
          end

          def auto?
            true
          end

          def create; end
        end
      end
    end
  end
end
