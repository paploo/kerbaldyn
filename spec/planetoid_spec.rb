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

  describe 'Planetoid Library' do

    describe 'Kerbin' do

      before(:all) do
        @planet_fact  = KerbalDyn::Planetoid.kerbin
        @expected_name = 'Kerbin'
      end

      it 'should be available via a factory method' do
        @planet_fact.should be_kind_of(KerbalDyn::Planetoid)
        @planet_fact.name.should == @expected_name
      end

      it 'should be a memoized' do
        # We fetch the constant and the factory method value twice, to be sure they are all the same.
        unique_ids = [@planet_fact, @planet_fact].map {|obj| obj.object_id}.uniq
        unique_ids.length.should == 1
      end

      it 'should be frozen' do
        @planet_fact.should be_frozen
      end

      {
        :radius => 600000.0,
        :mass => 5.29237224636595e22,
        :density => 58493.555811910,
        :surface_gravity => 9.8100,
        :gravitational_parameter => 3531600000000.0,
        :escape_velocity => 3431.03482931899,
        :rotational_period => 21600
      }.each do |param, value|
        it "should have a #{param} of #{value}" do
          @planet_fact.send(param).should be_within_six_sigma_of(value)
        end
      end

      describe 'geostationary orbit' do
        before(:all) do
          @orbit = KerbalDyn::Planetoid.kerbin.geostationary_orbit
        end

        it 'should compute the correct radius' do
          orbit_radius = 3468750.72504862
          @orbit.semimajor_axis.should be_within_six_sigma_of(orbit_radius)
        end

        it 'should compute the correct velocity' do
          @orbit.periapsis_velocity.should be_within_six_sigma_of(1009.01868471732)
        end

      end

    end

    describe 'Kerbol' do

      before(:all) do
        @planet_fact  = KerbalDyn::Planetoid.kerbol
        @expected_name = 'Kerbol'
      end

      it 'should be available via a factory method' do
        @planet_fact.should be_kind_of(KerbalDyn::Planetoid)
        @planet_fact.name.should == @expected_name
      end

      it 'should be a memoized' do
        # We fetch the constant and the factory method value twice, to be sure they are all the same.
        unique_ids = [@planet_fact, @planet_fact].map {|obj| obj.object_id}.uniq
        unique_ids.length.should == 1
      end

      it 'should be frozen' do
        @planet_fact.should be_frozen
      end

      {
        :radius => 261600000.0,
        :mass => 1.756830203555361e28,
        :surface_gravity => 17.13071282744409,
        :gravitational_parameter => 1.172332794832492300e18,
        :escape_velocity => 94672.00722134684
      }.each do |param, value|
        it "should have a #{param} of #{value}" do
          @planet_fact.send(param).should be_within_six_sigma_of(value)
        end
      end

    end

    describe 'Mun' do

      before(:all) do
        @planet_fact  = KerbalDyn::Planetoid.mun
        @expected_name = 'Mun'
      end

      it 'should be available via a factory method' do
        @planet_fact.should be_kind_of(KerbalDyn::Planetoid)
        @planet_fact.name.should == @expected_name
      end

      it 'should be a memoized' do
        # We fetch the constant and the factory method value twice, to be sure they are all the same.
        unique_ids = [@planet_fact, @planet_fact].map {|obj| obj.object_id}.uniq
        unique_ids.length.should == 1
      end

      it 'should be frozen' do
        @planet_fact.should be_frozen
      end

      {
        :radius => 200e3,
        :mass => 9.76148621621169e20,
        :surface_gravity => 1.628459938019515,
        :gravitational_parameter => 65138397520.7806,
        :escape_velocity => 807.0836234293234,
        :rotational_period => 138984.376574476,
      }.each do |param, value|
        it "should have a #{param} of #{value}" do
          @planet_fact.send(param).should be_within_six_sigma_of(value)
        end
      end

    end

    describe 'Minmus' do

      before(:all) do
        @planet_fact  = KerbalDyn::Planetoid.minmus
        @expected_name = 'Minmus'
      end

      it 'should be available via a factory method' do
        @planet_fact.should be_kind_of(KerbalDyn::Planetoid)
        @planet_fact.name.should == @expected_name
      end

      it 'should be a memoized' do
        # We fetch the constant and the factory method value twice, to be sure they are all the same.
        unique_ids = [@planet_fact, @planet_fact].map {|obj| obj.object_id}.uniq
        unique_ids.length.should == 1
      end

      it 'should be frozen' do
        @planet_fact.should be_frozen
      end

      {
        :radius => 60e3,
        :mass => 2.6461861626142216e19,
        :density => 29246.77834176579,
        :surface_gravity => 0.49050000730901944,
        :gravitational_parameter => 1.76580002631247e9,
        :escape_velocity => 242.61080123746,
        :rotational_period => 40400,
      }.each do |param, value|
        it "should have a #{param} of #{value}" do
          @planet_fact.send(param).should be_within_six_sigma_of(value)
        end
      end

    end
  end
end
