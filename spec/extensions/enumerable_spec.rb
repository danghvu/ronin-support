require 'spec_helper'
require 'ronin/extensions/enumerable'

describe Enumerable do
  describe "#map_hash" do
    it "should map elements to a Hash" do
      [1, 2, 3].map_hash { |i| i ** 2 }.should == {
        1 => 1,
        2 => 4,
        3 => 9
      }
    end

    it "should not map the same element twice" do
      [1, 2, 2].map_hash { |i| rand }.keys.should =~ [1, 2]
    end

    it "should set the default_proc of the Hash" do
      hash = [].map_hash { |i| i ** 2 }

      hash[3].should == 9
    end
  end
end
