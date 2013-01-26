require 'spec_helper'
require 'ronin/network/udp'

require 'resolv'

describe Network::UDP do
  describe "helper methods", :network do
    let(:host) { 'scanme.nmap.org' }
    let(:port) { 123 }

    let(:server_host) { 'localhost' }
    let(:server_ip)   { Resolv.getaddress(server_host) }

    subject do
      obj = Object.new
      obj.extend described_class
      obj
    end

    describe "#udp_open?" do
      let(:host) { '4.2.2.1' }
      let(:port) { 53 }

      it "should return true for open ports" do
        subject.udp_open?(host,port).should == true
      end

      it "should return false for closed ports" do
        subject.udp_open?('localhost',rand(1024) + 1).should == false
      end

      it "should have a timeout for firewalled ports" do
        timeout = 2

        t1 = Time.now
        subject.udp_open?(host,1337,nil,nil,timeout)
        t2 = Time.now

        (t2 - t1).to_i.should <= timeout
      end
    end

    describe "#udp_connect" do
      it "should open a UDPSocket" do
        socket = subject.udp_connect(host,port)

        socket.should be_kind_of(UDPSocket)
        socket.should_not be_closed

        socket.close
      end

      context "when local_port is given" do
        let(:local_port) { 1024 + rand(65535 - 1024) }

        it "should bind to a local port" do
          socket      = subject.udp_connect(host,port,nil,local_port)
          bound_port = socket.addr[1]

          bound_port.should == local_port

          socket.close
        end
      end

      it "should yield the new UDPSocket" do
        socket = nil

        subject.udp_connect(host,port) do |yielded_socket|
          socket = yielded_socket
        end

        socket.should_not be_closed
        socket.close
      end
    end

    describe "#udp_connect_and_send" do
      pending "need to find a UDP Service for these specs" do
        let(:data) { "HELO ronin\n" }

        it "should connect and then send data" do
          socket   = subject.udp_connect_and_send(data,host,port)
          banner   = socket.readline
          response = socket.readline

          response.start_with?('250').should be_true

          socket.close
        end

        context "when local_port is given" do
          let(:local_port) { 1024 + rand(65535 - 1024) }

          it "should bind to a local port" do
            socket      = subject.udp_connect_and_send(data,host,port,nil,local_port)
            bound_port = socket.addr[1]

            bound_port.should == local_port

            socket.close
          end
        end

        it "should yield the UDPSocket" do
          response = nil

          socket = subject.udp_connect_and_send(data,host,port) do |socket|
            banner   = socket.readline
            response = socket.readline
          end

          response.start_with?('250').should be_true

          socket.close
        end
      end
    end

    describe "#udp_session" do
      it "should open then close a UDPSocket" do
        socket = nil

        subject.udp_session(host,port) do |yielded_socket|
          socket = yielded_socket
        end

        socket.should be_kind_of(UDPSocket)
        socket.should be_closed
      end

      context "when local_port is given" do
        let(:local_port) { 1024 + rand(65535 - 1024) }

        it "should bind to a local host and port" do
          bound_port = nil

          subject.udp_session(host,port,nil,local_port) do |socket|
            bound_port = socket.addr[1]
          end

          bound_port.should == local_port
        end
      end
    end

    describe "#udp_banner" do
      pending "need to find a UDP service that sends a banner" do
        let(:host) { 'smtp.gmail.com' }
        let(:port) { 25 }

        it "should read the service banner" do
          banner = subject.udp_banner(host,port)

          banner.start_with?('220').should be_true
        end

        context "when local_port is given" do
          let(:local_port) { 1024 + rand(65535 - 1024) }

          it "should bind to a local host and port" do
            banner = subject.udp_banner(host,port,nil,local_port)

            banner.start_with?('220').should be_true
          end
        end

        it "should yield the banner" do
          banner = nil

          subject.udp_banner(host,port) do |yielded_banner|
            banner = yielded_banner
          end

          banner.start_with?('220').should be_true
        end
      end
    end

    describe "#udp_send" do
      let(:server) do
        socket = UDPSocket.new
        socket.bind(server_host,0)
        socket
      end
      let(:server_port) { server.addr[1] }

      let(:data)       { "hello\n" }

      after(:all) { server.close }

      it "should send data to a service" do
        subject.udp_send(data,server_host,server_port)

        mesg = server.recvfrom(data.length)

        mesg[0].should == data
      end

      context "when local_port is given" do
        let(:local_port) { 1024 + rand(65535 - 1024) }

        it "should bind to a local host and port" do
          subject.udp_send(data,server_host,server_port,nil,local_port)

          mesg = server.recvfrom(data.length)

          client_address = mesg[1]
          client_address[1].should == local_port
        end
      end
    end

    describe "#udp_server" do
      let(:server_port) { 1024 + rand(65535 - 1024) }

      it "should create a new UDPSocket" do
        server = subject.udp_server

        server.should be_kind_of(UDPSocket)
        server.should_not be_closed

        server.close
      end

      it "should bind to a specific port and host" do
        server      = subject.udp_server(server_port,server_host)
        bound_host = server.addr[3]
        bound_port = server.addr[1]

        bound_host.should == server_ip
        bound_port.should == server_port

        server.close
      end

      it "should yield the new UDPSocket" do
        server = nil
        
        subject.udp_server do |yielded_server|
          server = yielded_server
        end

        server.should be_kind_of(UDPSocket)
        server.should_not be_closed

        server.close
      end
    end

    describe "#udp_server_session" do
      let(:server_port) { 1024 + rand(65535 - 1024) }

      it "should create a temporary UDPSocket" do
        server = nil
        
        subject.udp_server_session do |yielded_server|
          server = yielded_server
        end

        server.should be_kind_of(UDPSocket)
        server.should be_closed
      end

      it "should bind to a specific port and host" do
        bound_host = nil
        bound_port = nil
        
        subject.udp_server_session(server_port,server_host) do |yielded_server|
          bound_host = yielded_server.addr[3]
          bound_port = yielded_server.addr[1]
        end

        bound_host.should == server_ip
        bound_port.should == server_port
      end
    end

    describe "#udp_recv" do
      let(:server_port) { 1024 + rand(65535 - 1024) }
    end
  end
end
