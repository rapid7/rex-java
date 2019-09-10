# -*- coding: binary -*-
require 'rex/java/serialization'

###
# This module implements probing strategies for identifying 
# classes/gadgets on a remote classpath
#
# If the remote party reveals exception details, an exception
# type based strategy can be used.
#
# For blind probing, a timing based strategy is provided.
#
# Probe definitions/targets are stored in probe/probes/. 
###
module Rex
  module Java
    module Serialization
      module Probe
          autoload :ProbeContext, 'rex/java/serialization/probe/base'
          autoload :ProbeStrategy, 'rex/java/serialization/probe/base'
          autoload :ExistsProbe, 'rex/java/serialization/probe/base'
          autoload :DeserProbe, 'rex/java/serialization/probe/base'

          autoload :BuiltinProbes,
            'rex/java/serialization/probe/builtin'

          autoload :ExceptionProbeStrategy, 
            'rex/java/serialization/probe/exception'

          autoload :TimingProbeStrategy, 
            'rex/java/serialization/probe/timing'
      end
    end
  end
end

