#!/usr/bin/env ruby

require 'set'
require 'socket'
require 'timeout'
require 'stringio'
require 'openssl'

require 'rex/java/serialization/metamodel'

###
# This module contains basic JRMP protocol implementation and utilities
#
# JRMP is the most common underlying transport protocol for Java RMI.
###
module Rex
  module Java
    module JRMP
      Model = Rex::Java::Serialization::Metamodel

      PROTO_MAGIC = 'JRMI'

      PROTO_VERSION = 2
      PROTO_STREAM = 0x4b
      PROTO_SINGLEOP = 0x4c
      PROTO_MULTIPLEX = 0x4d        

      PROTO_ACK = 0x4e
      PROTO_NACK = 0x4f

      OP_CALL = 0x50
      OP_RETURN = 0x51
      OP_PING = 0x52
      OP_PINGACK = 0x53
      OP_DGCACK = 0x54

      RETURN_NORMAL = 0x1
      RETURN_EX = 0x2

      class JRMPError < StandardError
        attr_accessor :ex
        def initialize(ex)
          @ex = ex
        end
      end

      class InvalidResponseError < StandardError
      end


      class Util

        # unwrap the root cause of an exception
        def self.unwrap_exception(r)
          return if r.nil?
          desc = r[0]
          type = desc[0]
          fields = r[1]
          if !fields['cause'].nil? && fields['cause'] != r
            unwrap_exception(fields['cause'])
          end
          return unwrap_exception(fields['detail']) unless fields['detail'].nil?
          r
        end

        # retrieve the reference from a proxy
        def self.unwrap_ref(r)
          return if r.nil? || r[1].nil?
          r = r[1]['h'] if r[1].key?('h')
          r[1]
        end

        # generate a method hash from a signature
        def self.generate_method_hash(sig)
          sha1 = Digest::SHA1.new
          sha1.update [sig.length].pack('s>') + sig.encode(Encoding::UTF_8)
          dgst = sha1.digest
          dgst[0..8].unpack('q<')[0]
        end

        def self.make_marshalledobject(obj, reg)
          h = 0
          buf = StringIO.new(''.force_encoding('BINARY'))
          oos = Model::ObjectOutputStream.new(buf, reg)
          oos.writeObject(obj)
          oos.flush
          buf.rewind
          bytes = Array(buf.each_byte)
          Model::JavaObject.new('Ljava/rmi/MarshalledObject;', 
                                'hash' => h, 
                                'objBytes' => Model::JavaArray.new('B', bytes))
        end

        # generate an array of arguments with suitable primitive
        # values for a signature, second return value provides
        # the first object values argument found.
        def self.make_dummy_args(sig)
          args = []
          argidx = -1

          s = sig.index('(')
          e = sig.index(')', s + 1)
          argsig = sig[s + 1..e - 1]

          p = 0
          a = 0

          while p < argsig.length
            type, l = parse_argtype(argsig, p)

            if argidx < 0 && (type[0] == 'L' || type['0'] == '[')
              argidx = a
              args.push(nil)
            elsif type[0] == 'Z'
              args.push(Model::JavaBoolean.new(false))
            elsif type[0] == 'B'
              args.push(Model::JavaByte.new(0))
            elsif type[0] == 'S'
              args.push(Model::JavaShort.new(0))
            elsif type[0] == 'C'
              args.push(Model::JavaChar.new(0))
            elsif type[0] == 'I'
              args.push(Model::JavaInteger.new(0))
            elsif type[0] == 'J'
              args.push(Model::JavaLong.new(0))
            elsif type[0] == 'F'
              args.push(Model::JavaFloat.new(0))
            elsif type[0] == 'D'
              args.push(Model::JavaDouble.new(0))
            else
              raise 'Unsupported primitive type'
            end

            p += l
            a += 1
          end
          [args, argidx]
        end

        # read next argument type from signature starting at *p
        def self.parse_argtype(argsig, p)
          type = ''
          l = 0

          if argsig[p] == 'L'
            s = p
            p += 1 while p < argsig.length && argsig[p] != ';'
            type = argsig[s..p + 1]
            l = p - s + 1
          elsif argsig[p] == '['
            atype, al = parse_argtype(argsig[p])
            type = '[' + atype
            l = al + 1
          else
            type = argsig[p]
            l = 1
          end

          [type, l]
        end
      end

      # custom ObjectOutputStream as used by JRMP/RMI
      class MarshalOutputStream < Model::ObjectOutputStream
        def initialize(client, registry, location: nil)
          super(client, registry)
          @annotateClass = true
          @annotateProxyClass = true
          @location = location
        end

        def annotateClass(_cl)
          writeObject(@location)
        end

        def annotateProxyClass(cl)
          annotateClass(cl)
        end
      end

      class JRMPClient
        def initialize(host, port, registry, location: nil, ssl: false)
          @location = location
          @registry = registry

          @client =  nsock = Rex::Socket::Tcp.create(
            'PeerHost'  => host,
            'PeerPort'  => port,
            'SSL'       => ssl
          )
          @client.write(PROTO_MAGIC)
          @client.write([PROTO_VERSION].pack('S>'))
          @client.write([PROTO_SINGLEOP].pack('C'))
          @client.flush
        end



        def convert_primitive(arg)
          bd = ''
          if arg.instance_of? Model::JavaBoolean
            bd = [arg.value ? 1 : 0].pack('C')
          elsif arg.instance_of? Model::JavaByte
            bd = [arg.value].pack('C')
          elsif arg.instance_of? Model::JavaShort
            bd = [arg.value].pack('s>')
          elsif arg.instance_of? Model::JavaChar
            bd = [arg.value].pack('S>')
          elsif arg.instance_of? Model::JavaInteger
            bd = [arg.value].pack('i>')
          elsif arg.instance_of? Model::JavaLong
            bd = [arg.value].pack('q>')
          elsif arg.instance_of? Model::JavaFloat
            bd = [arg.value].pack('g>')
          elsif arg.instance_of? Model::JavaDouble
            bd = [arg.value].pack('G>')
          else
            raise 'Unimplemented'
          end
          bd
        end

        def call(objId, method_id, methodhash, args, uid: nil)
          @client.write([OP_CALL].pack('C'))
          oos = MarshalOutputStream.new(@client, @registry, location: @location)

          uid = [0,0,0] if uid.nil?
          header = [objId, uid[0], uid[1], uid[2], method_id, methodhash].pack('q>l>q>s>I>Q>')
          @client.write([Rex::Java::Serialization::TC_BLOCKDATA, header.length].pack('CC'))
          @client.write(header)

          for arg in args
            begin
              if arg.is_a? Model::JavaPrimitive
                bd = convert_primitive(arg)
                @client.write([Rex::Java::Serialization::TC_BLOCKDATA, bd.length].pack('CC'))
                @client.write(bd)
              else
                oos.writeObject(arg)
              end
              # server may send error and close connection before consuming all arguments
            rescue Errno::ECONNRESET
              econn = true
              break
            rescue Errno::EPIPE
              econn = true
              break
            end
          end

          @client.flush

          rtype = nil
          Timeout.timeout(10) do
            rtype = @client.read(1).unpack('C')[0]
          end

          raise InvalidResponseError, 'Unknown return type ' + rtype.to_s(16) if rtype != OP_RETURN
          smagic, sversion = @client.read(4).unpack('S>S>')
          if smagic != Rex::Java::Serialization::STREAM_MAGIC || 
              sversion != Rex::Java::Serialization::STREAM_VERSION
            raise InvalidResponseError, 'Invalid stream magic' 
          end
          ois = Model::ObjectInputStream.new(@client, @registry)

          bs = ois.read_blockdata
          (resptype, uid1, uid2, uid3) = bs.unpack('CI>Q>S>')

          obj = ois.read_object

          if resptype == RETURN_EX
            raise JRMPError, obj
          elsif econn
            raise 'Connection error'
          end

          obj
        end
      end


      # JRMP Server base implementation
      class JRMPServer
        def initialize(port, registry, bind: true)
          @server = TCPServer.new port if bind
          @registry = registry
        end

        def run
          loop do
            client = @server.accept
            begin
              handle_connection(client)
            rescue ::Exception => e
              puts e.message
            end
          end
        end


        def handle_connection(client)
          magic = client.recv(4)
          if magic != PROTO_MAGIC
            raise 'Invalid magic ' + magic.each_byte.map { |byte| format('%02x', byte) }.join
          end

          ver = client.recv(2).unpack('S>')[0]
          if ver != 2
            raise 'Invalid version ' + ver.to_s(16)
          end

          ois = Model::ObjectInputStream.new(client, @registry)
          proto = client.recv(1).unpack('C')[0]

          if proto == PROTO_STREAM
            handle_stream_proto(client, ois)
          elsif proto == PROTO_SINGLEOP
            handle_request(client, ois)
          else 
            raise 'Invalid protocol'
          end
        ensure
          client.close
        end

        def handle_stream_proto(client, ois)
          if client.respond_to?('peeraddr')
            sock_domain, remote_port, remote_hostname, remote_ip = client.peeraddr
          else
            remote_port = client.peerport
            remote_hostname = client.peerhost
          end
          client.write([PROTO_ACK].pack('C')) # ACK
          client.write([remote_hostname.length].pack('S>'))
          client.write(remote_hostname)
          client.write([remote_port].pack('I>'))
          client.flush

          name = ois.read_utf
          port = client.read(4).unpack('I>')[0]
        end

        def handle_legacy_call(client, ois, objnum, opnum, hash); end

        def handle_call(client, ois)
          smagic, sversion = client.read(4).unpack('S>S>')
          if smagic != Rex::Java::Serialization::STREAM_MAGIC || 
              sversion != Rex::Java::Serialization::STREAM_VERSION
            raise 'Invalid stream magic' 
          end

          # read object id
          bdata = ois.read_blockdata
          # read raw objID
          objnum, suinque, stime, scount, opnum = bdata.unpack('Q>I>Q>S>I>')

          if objnum >= 0 && bdata.length == 34 # DGC
            hash = bdata[26, 34].unpack('Q>')[0]
            handle_legacy_call(client, ois, objnum, opnum, hash)
          else
            raise 'Unsupported call ' + onum.to_s(16)
          end

          # RETURN + MAGIC/VERSION
          client.write([
            OP_RETURN, 
            Rex::Java::Serialization::STREAM_MAGIC, 
            Rex::Java::Serialization::STREAM_VERSION].pack('CS>S>'))

          # Header 
          uiddata = [RETURN_EX, 0, 0, 0].pack('CI>Q>S>')
          client.write([Rex::Java::Serialization::TC_BLOCKDATA, uiddate.length].pack('CS>'))  
          client.write(uiddata)

          client.write([Rex::Java::Serialization::TC_NULL].pack('C')) # NULL for now, object requires class annotations
        end

        def handle_request(client, ois)
          op = client.read(1).unpack('C')[0]
          if op == OP_CALL # Call
            handle_call(client, ois)
          elsif op == OP_PING
            client.write([OP_PINGACK].pack('C'))
          elsif op == OP_DGCACK 
            # ignore
          else
            raise 'Unknown operation ' + op.to_s(16)
          end
          client.flush
        end
      end

      class DGCServer < JRMPServer
        def initialize(port, registry)
          super(port, registry)
          @seen = Set.new
          @handlers = {}
        end

        def handle_dirty(objId)
          if @seen.add?(objId)
            if @handlers.key?(objId)
              h = @handlers[key]
              h(objId)
            end
          end
        end

        def handle_legacy_call(_client, ois, objnum, opnum, _hash)
          return if objnum != 2 || opnum != 1
          rv = ois.read_object
          # rv is array of ObjID
          for id in rv
            objId = id[1]['objNum'].unpack('q>')[0]
            handle_dirty(objId)
          end
        end
      end

      class ExceptionJRMPServer < JRMPServer
        def initialize(port, registry, obj, bind: false)
          super(port, registry, bind: bind)
          @seen = Set.new
          @handlers = {}
          @obj = obj
        end

        def handle_call(client, ois)
          smagic, sversion = client.read(4).unpack('S>S>')
          if smagic != Rex::Java::Serialization::STREAM_MAGIC || 
              sversion != Rex::Java::Serialization::STREAM_VERSION
            raise 'Invalid stream magic'
          end

          # read object id
          bdata = ois.read_blockdata
          # read raw objID
          objnum, suinque, stime, scount, opnum = bdata.unpack('Q>I>Q>S>I>')

          oid = [objnum, suinque, stime, scount]

          return if @seen.include?(oid)
          @seen.add(oid)

          # buffer, subtle differences between native and metasploit IO
          out = StringIO.new

          # RETURN + MAGIC/VERSION
          out.write([OP_RETURN].pack('C')) # Return
          oos = MarshalOutputStream.new(out, @registry)

          oos.setBlockMode(true)
          oos.writeBytes([RETURN_EX].pack('C')) 
          oos.writeBytes([0, 0, 0].pack('I>Q>S>')) # UID

          oos.writeObject(@obj)
          oos.flush

          client.write out.string
          client.flush
        end
      end

    end
  end
end
