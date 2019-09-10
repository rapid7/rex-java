# -*- coding: binary -*-

module Rex
  module Java
    module Serialization
      module Metamodel
        class ObjectInputStream
          def initialize(input, reg)
            @input = input
            @handles = []
            @registry = reg
          end

          def read_utf
            len = @input.read(2).unpack('S>')[0]
            @input.read(len)
          end

          def read_handle
            handle = @input.read(4).unpack('I>')[0] - Rex::Java::Serialization::BASE_WIRE_HANDLE
            @handles[handle]
          end

          def read_string
            read_string_type(@input.read(1).unpack('C')[0])
          end

          def read_string_type(type)
            if type == Rex::Java::Serialization::TC_NULL
              return
            elsif type == Rex::Java::Serialization::TC_REFERENCE
              return read_handle
            elsif type != Rex::Java::Serialization::TC_STRING
              raise Rex::Java::Serialization::DecodeError,
                'Unexpected type: Not a string 0x' + type.to_s
            end

            str = read_utf
            @handles.push(str)
            str
          end

          def read_blockdata
            type = @input.read(1).unpack('C')[0]
            raise Rex::Java::Serialization::DecodeError, 
              'Unexpected type: Not block data' if type != Rex::Java::Serialization::TC_BLOCKDATA
            blen = @input.read(1).unpack('C')[0]
            bdata = @input.read(blen)
            bdata
          end

          def skip_custom
            loop do
              type = @input.read(1).unpack('C')[0]
              if type == Rex::Java::Serialization::TC_BLOCKDATA
                blen = @input.read(1).unpack('C')[0]
                @input.read(blen)
              elsif type == Rex::Java::Serialization::TC_ENDBLOCKDATA
                return
              else
                read_object_type(type)
              end
            end
          end

          def read_object
            data = @input.read(1)
            return if data.nil?
            type = data.unpack('C')[0]
            read_object_type(type)
          end

          def read_object_type(type)
            if type == Rex::Java::Serialization::TC_NULL
              nil
            elsif type == Rex::Java::Serialization::TC_REFERENCE
              read_handle
            elsif type == Rex::Java::Serialization::TC_CLASSDESC
              read_class_desc(type)
            elsif type == Rex::Java::Serialization::TC_OBJECT
              read_ordinary_object
            elsif type == Rex::Java::Serialization::TC_STRING
              read_string_type(type)
            elsif type == Rex::Java::Serialization::TC_ARRAY
              read_array
            elsif type == Rex::Java::Serialization::TC_EXCEPTION
              read_exception
            else
              raise Rex::Java::Serialization::DecodeError,
                'Unsupported object type 0x' + type.to_s(16)
            end
          end

          def defaultReadObject(desc)
            read_object_fields(desc)
          end

          def read_object_fields(desc)
            fields = {}
            for pf in desc[3]
              t = pf[1]
              if t == 'J' || t == 'D'
                val = @input.read(8)
              elsif t == 'I' || t == 'F'
                val = @input.read(4)
              elsif t == 'C' || t == 'S'
                val = @input.read(2)
              elsif t == 'B' || t == 'Z'
                val = @input.read(1)
              else
                raise Rex::Java::Serialization::DecodeError,
                  'Invalid value type ' + t.to_s
              end
              fields[pf[0]] = val
            end

            for of in desc[4]
              fields[of[0]] = read_object
            end
            fields
          end

          def read_ordinary_object
            desc = read_class_desc
            obj = [desc, nil]
            @handles.push(obj)
            flags = desc[2]
            raise Rex::Java::Serialization::DecodeError,
              'Externalizable' if flags & Rex::Java::Serialization::SC_BLOCK_DATA != 0
            fields = {}
            obj[1] = fields

            chain = []
            cur = desc
            begin
              chain.insert(0, cur)
              cur = cur[5]
            end while !cur.nil?

            for cdesc in chain
              tstr = 'L' + cdesc[0].tr('.', '/') + ';'
              sdesc = @registry.getDescriptor(tstr)
              if !sdesc.nil? && sdesc.fetch('hasReadObject', false)
                read = @registry.getHandler(tstr).readObject(self, cdesc)
                fields.merge!(read) unless read.nil?
              else
                fields.merge!(read_object_fields(cdesc))
              end

              skip_custom if cdesc[2] & Rex::Java::Serialization::SC_WRITE_METHOD != 0
            end
            obj
          end

          def read_exception
            raise DeserializeException, read_object
          end

          def read_array
            desc = read_class_desc
            len = @input.read(4).unpack('I>')[0]
            values = []
            @handles.push(values)

            for i in 0..len - 1
              values.push(read_object)
            end

            values
          end

          def read_class_desc
            type = @input.read(1).unpack('C')[0]
            read_class_desc_type(type)
          end

          def read_class_desc_type(type)
            if type == Rex::Java::Serialization::TC_NULL
              nil
            elsif type == Rex::Java::Serialization::TC_REFERENCE
              read_handle
            elsif type == Rex::Java::Serialization::TC_CLASSDESC
              name = read_utf
              suid, flags, nfields = @input.read(11).unpack('Q>CS>')

              primfields = []
              objfields = []
              desc = [name, suid, flags, primfields, objfields, nil]
              @handles.push(desc)
              for i in 0..nfields - 1
                tcode = @input.read(1)[0]
                fname = read_utf
                if tcode == 'L' || tcode == '['
                  tname = read_string
                  objfields.push([fname, tname])
                else
                  primfields.push([fname, tcode])
                end
              end

              skip_custom
              desc[5] = read_class_desc
              desc
            elsif type == Rex::Java::Serialization::TC_PROXYCLASSDESC
              intfs = []
              desc = ['proxy', 0, 0, [], [], nil, intfs]
              @handles.push(desc)
              nintf = @input.read(4).unpack('L>')[0]
              for i in 0..nintf - 1
                intfs[i] = read_utf
              end
              skip_custom
              desc[5] = read_class_desc
              desc
            else
              raise Rex::Java::Serialization::DecodeError,
                'Not a class descriptor 0x' + type.to_s(16)
            end
          end
        end
      end
    end
  end
end

