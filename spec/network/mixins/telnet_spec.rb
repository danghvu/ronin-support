require 'spec_helper'
require 'ronin/network/mixins/telnet'

describe Network::Mixins::Telnet do
  its(:default_port) { should == 23 }

  describe "helpers", :network do
    let(:host) { 'towel.blinkenlights.nl' }

    subject do
      obj = Object.new
      obj.extend described_class
      obj
    end

    before { subject.host = host }

    describe "#telnet_connect" do
      it "should return a Net::Telnet object" do
        telnet = subject.telnet_connect

        telnet.should be_kind_of(Net::Telnet)
        telnet.close
      end

      it "should connect to a telnet service on port 23" do
        telnet = subject.telnet_connect

        telnet.close
      end

      context "when given a block" do
        it "should yield the new Net::Telnet object" do
          telnet = nil

          subject.telnet_connect do |telnet_object|
            telnet = telnet_object
          end

          telnet.should be_kind_of(Net::Telnet)
          telnet.close
        end
      end
    end

    describe "#telnet_session" do
      it "should yield a new Net::Telnet object" do
        yielded_telnet = nil

        subject.telnet_session do |telnet|
          yielded_telnet = telnet
        end

        yielded_telnet.should be_kind_of(Net::Telnet)
      end

      it "should close the Telnet session after yielding it" do
        session  = nil
        was_open = nil

        subject.telnet_session do |telnet|
          session   = telnet
          was_open  = !telnet.sock.closed?
        end

        was_open.should == true
        session.sock.should be_closed
      end
    end
  end
end
