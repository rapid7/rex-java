# -*- coding: binary -*-

module Rex
  module Java
    module Classfile
      class Templates
        # this method pathces a Java class file/structure in
        # the following ways:
        # - the static method "payload" is modified to return
        #   a two dimensional array of binary chunks
        # - the string constant "<MAINCLASS>" is replaced with
        #   the specified _mainclass_ argument
        # - the classname is changed to _loadername_
        def self.patch_loader(classdata, loadername, jar, mainclass: nil)
          d = classdata 
          ipos = 0
          _magic, _major, _minor, cpoolcount = d[0..9].unpack('I>S>S>S>')
          ipos += 10

          # parse constant pool
          cpool = []
          i = 0
          while i < cpoolcount - 1
            tag = d[ipos..ipos].unpack('C')[0]
            ipos += 1
            datalen = 0
            case tag
            when 1
              strlen = d[ipos..ipos + 1].unpack('S>')[0]
              ipos += 2
              datalen = strlen
            when 7, 8, 16
              datalen = 2
            when 15
              datalen = 3
            when 3, 4, 9, 10, 11, 12, 18
              datalen = 4
            when 5, 6
              datalen = 8
              i += 1 # + extra slot
            else
              raise KeyError, tag
            end

            data = d[ipos..ipos + datalen - 1]
            ipos += datalen

            if !mainclass.nil?
              data = mainclass if data == '<MAINCLASS>'
            end

            cpool << {
              'idx' => i,
              'tag' => tag,
              'len' => datalen,
              'data' => data
            }

            i += 1
          end

          # locate string type entry, neeed later
          strtyperef = 0
          cpool.each do |entry|
            next if entry['tag'] != 7 #class
            nameidx = entry['data'].unpack("S>")[0]
            if cpool[nameidx-1]['data'] == 'java/lang/String'
                strtyperef = entry['idx'] + 1
                break
            end
          end
          if strtyperef == 0
            raise 'Failed to locate type java.lang.String'
          end

          flags, thiscl, supercl, intcnt = d[ipos..ipos + 7].unpack('S>S>S>S>')
          ipos += 8

          cpool << {
            'tag' => 1,
            'data' => loadername
          }
          cpoolcount += 1
          newidx = cpool.length
          ce = cpool[thiscl - 1]
          ce['data'] = [newidx].pack('S>')

          hexpartrefs = []

          # add runtime data entries to constant pool
          jar.bytes.to_a.each_slice(65536) do |hexpart|
            hexpart = hexpart.map { |b| b.to_s(16).rjust(2, '0') }.join
            # add string value to constant pool
            cpool << {
              'tag' => 1,
              'data' => hexpart
            }
            cpoolcount += 1

            # add reference to string
            cpool << {
              'tag' => 8,
              'data' => [cpool.length].pack('S>')
            }
            hexpartrefs += [cpoolcount]
            cpoolcount += 1
          end

          cpool << {
            'tag' => 3, # Integer
            'data' => [hexpartrefs.length].pack('I>')
          }
          lenref = cpoolcount
          cpoolcount += 1

          out = ''.b
          out += d[0..7]
          out += [cpoolcount].pack('S>')

          # wire out modified constant pool
          cpool.each do |cpe|
            l = cpe['data'].length
            if cpe['tag'] == 1 # CONSTANT_Utf8_info
              out += [1, l].pack('CS>')
            else
              out += [cpe['tag']].pack('C')
            end
            out += cpe['data']
          end

          out += [flags, thiscl, supercl, intcnt].pack('S>S>S>S>')

          intlen = 2 * intcnt
          if intlen > 0
            out += d[ipos..ipos + intlen - 1]
            ipos += intlen
          end

          # copy fields
          fcnt = d[ipos..ipos + 1].unpack('S>')[0]
          ipos += 2
          out += [fcnt].pack('S>')
          for i in 1..fcnt
            access, nameidx, descidx, attrcnt = d[ipos..ipos + 7].unpack('S>S>S>S>')
            ipos += 8
            out += [access, nameidx, descidx, attrcnt].pack('S>S>S>S>')
            for j in 1..attrcnt
              anameidx, alen = d[ipos..ipos + 5].unpack('S>I>')
              ipos += 6
              out += [anameidx, alen].pack('S>I>')
              out += d[ipos..ipos + alen - 1] if alen > 0
              ipos += alen
            end
          end

          # modify methods
          mcnt = d[ipos..ipos + 2].unpack('S>')[0]
          ipos += 2
          out += [mcnt].pack('S>')
          for i in 1..mcnt
            access, nameidx, descidx, attrcnt = d[ipos..ipos + 7].unpack('S>S>S>S>')
            ipos += 8
            out += [access, nameidx, descidx, attrcnt].pack('S>S>S>S>')
            mname = cpool[nameidx - 1]['data']
            for j in 1..attrcnt
              anameidx, alen = d[ipos..ipos + 5].unpack('S>I>')
              ipos += 6
              aname = cpool[anameidx - 1]['data']
              if aname == 'Code' && mname == 'payload'
                bc = generate_initializer(hexpartrefs, strtyperef, lenref)
                out += [anameidx, bc.length].pack('S>I>')
                out += bc
              else
                out += [anameidx, alen].pack('S>I>')
                out += d[ipos..ipos + alen - 1]
              end
              ipos += alen
            end
          end

          # remaining data
          out += d[ipos..-1]
          out
        end



        # generates static method bytecode that initializes
        # initializes the array containing the JAR binary data.
        def self.generate_initializer(hexparts, strtyperef, lenref)
          bc = ''.b
          # iconst_0, istore_0
          bc += "\x03\x3b".b
          # ldc_w lenref
          bc += [0x13, lenref].pack('CS>')
          # anewarray strref
          bc += [0xbd, strtyperef].pack('CS>')

          for i in 0..hexparts.length - 1
            # dup (arr)
            bc += "\x59".b
            # iload_0 (i)
            bc += "\x1a".b
            # ldc_w hexparts[i]
            bc += [0x13, hexparts[i]].pack('CS>')
            # aastore arr, i, hexparts[i]
            bc += "\x53".b

            # iload_0, iinc 0,1, istore_0
            bc += "\x1a\x84\x00\x01\x3b".b
          end

          # areturn
          bc += "\xb0".b
          [16, 1, bc.length].pack('S>S>I>') + bc + [0, 0].pack('S>S>')
        end
      end
    end
  end
end
