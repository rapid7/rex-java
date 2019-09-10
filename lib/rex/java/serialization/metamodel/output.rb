# -*- coding: binary -*-



module Rex
  module Java
    module Serialization
      module Metamodel

        class ObjectOutputStream
          def initialize(out, registry)
            @out = out
            @registry = registry
            @enableOverride = false
            @enableAnnotateClass = false
            @enableAnnotateProxyClass = false
            @blockMode = false
            @blockBuf = StringIO.new('', 'wb+')
            @blockPos = 0
            @protocol = 2
            @depth = 0
            @handles = {}.compare_by_identity
            writeStreamHeader
          end

          def writeStreamHeader
            enc = [Rex::Java::Serialization::STREAM_MAGIC, 
                   Rex::Java::Serialization::STREAM_VERSION].pack('S>S>')
            @out.write(enc)
          end

          def setBlockMode(mode)
            obm = @blockMode
            return obm if mode == obm
            flush
            @blockMode = mode
            obm
          end

          def flush
            return if @blockPos == 0

            writeBlockHeader(@blockPos) if @blockMode

            @out.write(@blockBuf.string)
            @blockBuf = StringIO.new('', 'wb+')
            @blockPos = 0
          end

          def writeBlockHeader(len)
            if len <= 0xFF
              @out.write([Rex::Java::Serialization::TC_BLOCKDATA, len].pack('CC'))
            else
              @out.write([Rex::Java::Serialization::TC_BLOCKDATALONG, len].pack('Ci>'))
            end
          end

          def endBlockMode
            setBlockMode(false)
            @out.write([Rex::Java::Serialization::TC_ENDBLOCKDATA].pack('C'))
          end

          def writeByte(b)
            enc = [b].pack('C')
            if @blockMode
              @blockBuf.write(enc)
              @blockPos += 1
            else
              @out.write(enc)
            end
          end

          def writeBytes(data)
            if @blockMode
              @blockBuf.write(data)
              @blockPos += data.length
            else
              @out.write(data)
            end
          end

          def assign(obj)
            return if obj.nil?

            i = @handles.length
            @handles[obj] = i
            raise 'Missed' if i == @handles.length
          end

          def lookup(obj)
            r = @handles[obj]
            r.nil? ? -1 : r
          end

          def writeNull
            writeByte(Rex::Java::Serialization::TC_NULL)
          end

          def writeHandle(hdl)
            writeByte(Rex::Java::Serialization::TC_REFERENCE)
            writeBytes([hdl + Rex::Java::Serialization::BASE_WIRE_HANDLE].pack('l>'))
          end

          def writeString(s, unshared)
            assign(unshared ? nil : s)
            enc = s.encode('utf-8')
            if enc.length < 0xFFFF
              writeByte(Rex::Java::Serialization::TC_STRING)
              writeBytes([s.length].pack('s>'))
              writeBytes(enc)
            else
              raise NotImplementedError, "Long strings not implemented"
            end
          end

          def writeUTF(s)
            writeBytes([s.length].pack('s>'))
            writeBytes(s.encode(::Encoding::UTF_8))
          end

          def writeTypeString(type)
            handle = -1
            if type.nil?
              writeNull
            elsif (handle = lookup(type)) != -1
              writeHandle(handle)
            else
              writeString(type, false)
            end
          end

          def writeEnum(en, desc, unshared)
            writeByte(Rex::Java::Serialization::TC_ENUM)

            stype = desc.fetch('superType', 'Ljava/lang/Object;')
            sdesc = @registry.getDescriptor(stype)

            raise ClassNotFoundError, stype if sdesc.nil?

            writeClassDesc(stype == 'Ljava/lang/Enum;' ? desc : sdesc, false)

            assign(unshared ? null : en)
            writeString(en.name, false)
          end

          def writeClassDesc(desc, unshared)
            handle = -1
            if desc.nil?
              writeNull
            elsif !unshared && (handle = lookup(desc)) != -1
              writeHandle(handle)
            elsif desc.fetch('proxy', false)
              writeProxyDesc(desc, unshared)
            else
              writeNonProxyDesc(desc, unshared)
            end
          end

          def writeClass(clazz, unshared)
            writeByte(Rex::Java::Serialization::TC_CLASS)
            desc = @registry.getDescriptor(clazz)
            if desc.nil?
              # dummy
              desc = { 'typeString' => clazz }
            end
            writeClassDesc(desc, false)
            assign(unshared ? null : clazz)
          end

          def writeProxyDesc(desc, unshared)
            writeByte(Rex::Java::Serialization::TC_PROXYCLASSDESC)
            assign(unshared ? null : desc)

            interfaces = desc.fetch('interfaces', [])
            # 0 interfaces
            writeBytes([interfaces.length].pack('i>'))

            for interface in interfaces
              writeUTF(interface)
            end

            setBlockMode(true)
            annotateProxyClass(desc.class) if @annotateProxyClass
            endBlockMode
            sdesc = @registry.getDescriptor(desc.fetch('superType', 'Ljava/lang/Object;'))

            raise ClassNotFoundError, sdesc if sdesc.nil?
            writeClassDesc(sdesc, false)
          end

          def writeNonProxyDesc(desc, unshared)
            writeByte(Rex::Java::Serialization::TC_CLASSDESC)
            assign(unshared ? null : desc)

            ts = desc.fetch('typeString')
            arrsep = ts.rindex('[')
            if ts[0] == 'L'
              ts = ts[1..-2].tr('/', '.')
            elsif !arrsep.nil? && ts[arrsep + 1] == 'L'
              ts = ts[0..arrsep] + ts[arrsep + 1..-1].tr('/', '.')
            end
            writeUTF(ts)
            writeBytes([desc.fetch('serialVersion', 0)].pack('q>'))

            flags = 0
            if desc.fetch('externalizable', false)
              flags |= Rex::Java::Serialization::SC_EXTERNALIZABLE
              if @protocol != 1
                flags |= Rex::Java::Serialization::SC_BLOCK_DATA
              end
            else
              flags |= Rex::Java::Serialization::SC_SERIALIZABLE
            end

            if desc.fetch('hasWriteObject', false)
              flags |= Rex::Java::Serialization::SC_WRITE_METHOD
            end

            if desc.fetch('enum', false)
              flags |= Rex::Java::Serialization::SC_ENUM
            end

            fields = desc.fetch('fields', [])

            writeByte(flags)
            writeBytes([fields.length].pack('s>'))

            fields.each do |f|
              fn = f.fetch('name')
              ts = f.fetch('typeString')
              typeCode = ts[0]
              writeByte(typeCode.ord)
              writeUTF(fn)
              writeTypeString(ts) if typeCode == 'L' || typeCode == '['
            end

            # empty annotation block
            setBlockMode(true)
            annotateClass(desc.class) if @annotateClass
            endBlockMode

            stype = desc.fetch('superType', nil)
            sdesc = @registry.getDescriptor(stype) unless stype.nil?
            writeClassDesc(sdesc, false)
          end

          def writeArray(array, desc, unshared)
            writeByte(Rex::Java::Serialization::TC_ARRAY)
            writeClassDesc(desc, false)
            assign(unshared ? nil : array)

            writeBytes([array.values.length].pack('l>'))

            array.values.each do |elem|
              if array.primitive
                writePrimitive(array.componentType, elem)
              else
                writeObject0(elem, false)
              end
            end
          end

          def writePrimitive(type, val)
            val = 0 if val.nil?

            case type
            when 'Z' # boolean
              writeByte(val ? 1 : 0)
              return
            when 'B' # byte
              writeByte(val)
              return
            when 'C' # char
              packed = [val].pack('S>')
            when 'S' # short
              packed = [val].pack('s>')
            when 'I' # int
              packed = [val].pack('l>')
            when 'J' # long
              packed = [val].pack('q>')
            when 'D' # double
              packed = [val].pack('G')
            when 'F' # float
              packed = [val].pack('g')
            else
              raise NotImplementedError, type
            end
            writeBytes(packed)
          end

          def writeObjectOverride(o); end

          def writeObject(o)
            return writeObjectOverride(o) if @enableOverride
            writeObject0(o, false)
          end

          def writeObject0(obj, unshared)
            obm = setBlockMode(false)
            @depth += 1
            begin
              return writeNull if obj.nil?

              if !unshared && (h = lookup(obj)) != -1
                return writeHandle(h)
              elsif obj.instance_of? JavaClass
                if !unshared && (h = lookup(obj.type)) != -1
                  return writeHandle(h)
                else
                  return writeClass(obj.type, unshared)
                end
              elsif obj.instance_of? ObjectStreamClass
                if !unshared && (h = lookup(obj.type)) != -1
                  return writeHandle(h)
                else
                  return writeClassDesc(@registry.getDescriptor(obj.type), unshared)
                end
              end

              # writeReplace

              return writeString(obj, unshared) if obj.instance_of? String

              desc = if obj.respond_to?('desc') && !obj.desc.nil?
                       obj.desc
                     else
                       @registry.getDescriptor(obj.type)
                     end
              if desc.nil?
                raise ClassNotFoundError, obj.type
              elsif obj.type[0] == '['
                writeArray(obj, desc, unshared)
              elsif desc.fetch('enum', false)
                writeEnum(obj, desc, unshared)
              else
                writeOrdinaryObject(obj, desc, unshared)
              end
            ensure
              @depth -= 1
              setBlockMode(obm)
            end
          end

          def writeOrdinaryObject(obj, desc, unshared)
            writeByte(Rex::Java::Serialization::TC_OBJECT)
            writeClassDesc(desc, false)
            assign(unshared ? nil : obj)

            if !desc.fetch('proxy', false) && desc.fetch('externalizable', false)
              writeExternalData(obj, desc)
            else
              writeSerialData(obj, desc)
            end
          end

          def writeSerialData(obj, desc)
            slots = [desc]
            cur = desc
            until cur.fetch('superType', nil).nil?
              cur = @registry.getDescriptor(cur.fetch('superType'))

              break if cur.nil?

              slots += [cur]
            end

            slots.reverse.each do |slotDesc|
              if slotDesc.fetch('hasWriteObject', false)
                setBlockMode(true)
                @registry.writeObject(self, obj, slotDesc)
                endBlockMode
              else
                defaultWriteFields(obj, slotDesc)
              end
            end
          end

          def writeExternalData(obj, desc)
            if @protocol == 1
              @registry.writeExternal(self, obj, desc)
            else
              setBlockMode(true)
              @registry.writeExternal(self, obj, desc)
              endBlockMode
            end
          end

          def defaultWriteObject(obj, desc)
            setBlockMode(false)
            defaultWriteFields(obj, desc)
            setBlockMode(true)
          end

          def defaultWriteFields(obj, desc)
            primFields = []
            objFields = []

            desc.fetch('fields', []).each do |f|
              ts = f.fetch('typeString')
              if ts[0] == '[' || ts[0] == 'L'
                objFields += [f]
              else
                primFields += [f]
              end
            end

            values = obj.fields
            primFields.each do |f|
              fn = f.fetch('name')
              ft = f.fetch('typeString')
              val = values.fetch(fn, nil)
              writePrimitive(ft, val)
            end

            objFields.each do |f|
              fn = f.fetch('name')
              val = values.fetch(fn, nil)
              writeObject0(val, f.fetch('unshared', false))
            end
          end
        end
      end
    end
  end
end

