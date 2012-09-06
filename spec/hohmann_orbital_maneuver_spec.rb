require File.join(File.dirname(__FILE__), 'spec_helper')

describe KerbalDyn::OrbitalManeuver::Hohmann do

  describe "Earth lower-to-higher orbit" do

    before(:all, &BeforeFactory.earth)

    before(:all) do
        # The starting circ orbit.
        @r1 = 6678e3
        @v1 = 7.73e3

        # The final circ orbit.
        @r2 = 42164e3
        @v2 = 3.07e3

        # The transfer orbit apoapsis and periapsis velocities
        @va = 10.15e3
        @vp =  1.61e3

        # The deltas
        @dv1 =  2.42e3
        @dv2 =  1.46e3
        @dv  =  3.88e3


        @orbit1 = KerbalDyn::Orbit.new(@planetoid, :semimajor_axis => @r1, :eccentricity => 0.0)
        @orbit2 = KerbalDyn::Orbit.new(@planetoid, :semimajor_axis => @r2, :eccentricity => 0.0)

        @hohmann = KerbalDyn::OrbitalManeuver::Hohmann.new(@orbit1, @orbit2)
        puts @hohmann.transfer_orbit.inspect
    end

    it 'should calculate burn one from velocity' do
      @hohmann.initial_orbit.apoapsis_velocity.should be_within_two_sigma_of(@v1)
    end

    it 'should calculate burn two from velocity' do
      @hohmann.final_orbit.apoapsis_velocity.should be_within_two_sigma_of(@v2)
    end


    it 'should calculate burn one to velocity' do
      @hohmann.transfer_orbit.periapsis_velocity.should be_within_two_sigma_of(@va)
      @hohmann.transfer_v1.should be_within_two_sigma_of(@va)
    end

    it 'should calculate burn two to velocity' do
      @hohmann.transfer_orbit.apoapsis_velocity.should be_within_two_sigma_of(@vp)
      @hohmann.transfer_v2.should be_within_two_sigma_of(@vp)
    end


    it 'should calculate burn one delta velocity' do
      @hohmann.delta_v1.should be_within_two_sigma_of(@dv1)
    end

    it 'should calculate burn two delta velocity' do
      @hohmann.delta_v2.should be_within_two_sigma_of(@dv2)
    end

    it 'should calculate total delta velocity' do
      @hohmann.delta_v.should be_within_two_sigma_of(@dv)
    end

  end

end
