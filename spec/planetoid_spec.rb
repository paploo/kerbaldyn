require File.join(File.dirname(__FILE__), 'spec_helper')

describe KerbalDyn::Planetoid do

  before(:each) do
    # I looked up real values off of tables for the Earth as test data where possible.
    @name = 'Earth'
    @mass = 5.9736e24
    @radius = 6378.1e3
    @rotational_period = 88533.6
    @rotational_velocity = 7.2921150e-5
    @volume = 1.08321e21
    @density = 5515.0
    @gravitational_parameter = 398600.4418e9
    @surface_gravity = 9.780327
    @escape_velocity = 11.186e3
    @equitorial_velocity = 465.1
    @geostationary_orbit_radius = 42164e3
    @geostationary_orbit_altitude = 35786e3
    @geostationary_orbit_angular_velocity = 7.2921e-5
    @geostationary_orbit_velocity = 3074.6

    @options = {
      :rotational_period => @rotational_period
    }
    @planetoid = KerbalDyn::Planetoid.new(@name, @mass, @radius, @options)
  end

  describe 'Basic Properties' do

      it 'should have a name' do
        @planetoid.name.should == @name
      end

      it 'should have mass' do
        @planetoid.mass.should be_within_six_sigma_of(@mass) 
      end

      it 'should have a radius' do
        @planetoid.radius.should be_within_six_sigma_of(@radius)
      end

      it 'should set param as nil with nil' do
        @planetoid.mass = nil
        @planetoid.mass.should be_nil
      end

      [Integer, Float, Rational, Complex].each do |type|
        it 'should convert param of type #{type} as a float' do
          @new_mass = Kernel.send(type.name.to_sym, 12)
          @new_mass.should be_kind_of(type)

          @planetoid.mass = @new_mass

          @planetoid.mass.should be_kind_of(Float)
        end
      end

    describe 'Optional Properties' do

      it 'should have a rotational period' do
        @planetoid.rotational_period.should be_within_six_sigma_of(@rotational_period)
      end

    end

    describe 'Derived Properties' do

      [
        :gravitational_parameter,
        :surface_gravity,
        :volume,
        :density,
        :rotational_velocity,
        :equitorial_velocity,
        :escape_velocity,
        :geostationary_orbit_radius,
        :geostationary_orbit_altitude,
        :geostationary_orbit_velocity
      ].each do |method|
        it "should calculate #{method}" do
          value = self.instance_variable_get("@#{method}")
          # Two sigma let's rough calculations (like those that assume a sphere instead of a spheroid) pass.
          @planetoid.send(method).should be_within_two_sigma_of(value)
        end
      end

      [
        [:gravitational_acceleration, :surface_gravity, :radius],
        [:circular_orbit_velocity, :geostationary_orbit_velocity, :geostationary_orbit_radius],
        [:circular_orbit_angular_velocity, :geostationary_orbit_angular_velocity, :geostationary_orbit_radius],
        [:circular_orbit_period, :rotational_period, :geostationary_orbit_radius],
        [:circular_orbit_velocity_with_period, :geostationary_orbit_velocity, :rotational_period],
        [:circular_orbit_radius_with_period, :geostationary_orbit_radius, :rotational_period]
      ].each do |method, expected_var, *args_vars|
        it "should calculate #{method}" do
          expected = self.instance_variable_get("@#{expected_var}")
          args = args_vars.map {|var| self.instance_variable_get("@#{var}")}
          @planetoid.send(method, *args).should be_within_two_sigma_of(expected)
        end
      end

    end

  end

end
