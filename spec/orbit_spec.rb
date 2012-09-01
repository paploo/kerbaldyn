require File.join(File.dirname(__FILE__), 'spec_helper')

describe KerbalDyn::Orbit do

  describe 'Orbit Types' do

    describe 'Circular Orbit' do
      before(:all, &BeforeFactory.earth)
      before(:all, &BeforeFactory.earth_geostationary_orbit)

      it 'should be closed' do
        @orbit.closed?.should be_true
        @orbit.open?.should be_false
      end

      it 'should be circular' do
        @orbit.kind.should == :circular
      end

      it 'should have zero eccentricity' do
        @orbit.eccentricity.should be_within(0.000001).of(0.0)
      end

      it 'should have the parent body gravitational parameter' do
        @orbit.gravitational_parameter.should be_within_four_sigma_of(@gravitational_parameter)
      end

      it 'should have the right kinetic energy' do
        @orbit.kinetic_energy(@orbital_velocity).should be_within_four_sigma_of(@orbital_kinetic_energy)
      end

      it 'should have the right potential energy' do
        @orbit.potential_energy(@orbital_radius).should be_within_four_sigma_of(@orbital_potential_energy)
      end

      it 'should have total energy that is the sum of kinetic and poential energy' do
        @orbit.energy.should be_within_four_sigma_of( @orbital_kinetic_energy + @orbital_potential_energy )
      end

      it 'should have the right rotational momentum' do
        @orbit.specific_angular_momentum.should be_within_four_sigma_of( @orbital_angular_momentum )
      end

      it 'should have a semimajor_axis equal to the radius' do
        @orbit.semimajor_axis.should be_within_six_sigma_of(@orbital_radius)
      end

      it 'should have a semiminor_axis equal to the radius' do
        @orbit.semiminor_axis.should be_within_six_sigma_of(@orbital_radius)
      end

      it 'should have a periapsis equal to the radius' do
        @orbit.periapsis.should be_within_six_sigma_of(@orbital_radius)
      end

      it 'should have an apoapsis equal to the radius' do
        @orbit.apoapsis.should be_within_six_sigma_of(@orbital_radius)
      end

      it 'should have the expected period' do
        @orbit.period.should be_within_four_sigma_of(@orbital_period)
      end

      it 'should have the correct periapsis_velocity' do
        @orbit.periapsis_velocity.should be_within_four_sigma_of(@orbital_velocity)
      end

      it 'should have the correct apoapsis_velocity' do
        @orbit.apoapsis_velocity.should be_within_four_sigma_of(@orbital_velocity)
      end

    end

    describe 'Elliptical Orbit' do
      before(:all, &BeforeFactory.earth)
      before(:all, &BeforeFactory.geostationary_transfer_orbit)

      it 'should be of kind elliptical' do
        @orbit.kind.should == :elliptical
      end

      [
        :periapsis,
        :apoapsis,
        :periapsis_velocity,
        :apoapsis_velocity,
        :eccentricity,
        :semimajor_axis
      ].each do |parameter|
        it "should calculate the correct #{parameter} value" do
          expected_value = instance_variable_get("@#{parameter}")
          @orbit.send(parameter).should be_within_three_sigma_of(expected_value)
        end
      end

    end

    describe 'Parabolic Orbit' do

      it 'should have the correct escape velocity'

      it 'should be of kind :parabolic'

      it 'should have an eccentricity of 1'

    end

    describe 'Hyperbolic Orbit' do

      it 'should be of kind :hyperbolic'

      it 'should have an eccentricity greater than 1'

    end

  end

  describe 'Orbit Initializers and Factory Methods' do
    before(:all, &BeforeFactory.earth)

    describe 'constructing orbits from periapsis and periapsis velocity' do
      before(:all, &BeforeFactory.geostationary_transfer_orbit)

      it 'should create an elliptical orbit correctly'

    end

    describe 'constructing orbits from periapsis and apoapsis' do
      before(:all, &BeforeFactory.geostationary_transfer_orbit)

      it 'should create an elliptical orbit correctly'

    end

    describe 'constructing orbits from semimajor_axis and eccentricity' do
      before(:all, &BeforeFactory.geostationary_transfer_orbit)

      it 'should create an elliptical orbit correctly'

    end

    describe 'constructing cicular orbits from a radius' do
      before(:all, &BeforeFactory.earth_geostationary_orbit)

      it 'should describe the circular geostationary orbit correctly' do
        orbit = KerbalDyn::Orbit.circular_orbit(@planetoid, @geostationary_orbit_radius)
        orbit.eccentricity.should be_within(0.000001).of(0.0)
        orbit.periapsis.should be_within_four_sigma_of(@geostationary_orbit_radius)
        orbit.periapsis_velocity.should be_within_four_sigma_of(@geostationary_orbit_velocity)
        orbit.apoapsis.should be_within_four_sigma_of(@geostationary_orbit_radius)
        orbit.apoapsis_velocity.should be_within_four_sigma_of(@geostationary_orbit_velocity)
      end

    end

    describe 'constructing geostationary orbits' do
      before(:all, &BeforeFactory.earth_geostationary_orbit)

      it 'should construct geostationary orbit' do
        orbit = KerbalDyn::Orbit.geostationary_orbit(@planetoid)
        orbit.eccentricity.should be_within(0.000001).of(0.0)
        orbit.periapsis.should be_within_four_sigma_of(@geostationary_orbit_radius)
        orbit.apoapsis.should be_within_four_sigma_of(@geostationary_orbit_radius)
        orbit.apoapsis_velocity.should be_within_four_sigma_of(@geostationary_orbit_velocity)
        orbit.periapsis_velocity.should be_within_four_sigma_of(@geostationary_orbit_velocity)
      end

    end

    describe 'constructing escape orbits' do

      it 'should construct an escape orbit'

    end

  end

end
