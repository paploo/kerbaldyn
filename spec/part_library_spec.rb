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

  it 'should map to a library'

  it 'should select/reject to a library'

  it 'should inject/reduce to a library'

  it 'should export as JSON' do
    json = @library.to_json

    json.should be_kind_of(String)
    lambda {JSON.parse(json)}.should_not raise_error
    JSON.parse(json).should be_kind_of(Array)
  end

  it 'should export as CSV' do
    pending "Need to stub CSV output on test parts first."
  end

  describe 'parser' do

    it 'should parse a directory of parts into a library'

  end

end
