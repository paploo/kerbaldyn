require File.join(File.dirname(__FILE__), 'spec_helper')

describe KerbalDyn::Mixin::ParameterAttributeHelper do

  class DerivedParametersTestClass
    include KerbalDyn::Mixin::ParameterAttributeHelper

    def initialize(foo)
      self.foo = foo
    end

    attr_parameter :foo
    alias_parameter :bar, :foo

    attr_parameter :alpha, :beta, :gamma
  end

  describe 'attr_parameter' do

    before(:each) do
      @obj = DerivedParametersTestClass.new(42)
    end

    it 'should supply parameter getter' do
      @obj.should respond_to(:foo)
      @obj.foo.should == 42
    end

    it 'should supply parameter setter' do
      @obj.should respond_to(:foo=)
      @obj.foo = 88
      @obj.foo.should == 88
    end

    [Integer, Float, Rational, Complex].each do |type|
      it "should convert parameter of type #{type} as a float" do
        value = Kernel.send(type.name.to_sym, 88)
        value.should be_kind_of(type)

        @obj.foo = value

        @obj.foo.should be_kind_of(Float)
        @obj.foo.should be_within_six_sigma_of(88.0)
      end
    end

    it 'should accept nil' do
      @obj.foo = nil
      @obj.foo.should == nil
    end

    it 'should accept multiple arguments' do
      @obj.should respond_to :alpha
      @obj.should respond_to :beta
      @obj.should respond_to :gamma
    end

  end

  describe 'alias_parameter' do

    before(:each) do
      @obj = DerivedParametersTestClass.new(42)
    end

    it "should read aliased parameter value" do
      @obj.should respond_to(:bar)
      @obj.bar.should == @obj.foo
      @obj.foo = 88
      @obj.bar.should == @obj.foo
    end

    it "should set aliased parameter value" do
      @obj.should respond_to(:bar=)
      @obj.bar = 88
      @obj.bar.should == @obj.foo
    end

  end

end

