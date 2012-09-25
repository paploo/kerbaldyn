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

    PLANET_TEST_DATA.each do |planet_key, test_data|
      data = test_data[:planetoid]

      describe "#{data[:name]}" do

        before(:all) do
          @planetoid = KerbalDyn::Planetoid.send(planet_key)
        end

        it 'should be memoized' do
          unique_ids = [@planetoid, KerbalDyn::Planetoid.send(planet_key)].map {|obj| obj.object_id}.uniq
          unique_ids.length.should == 1
        end

        it 'should be frozen' do
          @planetoid.should be_frozen
        end

        data.each do |property, expected_value|
          it "should have #{property} of #{expected_value}" do
            case expected_value
            when Float
              @planetoid.send(property).should be_within_six_sigma_of(expected_value)
            else
              @planetoid.send(property).should == expected_value
            end
          end
        end

      end

    end

  end

end
