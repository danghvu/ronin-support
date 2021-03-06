require 'spec_helper'
require 'ronin/ui/shell'

require 'ui/classes/test_shell'

describe UI::Shell do
  context "with handler callback" do
    let(:line) { 'one two three' }

    it "should call the input handler with the shell and input line" do
      lines = []
      shell = described_class.new { |shell,input| lines << input }

      shell.call(line)

      lines.should == [line]
    end
  end

  context "with commands" do
    subject { TestShell.new }

    describe "#commands" do
      it "should include builtin methods" do
        subject.commands.should include('help', 'exit')
      end

      it "should include protected methods" do
        subject.commands.should include(
          'command1',
          'command_with_arg',
          'command_with_args'
        )
      end

      it "should not include public methods" do
        subject.commands.should_not include('a_public_method')
      end
    end

    describe "#call" do
      it "should ignore empty lines" do
        subject.call('').should == false
      end

      it "should ignore white-space lines" do
        subject.call("     \t   ").should == false
      end

      it "should not allow calling the handler method" do
        subject.call('handler').should == false
      end

      it "should not allow calling unknown commands" do
        subject.call('an_unknown_command').should == false
      end

      it "should not allow calling unknown commands" do
        subject.call('an_unknown_command').should == false
      end

      it "should not allow calling public methods" do
        subject.call('a_public_method').should == false
      end

      it "should allow calling protected methods" do
        subject.call('command1').should == :command1
      end

      it "should raise an exception when passing invalid number of arguments" do
        lambda {
          subject.call('command_with_arg too many args')
        }.should raise_error(ArgumentError)
      end

      it "should splat the command arguments to the command method" do
        subject.call('command_with_args one two three').should == [
          'one', 'two', 'three'
        ]
      end
    end
  end
end
