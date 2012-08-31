require File.join(File.dirname(__FILE__), 'spec_helper')

describe KerbalDyn::Orbit do

  describe 'Properties' do
    before(:each, &BeforeFactory.lunar_orbit)

    [
      :semimajor_axis,
      :eccentricity,
      :inclination,
      :longitude_of_ascending_node,
      :argument_of_periapsis,
      :mean_anomaly,
      :epoch
    ].each do |method|
      it "should calculate #{method}" do
        value = self.instance_variable_get("@#{method}")
        # Two sigma let's rough calculations (like those that assume a sphere instead of a spheroid) pass.
        @orbit.send(method).should be_within_two_sigma_of(value)
      end
    end

    [
    ].each do |method, expected_var, *args_vars|
      it "should calculate #{method}" do
        expected = self.instance_variable_get("@#{expected_var}")
        args = args_vars.map {|var| self.instance_variable_get("@#{var}")}
        @orbit.send(method, *args).should be_within_two_sigma_of(expected)
      end
    end

  end
end
