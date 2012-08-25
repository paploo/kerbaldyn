require 'rubygems'
require 'bundler/setup'
Bundler.require(:test)
require 'kerbaldyn'

RSpec::Matchers.define :be_within_error do |err|
  chain :of do |expected|
    @expected = expected
  end

  match do |actual|
    actual.should be_within(err*@expected).of(@expected)
  end
end

{:two => 21.977895, :three => 370.398, :four => 15787.0, :five => 1744278.0, :six => 506797346}.each do |level, frac|
  err = 1.0 / frac.to_f
  RSpec::Matchers.define "be_within_#{level}_sigma_of".to_sym do |expected|
    match do |actual|
      actual.should be_within_error(err).of(expected)
    end
  end
end
