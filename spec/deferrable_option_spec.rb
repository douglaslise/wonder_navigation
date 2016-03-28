require 'spec_helper'

RSpec.describe WonderNavigation::DeferrableOption do

  context "with fixed value" do
    it "should return self value" do
      subject.fixed_value = "FixedValue"
      subject.fixed_value_assigned = true
      expect(subject.resolve(nil)).to eq("FixedValue")
    end
  end
  context "with block" do
    context "with parameters" do
      it "should return block's return value" do
        subject.block = proc{|obj| obj }
        expect(subject.resolve("Object")).to eq("Object")
      end
      it "should raise error when calling the block without an object" do
        subject.block = proc {|obj| obj }
        expect{subject.resolve(nil)}.to raise_error(WonderNavigation::EObjectNotSupplied)
      end
      it "should not raise error when calling try_resolve without give an object" do
        subject.block = proc {|obj| obj }
        expect{subject.try_resolve(nil)}.to_not raise_error
      end
    end
    context "without parameters" do
      it "should return block's return value" do
        subject.block = proc { "Resultado" }
        expect(subject.resolve(nil)).to eq("Resultado")
      end
    end
  end
  context "without value neither block" do
    it "should indicate that values are not present" do
      expect(subject.present?).to_not be
    end
    it "should raise exception when calling resolve" do
      expect{subject.resolve(nil)}.to raise_error(WonderNavigation::EDeferrableOptionEmpty)
    end
  end
end
