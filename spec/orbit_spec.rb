require File.join(File.dirname(__FILE__), 'spec_helper')

describe KerbalDyn::Orbit do

  describe 'Circularize' do

    before(:all) do
      @elliptical = KerbalDyn::Orbit.new(KerbalDyn::Planetoid.kerbin, :secondary_body => KerbalDyn::Planetoid.test_particle, :periapsis => 700000.0, :apoapsis => 3e6, :inclination => 0.2)
      @circular = @elliptical.circularize
    end

    it 'should have the same primary body' do
      @circular.primary_body.should == @elliptical.primary_body
    end

    it 'should have the same secondary body' do
      @circular.secondary_body.should == @elliptical.secondary_body
    end

    it 'should be circular' do
      @circular.kind.should == :circular
    end

    it 'should have the same semimajor_axis' do
      @circular.semimajor_axis.should == @elliptical.semimajor_axis
    end

    it 'should have zero inclination' do
      @circular.inclination.should be_within(1e-9).of(0.0)
    end

    it 'should have the same period' do
      @circular.period.should be_within_six_sigma_of(@elliptical.period)
    end

    it 'should have a periapsis and apoapsis velocity that is the same as original mean velocity.' do
      @circular.mean_velocity.should be_within_six_sigma_of(@elliptical.mean_velocity)
      @circular.periapsis_velocity.should be_within_six_sigma_of(@elliptical.mean_velocity)
      @circular.apoapsis_velocity.should be_within_six_sigma_of(@elliptical.mean_velocity)
    end

  end

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

      it 'should have the right specific kinetic energy' do
        @orbit.specific_kinetic_energy(@orbital_velocity).should be_within_four_sigma_of(@orbital_specific_kinetic_energy)
      end

      it 'should have the right specific potential energy' do
        @orbit.specific_potential_energy(@orbital_radius).should be_within_four_sigma_of(@orbital_specific_potential_energy)
      end

      it 'should have total specific energy that is the sum of kinetic and poential specific energy' do
        @orbit.specific_energy.should be_within_four_sigma_of( @orbital_specific_kinetic_energy + @orbital_specific_potential_energy )
      end

      it 'should have the right rotational momentum' do
        @orbit.specific_angular_momentum.should be_within_four_sigma_of( @orbital_specific_angular_momentum )
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

      it 'should have the expected mean_angular_velocity' do
        @orbit.mean_angular_velocity.should be_within_four_sigma_of(2.0*Math::PI / @orbital_period)
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
      before(:all, &BeforeFactory.earth)
      before(:all, &BeforeFactory.earth_escape_orbit)

      it 'should have the correct escape velocity' do
        @orbit.periapsis_velocity.should be_within_six_sigma_of(@escape_velocity)
      end

      it 'should be of kind :parabolic' do
        @orbit.kind.should == :parabolic
      end

      it 'should have an eccentricity of 1' do
        @orbit.eccentricity.should be_within_six_sigma_of(1.0)
      end

      it 'should have a total specific energy of zero' do
        @orbit.specific_energy.should be_within(1e-6).of(0.0)
      end

    end

    describe 'Hyperbolic Orbit' do
      before(:all, &BeforeFactory.earth)
      before(:all, &BeforeFactory.earth_hyperbolic_orbit)

      it 'should be of kind :hyperbolic' do
        @orbit.kind.should == :hyperbolic
      end

      it 'should have an eccentricity greater than 1' do
        @orbit.eccentricity.should > 1.0
        @orbit.eccentricity.should be_within_four_sigma_of(@eccentricity)
      end

    end

  end

  describe 'Eccentricity Independent Quantities' do

    before(:all) do
      @primary_planetoid = KerbalDyn::Planetoid.new('Kerbin', :mass => 5.29e22, :radius => 600e3)
      @secondary_planetoid = KerbalDyn::Planetoid.new('Mun', :mass => 9.76e20, :radius => 200e3)
      @semimajor_axis = 12000e3
      @secondary_soi = 2430e3
      @primary_soi = 59.26e6
      @orbit = KerbalDyn::Orbit.new(@primary_planetoid, :secondary_body => @secondary_planetoid, :semimajor_axis => @semimajor_axis, :eccentricity => 0.0)
    end

    it 'should calculate SOI of primary body' do
      @orbit.primary_body_sphere_of_influence.should be_within_four_sigma_of(@primary_soi)
    end

    it 'should cacluate SOI of secondary body' do
      @orbit.secondary_body_sphere_of_influence.should be_within_four_sigma_of(@secondary_soi)
    end

    it 'should default to the secondary body SOI' do
      @orbit.sphere_of_influence.should be_within_four_sigma_of(@secondary_soi)
    end

  end

  describe 'Orbit Initializers and Factory Methods' do
    before(:all, &BeforeFactory.earth)

    describe 'constructing orbits from periapsis and periapsis velocity' do
      before(:all, &BeforeFactory.geostationary_transfer_orbit)

      it 'should create from the initializer' do
        orbit = KerbalDyn::Orbit.new(@planetoid, :periapsis => @periapsis, :periapsis_velocity => @periapsis_velocity)
        [:periapsis, :apoapsis, :periapsis_velocity, :apoapsis_velocity, :eccentricity, :semimajor_axis].each do |parameter|
          orbit.send(parameter).should be_within_three_sigma_of( instance_variable_get("@#{parameter}") )
        end
      end

    end

    describe 'constructing orbits from periapsis and apoapsis' do
      before(:all, &BeforeFactory.geostationary_transfer_orbit)

      it 'should create from the initializer' do
        orbit = KerbalDyn::Orbit.new(@planetoid, :periapsis => @periapsis, :apoapsis => @apoapsis)
        [:periapsis, :apoapsis, :periapsis_velocity, :apoapsis_velocity, :eccentricity, :semimajor_axis].each do |parameter|
          orbit.send(parameter).should be_within_three_sigma_of( instance_variable_get("@#{parameter}") )
        end
      end

    end

    describe 'constructing orbits from semimajor_axis and eccentricity' do
      before(:all, &BeforeFactory.geostationary_transfer_orbit)

      it 'should create from the initializer' do
        orbit = KerbalDyn::Orbit.new(@planetoid, :semimajor_axis => @semimajor_axis, :eccentricity => @eccentricity)
        [:periapsis, :apoapsis, :periapsis_velocity, :apoapsis_velocity, :eccentricity, :semimajor_axis].each do |parameter|
          orbit.send(parameter).should be_within_three_sigma_of( instance_variable_get("@#{parameter}") )
        end
      end

    end

    describe 'constructing cicular orbits from a radius' do
      before(:all, &BeforeFactory.earth_geostationary_orbit)

      it 'should be creatable from the initializer' do
        orbit = KerbalDyn::Orbit.new(@planetoid, :radius => @geostationary_orbit_radius)
        orbit.eccentricity.should be_within(1e-9).of(0.0)
        orbit.periapsis.should be_within_four_sigma_of(@geostationary_orbit_radius)
        orbit.periapsis_velocity.should be_within_four_sigma_of(@geostationary_orbit_velocity)
        orbit.apoapsis.should be_within_four_sigma_of(@geostationary_orbit_radius)
        orbit.apoapsis_velocity.should be_within_four_sigma_of(@geostationary_orbit_velocity)
      end

      it 'should be creatable from the factory method' do
        orbit = KerbalDyn::Orbit.circular_orbit(@planetoid, @geostationary_orbit_radius)
        orbit.eccentricity.should be_within(1e-9).of(0.0)
        orbit.periapsis.should be_within_four_sigma_of(@geostationary_orbit_radius)
        orbit.periapsis_velocity.should be_within_four_sigma_of(@geostationary_orbit_velocity)
        orbit.apoapsis.should be_within_four_sigma_of(@geostationary_orbit_radius)
        orbit.apoapsis_velocity.should be_within_four_sigma_of(@geostationary_orbit_velocity)
      end

      it 'should construct using the orbital period' do
        orbit = KerbalDyn::Orbit.circular_orbit_of_period(@planetoid, @orbital_period)
        orbit.eccentricity.should be_within(1e-9).of(0.0)
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
        orbit.eccentricity.should be_within(1e-9).of(0.0)
        orbit.periapsis.should be_within_four_sigma_of(@geostationary_orbit_radius)
        orbit.apoapsis.should be_within_four_sigma_of(@geostationary_orbit_radius)
        orbit.apoapsis_velocity.should be_within_four_sigma_of(@geostationary_orbit_velocity)
        orbit.periapsis_velocity.should be_within_four_sigma_of(@geostationary_orbit_velocity)
      end

    end

    describe 'constructing escape orbits' do

      it 'should construct an escape orbit' do
        @periapsis = (@planetoid.radius * 2.0) # Just picked one at pseudo-random.
        orbit = KerbalDyn::Orbit.escape_orbit(@planetoid, @periapsis)
        orbit.eccentricity.should be_within(1e-9).of(1.0)
        orbit.specific_energy.should be_within(1e-6).of(0.0)
      end

    end

  end

  describe 'Orbit Library' do

    PLANET_TEST_DATA.each do |planet_key, test_data|
      data = test_data[:orbit]

      describe "#{data[:name]}" do

        before(:all) do
          @library_method = planet_key
          @orbit = KerbalDyn::Orbit.send(@library_method)
        end

        it 'should be memoized' do
          unique_ids = [@orbit, KerbalDyn::Orbit.send(@library_method)].map {|obj| obj.object_id}.uniq
          unique_ids.length.should == 1
        end

        it 'should be frozen' do
          @orbit.should be_frozen
        end

        it "should have the primary_body #{data[:primary_body]}" do
          @orbit.primary_body.should == KerbalDyn::Planetoid.send( data[:primary_body] )
        end

        it "should have the secondary_body #{data[:secondary_body]}" do
          @orbit.secondary_body.should == KerbalDyn::Planetoid.send( data[:secondary_body] )
        end


        data.each do |property, expected_value|
          next if [:primary_body, :secondary_body, :name].include?(property)
          it "should have #{property} of #{expected_value}" do
            value = @orbit.send(property)
            case expected_value
            when Float
              if( expected_value.abs < 1e-15 )
                value.should be_within(1e-15).of(expected_value)
              else
                value.should be_within_five_sigma_of(expected_value)
              end
            else
              value.should == expected_value
            end
          end
        end

      end
    end

  end

end
