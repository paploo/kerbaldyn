require File.join(File.dirname(__FILE__), 'spec_helper')

describe KerbalDyn::PartLibrary do

  before(:each) do
    @parts = [
      KerbalDyn::Part::Generic.new(:name => 'part1'),
      KerbalDyn::Part::Generic.new(:name => 'part2').tap {|p| p.send(:errors=, [{:error => :foo, :message => 'bar'}])}
    ]

    @library = KerbalDyn::PartLibrary.new(*@parts)
  end

  it 'should be enumerable' do
    @library.should respond_to(:each)
    @library.class.included_modules.should include(Enumerable)
  end

  it 'should respond to length' do
    @library.should respond_to(:length)
    @library.length.should == @parts.length
  end

  it 'should export as JSON' do
    json = @library.to_json

    json.should be_kind_of(String)
    lambda {JSON.parse(json)}.should_not raise_error
    JSON.parse(json).should be_kind_of(Array)
  end

  it 'should export as CSV' do
    pending "Need to stub CSV output on test parts first."
  end

  describe 'parts directory parser' do

    before(:each) do
      @parts_directory = File.join(File.dirname(__FILE__), 'support', 'parts')
      @library = KerbalDyn::PartLibrary.load_parts(@parts_directory)
    end

    it 'should be composed of parts' do
      @library.reject {|part| part.kind_of?(KerbalDyn::Part::Base)}.should == []
    end

    it 'should have a length of 7' do
      @library.length.should == 7
    end

  end

end
