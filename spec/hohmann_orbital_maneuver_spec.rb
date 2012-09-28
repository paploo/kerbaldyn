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
      @vp = 10.15e3
      @va =  1.61e3

      # The deltas
      @dv1 =  2.42e3
      @dv2 =  1.46e3
      @dv  =  3.88e3


      @orbit1 = KerbalDyn::Orbit.new(@planetoid, :semimajor_axis => @r1, :eccentricity => 0.0)
      @orbit2 = KerbalDyn::Orbit.new(@planetoid, :semimajor_axis => @r2, :eccentricity => 0.0)

      @hohmann = KerbalDyn::OrbitalManeuver::Hohmann.new(@orbit1, @orbit2)
    end

    it 'should calculate burn one from velocity' do
      @hohmann.initial_orbit.apoapsis_velocity.should be_within_two_sigma_of(@v1)
      @hohmann.velocities[0][0].should be_within_two_sigma_of(@v1)
    end

    it 'should calculate burn one to velocity' do
      @hohmann.transfer_orbit.periapsis_velocity.should be_within_two_sigma_of(@vp)
      @hohmann.velocities[0][1].should be_within_two_sigma_of(@vp)
    end

    it 'should calculate burn two from velocity' do
      @hohmann.transfer_orbit.apoapsis_velocity.should be_within_two_sigma_of(@va)
      @hohmann.velocities[1][0].should be_within_two_sigma_of(@va)
    end

    it 'should calculate burn two to velocity' do
      @hohmann.final_orbit.apoapsis_velocity.should be_within_two_sigma_of(@v2)
      @hohmann.velocities[1][1].should be_within_two_sigma_of(@v2)
    end

    it 'should calculate burn one delta velocity' do
      @hohmann.delta_velocities[0].should be_within_two_sigma_of(@dv1)
    end

    it 'should calculate burn two delta velocity' do
      @hohmann.delta_velocities[1].should be_within_two_sigma_of(@dv2)
    end

    it 'should calculate total delta velocity' do
      @hohmann.delta_v.should be_within_two_sigma_of(@dv)
    end

    it 'should calculate the lead angle for intercept' do
      # Value calculated several times, several different ways to cross-check
      @hohmann.mean_lead_angle.should be_within_two_sigma_of(1.756)
    end

    it 'should calculate the lead time for intercept' do
      # Value calculated
      @hohmann.mean_lead_time.should be_within_two_sigma_of(4175.58)
    end

    it 'should calculate the realtive anomaly change per complete orbit' do
      delta_theta = -5.887 #separation change per complete rotation ofinitial orbit as compared to something in the final orbit; negative since the lower orbit should close the gap.
      @hohmann.relative_anomaly_delta.should be_within_two_sigma_of(delta_theta)
    end

    it 'should recognize as a move to a lower orbit' do
      @hohmann.moving_to_higher_orbit?.should be_true
    end

  end

  describe "Earth higher-to-lower orbit" do

    before(:all, &BeforeFactory.earth)

    before(:all) do
      # The final circ orbit.
      @r1 = 42164e3
      @v1 = 3.07e3

      # The starting circ orbit.
      @r2 = 6678e3
      @v2 = 7.73e3

      # The transfer orbit apoapsis and periapsis velocities
      @vp = 10.15e3
      @va =  1.61e3

      # The deltas
      @dv1 =  -1.46e3
      @dv2 =  -2.42e3
      @dv  =  3.88e3


      @orbit1 = KerbalDyn::Orbit.new(@planetoid, :semimajor_axis => @r1, :eccentricity => 0.0)
      @orbit2 = KerbalDyn::Orbit.new(@planetoid, :semimajor_axis => @r2, :eccentricity => 0.0)

      @hohmann = KerbalDyn::OrbitalManeuver::Hohmann.new(@orbit1, @orbit2)
    end

    it 'should calculate burn one from velocity' do
      @hohmann.initial_orbit.apoapsis_velocity.should be_within_two_sigma_of(@v1)
      @hohmann.velocities[0][0].should be_within_two_sigma_of(@v1)
    end

    it 'should calculate burn one to velocity' do
      @hohmann.transfer_orbit.apoapsis_velocity.should be_within_two_sigma_of(@va)
      @hohmann.velocities[0][1].should be_within_two_sigma_of(@va)
    end

    it 'should calculate burn two from velocity' do
      @hohmann.transfer_orbit.periapsis_velocity.should be_within_two_sigma_of(@vp)
      @hohmann.velocities[1][0].should be_within_two_sigma_of(@vp)
    end

    it 'should calculate burn two to velocity' do
      @hohmann.final_orbit.apoapsis_velocity.should be_within_two_sigma_of(@v2)
      @hohmann.velocities[1][1].should be_within_two_sigma_of(@v2)
    end

    it 'should calculate burn one delta velocity' do
      @hohmann.delta_velocities[0].should be_within_two_sigma_of(@dv1)
    end

    it 'should calculate burn two delta velocity' do
      @hohmann.delta_velocities[1].should be_within_two_sigma_of(@dv2)
    end

    it 'should calculate total delta velocity' do
      @hohmann.delta_v.should be_within_two_sigma_of(@dv)
    end

    it 'should calculate the lead angle for intercept' do
      # Value calculated several times, several different ways to cross-check
      # This is a large negative number because the lower orbit gets nearly 3.5 periods in during the transfer, which is nearly 22 radians.
      @hohmann.mean_lead_angle.should be_within_two_sigma_of(-18.83)
    end

    it 'should calculate the lead time for intercept' do
      # The lead angle, -18.828, is so insanely close to three times around the circle, that about 20s is actually the lead time!
      @hohmann.mean_lead_time.should be_within_two_sigma_of(19.73)
    end

    it 'should calculate the realtive anomaly change per complete orbit' do
      # This is large because the inner planet gets nearly 16 loops (nearly 100 radians) in for each of the slow orbit's
      delta_theta = 93.40
      @hohmann.relative_anomaly_delta.should be_within_two_sigma_of(delta_theta)
    end

    it 'should recognize as a move to a lower orbit' do
      @hohmann.moving_to_higher_orbit?.should be_false
    end

  end

  describe 'same orbit' do
    before(:all, &BeforeFactory.earth)

    before(:all) do
      @orbit1 = KerbalDyn::Orbit.new(@planetoid, :semimajor_axis => 1000e3, :eccentricity => 0.0)
      @orbit2 = KerbalDyn::Orbit.new(@planetoid, :semimajor_axis => 1000e3, :eccentricity => 0.0)
      @hohmann = KerbalDyn::OrbitalManeuver::Hohmann.new(@orbit1, @orbit2)
    end

    it 'should have zero relative anomaly delta' do
      @hohmann.relative_anomaly_delta.should be_within(1e-6).of(0.0)
    end

    it 'should have zero lead angle' do
      @hohmann.mean_lead_angle.should be_within(1e-6).of(0.0)
    end

  end

end
