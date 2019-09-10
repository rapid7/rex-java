# -*- coding: binary -*-


module Rex
  module Java
    module Serialization
      module Payloads
        class Probe
          def self.make_probe_test(posProbe)
            posTest = Model::JavaObject.new('Ljavax/swing/event/EventListenerList;', 'listeners' => [
              ['java.awt.LightweightDispatcher',
               Model::JavaObject.new('Ljava/awt/LightweightDispatcher;', {})]
            ])
            Model::JavaObject.new('Ljava/util/ArrayList;', 'elements' => [posTest, posProbe])
          end

          def self.make_eventlistenerlist_probe(classname, posProbe, negProbe)
            posTest = Model::JavaObject.new('Ljavax/swing/event/EventListenerList;', 'listeners' => [
              ['java.awt.LightweightDispatcher',
               Model::JavaObject.new('Ljava/awt/LightweightDispatcher;', {})]
            ])

            negTest = Model::JavaObject.new('Ljavax/swing/event/EventListenerList;', 'listeners' => [
              [classname,
               Model::JavaProxy.new(['java.util.EventListener'],
                                    nil)]
            ])

            Model::JavaObject.new('Ljava/util/ArrayList;', 
                                  'elements' => [posTest, posProbe, negTest, negProbe])
          end
        end
      end
    end
  end
end
