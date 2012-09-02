require File.join(File.dirname(__FILE__), 'spec_helper')

describe KerbalDyn::Planetoid do

  describe 'Properties' do
    before(:each, &BeforeFactory.earth)

    it "should have a name" do
      @planetoid.name.should == @name
    end

    [
      :mass,
      :radius,
      :rotational_period,
      :gravitational_parameter,
      :surface_gravity,
      :volume,
      :density,
      :angular_velocity,
      :equitorial_velocity,
      :escape_velocity,
    ].each do |method|
      it "should calculate #{method}" do
        value = self.instance_variable_get("@#{method}")
        # Two sigma let's rough calculations (like those that assume a sphere instead of a spheroid) pass.
        @planetoid.send(method).should be_within_two_sigma_of(value)
      end
    end

    [
      [:gravitational_acceleration, :surface_gravity, :radius],
    ].each do |method, expected_var, *args_vars|
      it "should calculate #{method}" do
        expected = self.instance_variable_get("@#{expected_var}")
        args = args_vars.map {|var| self.instance_variable_get("@#{var}")}
        @planetoid.send(method, *args).should be_within_two_sigma_of(expected)
      end
    end

  end

  describe 'hohmann transfer orbit' do

    before(:each) do
      @r1 = 6678e3
      @r2 = 42164e3
      @h1 = 300e3
      @h2 = 35786e3

      @burn_params = @planetoid.hohmann_transfer_orbit(@r1, @r2)
    end

    it 'should calculate burn one from velocity' do
      @burn_params[:burn_one][:from_velocity].should be_within_two_sigma_of(7.73e3)
    end

    it 'should calculate burn two from velocity' do
      @burn_params[:burn_two][:from_velocity].should be_within_two_sigma_of(1.61e3)
    end


    it 'should calculate burn one to velocity' do
      @burn_params[:burn_one][:to_velocity].should be_within_two_sigma_of(10.15e3)
    end

    it 'should calculate burn two to velocity' do
      @burn_params[:burn_two][:to_velocity].should be_within_two_sigma_of(3.07e3)
    end


    it 'should calculate burn one delta velocity' do
      @burn_params[:burn_one][:delta_velocity].should be_within_two_sigma_of(2.42e3)
    end

    it 'should calculate burn two delta velocity' do
      @burn_params[:burn_two][:delta_velocity].should be_within_two_sigma_of(1.46e3)
    end


    it 'should calculate burn one radius' do
      @burn_params[:burn_one][:radius].should be_within_two_sigma_of(@r1)
    end

    it 'should calculate burn two radius' do
      @burn_params[:burn_two][:radius].should be_within_two_sigma_of(@r2)
    end

    it 'should calculate burn one altitude' do
      @burn_params[:burn_one][:altitude].should be_within_two_sigma_of(@h1)
    end

    it 'should calculate burn two altitude' do
      @burn_params[:burn_two][:altitude].should be_within_two_sigma_of(@h2)
    end
  end

  describe 'Planetoid Library' do

    describe 'Kerbin' do

      before(:all) do
        @planet_const = KerbalDyn::Planetoid::KERBIN
        @planet_fact  = KerbalDyn::Planetoid.kerbin
        @expected_name = 'Kerbin'
      end

      it 'should be available via constant' do
        @planet_const.should be_kind_of(KerbalDyn::Planetoid)
        @planet_const.name.should == @expected_name
      end

      it 'should be available via a factory method' do
        @planet_fact.should be_kind_of(KerbalDyn::Planetoid)
        @planet_fact.name.should == @expected_name
      end

      it 'should be a memoized' do
        # We fetch the constant and the factory method value twice, to be sure they are all the same.
        unique_ids = [@planet_const, @planet_fact, @planet_fact].map {|obj| obj.object_id}.uniq
        unique_ids.length.should == 1
      end

      it 'should be frozen' do
        @planet_fact.should be_frozen
        @planet_const.should be_frozen
      end

      {
        :radius => 600e3,
        :mass => 5.29e22,
        :density => 58467,
        :surface_gravity => 9.8068,
        :gravitational_parameter => 3530.461e9,
        :escape_velocity => 3430.45,
        :rotational_period => 6.0 * 3600.0
      }.each do |param, value|
        it "should have a #{param} of #{value}" do
          KerbalDyn::Planetoid::KERBIN.send(param).should be_within_three_sigma_of(value)
        end
      end

      describe 'geostationary orbit' do
        before(:all) do
          @orbit = KerbalDyn::Planetoid::KERBIN.geostationary_orbit
        end

        it 'should compute the correct radius' do
          orbit_radius = (2868.4e3 + KerbalDyn::Planetoid::KERBIN.radius)
          @orbit.semimajor_axis.should be_within_three_sigma_of(orbit_radius)
        end

        it 'should compute the correct velocity' do
          @orbit.periapsis_velocity.should be_within_three_sigma_of(1008.9)
        end

      end

    end

    describe 'Kerbol' do

      before(:all) do
        @planet_const = KerbalDyn::Planetoid::KERBOL
        @planet_fact  = KerbalDyn::Planetoid.kerbol
        @expected_name = 'Kerbol'
      end

      it 'should be available via constant' do
        @planet_const.should be_kind_of(KerbalDyn::Planetoid)
        @planet_const.name.should == @expected_name
      end

      it 'should be available via a factory method' do
        @planet_fact.should be_kind_of(KerbalDyn::Planetoid)
        @planet_fact.name.should == @expected_name
      end

      it 'should be a memoized' do
        # We fetch the constant and the factory method value twice, to be sure they are all the same.
        unique_ids = [@planet_const, @planet_fact, @planet_fact].map {|obj| obj.object_id}.uniq
        unique_ids.length.should == 1
      end

      it 'should be frozen' do
        @planet_fact.should be_frozen
        @planet_const.should be_frozen
      end

      {
        :radius => 65400e3,
        :mass => 1.75e28,
        :surface_gravity => 273.06,
        :gravitational_parameter => 1.167922e18,
        :escape_velocity => 188.9e3
      }.each do |param, value|
        it "should have a #{param} of #{value}" do
          KerbalDyn::Planetoid::KERBOL.send(param).should be_within_three_sigma_of(value)
        end
      end

    end

    describe 'Mun' do

      before(:all) do
        @planet_const = KerbalDyn::Planetoid::MUN
        @planet_fact  = KerbalDyn::Planetoid.mun
        @expected_name = 'Mun'
      end

      it 'should be available via constant' do
        @planet_const.should be_kind_of(KerbalDyn::Planetoid)
        @planet_const.name.should == @expected_name
      end

      it 'should be available via a factory method' do
        @planet_fact.should be_kind_of(KerbalDyn::Planetoid)
        @planet_fact.name.should == @expected_name
      end

      it 'should be a memoized' do
        # We fetch the constant and the factory method value twice, to be sure they are all the same.
        unique_ids = [@planet_const, @planet_fact, @planet_fact].map {|obj| obj.object_id}.uniq
        unique_ids.length.should == 1
      end

      it 'should be frozen' do
        @planet_fact.should be_frozen
        @planet_const.should be_frozen
      end

      {
        :radius => 200e3,
        :mass => 9.76e20,
        :surface_gravity => 1.628,
        :gravitational_parameter => 65.135e9,
        :escape_velocity => 806,
        :rotational_period => 41.0 * 3600.0,
        #:geostationary_orbit_altitude => 2970876.0, # The wiki seems wrong!
        #:geostationary_orbit_velocity => 143 # The wiki seems wrong!
      }.each do |param, value|
        it "should have a #{param} of #{value}" do
          KerbalDyn::Planetoid::MUN.send(param).should be_within_three_sigma_of(value)
        end
      end

    end

    describe 'Minmus' do

      before(:all) do
        @planet_const = KerbalDyn::Planetoid::MINMUS
        @planet_fact  = KerbalDyn::Planetoid.minmus
        @expected_name = 'Minmus'
      end

      it 'should be available via constant' do
        @planet_const.should be_kind_of(KerbalDyn::Planetoid)
        @planet_const.name.should == @expected_name
      end

      it 'should be available via a factory method' do
        @planet_fact.should be_kind_of(KerbalDyn::Planetoid)
        @planet_fact.name.should == @expected_name
      end

      it 'should be a memoized' do
        # We fetch the constant and the factory method value twice, to be sure they are all the same.
        unique_ids = [@planet_const, @planet_fact, @planet_fact].map {|obj| obj.object_id}.uniq
        unique_ids.length.should == 1
      end

      it 'should be frozen' do
        @planet_fact.should be_frozen
        @planet_const.should be_frozen
      end

      {
        :radius => 60e3,
        :mass => 4.234e19,
        :density => 46790,
        :surface_gravity => 0.785,
        :gravitational_parameter => 2.825505e9,
        :escape_velocity => 306.89,
        :rotational_period => 299.272 * 3600.0,
      }.each do |param, value|
        it "should have a #{param} of #{value}" do
          KerbalDyn::Planetoid::MINMUS.send(param).should be_within_three_sigma_of(value)
        end
      end

    end
  end
end
