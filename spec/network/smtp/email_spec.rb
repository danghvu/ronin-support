require 'spec_helper'
require 'ronin/network/smtp/email'

require 'date'

describe Network::SMTP::Email do
  describe "#initialize" do
    it "should default 'date' to Time.now" do
      email = Network::SMTP::Email.new

      email.date.should_not be_nil
    end

    it "should accept a String body" do
      body = 'hello'
      email = Network::SMTP::Email.new(body: body)

      email.body.should == [body]
    end

    it "should accept an Array body" do
      body = ['hello', 'world']
      email = Network::SMTP::Email.new(body: body)

      email.body.should == body
    end

    it "should default 'body' to an empty Array" do
      email = Network::SMTP::Email.new

      email.body.should be_empty
    end
  end

  describe "#to_s" do
    subject { Network::SMTP::Email.new }

    it "should add the 'from'" do
      subject.from = 'joe@example.com'

      subject.to_s.should include("From: joe@example.com\n\r")
    end

    context "when formatting 'to'" do
      it "should accept an Array of addresses" do
        subject.to = ['alice@example.com', 'joe@example.com']

        subject.to_s.should include("To: alice@example.com, joe@example.com\n\r")
      end

      it "should accept a String" do
        subject.to = 'joe@example.com'

        subject.to_s.should include("To: joe@example.com\n\r")
      end
    end

    it "should add the 'subject'" do
      subject.subject = 'Hello'

      subject.to_s.should include("Subject: Hello\n\r")
    end

    it "should add the 'date'" do
      subject.date = Date.parse('Sun Apr 24 17:22:55 PDT 2011')

      subject.to_s.should include("Date: #{subject.date}\n\r")
    end

    it "should add the 'message_id'" do
      subject.message_id = '1234'

      subject.to_s.should include("Message-Id: <#{subject.message_id}>\n\r")
    end

    it "should add additional headers" do
      subject.headers['X-Foo'] = 'Bar'
      subject.headers['X-Baz'] = 'Quix'

      lines = subject.to_s.split("\n\r")
      
      lines.should include('X-Foo: Bar')
      lines.should include('X-Baz: Quix')
    end

    context "when formatting 'body'" do
      it "should append each line with a CRLF" do
        subject.body = ['hello', 'world']

        subject.to_s.should include("hello\n\rworld")
      end

      it "should add a CRLF before the body" do
        subject.body = ['hello', 'world']

        subject.to_s.should include("\n\rhello")
      end
    end
  end
end
