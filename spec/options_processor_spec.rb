require File.join(File.dirname(__FILE__), 'spec_helper')

describe KerbalDyn::Mixin::OptionsProcessor do

  class OptionsProcessorTestClass
    include KerbalDyn::Mixin::OptionsProcessor
    DEFAULTS = {:foo => :default}

    def initialize(opts={})
      process_options(opts, DEFAULTS)
    end

    attr_accessor :foo
    attr_accessor :alpha
  end

  it 'should set valid keys' do
    obj = OptionsProcessorTestClass.new(:foo => :bar, :alpha => :beta)
    obj.foo.should == :bar
    obj.alpha.should == :beta
  end

  it 'should error on invalid keys' do
    lambda {OptionsProcessorTestClass.new(:miss => :sunshine)}.should raise_error(NoMethodError)
  end

  it 'should use a block as a defaults hook' do
    obj = OptionsProcessorTestClass.new
    obj.foo.should == :default
    obj.alpha.should == nil
  end

end
