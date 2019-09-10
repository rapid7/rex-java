# -*- coding: binary -*-
class Org_jboss_weld_interceptor_proxy_InterceptorMethodHandler < Rex::Java::Serialization::Metamodel::ObjectHandlers
  def writeObject(stream, obj, desc)
    stream.defaultWriteObject(obj, desc)
  end
end
