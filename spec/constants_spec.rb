require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'KerbalDyn Constants' do

  it "should define Newton's gravitational constant" do
    KerbalDyn::G.should be_kind_of(Numeric)
  end

end
