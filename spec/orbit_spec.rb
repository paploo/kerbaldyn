require File.join(File.dirname(__FILE__), 'spec_helper')

describe KerbalDyn::Orbit do

  describe 'Orbit Types' do

    describe 'Circular Orbit' do
      before(:all, &BeforeFactory.earth)
      before(:all) do
        @orbital_radius = @geostationary_orbit_radius
        @orbital_period = @rotational_period
        @orbital_velocity = @geostationary_orbit_velocity
        @orbital_kinetic_energy = 4726582.58
        @orbital_potential_energy = -9453572.75875
        @orbit = KerbalDyn::Orbit.new(@planetoid, :radius => @orbital_radius)
      end

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

    describe 'Elliptical Orbit'

    describe 'Parabolic Orbit'

    describe 'Hyperbolic Orbit'

  end

  describe 'Orbit Factory Methods' do
    before(:all, &BeforeFactory.earth)

    it 'should construct orbits from periapsis and periapsis velocity'

    it 'should construct orbits from periapsis and apoapsis'

    it 'should construct orbits from semimajor_axis and eccentricity'

    it 'should construct cicular orbits from a radius'

    it 'should construct geostationary orbits' do
      orbit = KerbalDyn::Orbit.geostationary_orbit(@planetoid)
      orbit.eccentricity.should be_within(0.000001).of(0.0)
      orbit.periapsis.should be_within_four_sigma_of(@geostationary_orbit_radius)
      orbit.periapsis_velocity.should be_within_four_sigma_of(@geostationary_orbit_velocity)
    end

    it 'should construct a escape orbits'

  end

end
