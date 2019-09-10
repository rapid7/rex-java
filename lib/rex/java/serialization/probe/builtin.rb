# -*- coding: binary -*-

module Rex
  module Java
    module Serialization
      module Probe
        def register(probes)
          probes.each do |probe|
            BuiltinProbes.register(probe)
          end
        end
        module_function :register

        class BuiltinProbes
          @@probes = []

          def initialize
            Dir[File.dirname(__FILE__) + '/probes/*.rb'].sort.each do |file|
              Kernel.load file, wrap: true
            end
          end

          def self.register(probe)
            @@probes.push(probe)
          end

          def create_context(reg, params: {})
            ProbeContext.new(@@probes.map(&:dup), reg, params: params)
          end
        end
      end
    end
  end
end
