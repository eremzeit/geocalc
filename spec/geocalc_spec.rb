require 'spec_helper'

describe GeoCalc do
  #LAX in Los Angeles
  let(:lat_lon1) { [0.592539, 2.066470] }

  #JFK in new york city
  let(:lat_lon2) { [0.709186, 1.287762] }

  # Dehli International Airpoint
  let(:lat_lon3) { [0.49848882836961156, 1.3459954931303668] }

  describe '::great_circle_distance' do
    it 'finds the distance between LAX and JFK' do
      meters = GeoCalc.great_circle_distance(lat_lon1[0], lat_lon1[1], lat_lon2[0], lat_lon2[1])
      expect(meters).to be_within(1000).of(3970688)
    end

    it 'returns the same result with the arguments flipped' do
      meters1 = GeoCalc.great_circle_distance(lat_lon1[0], lat_lon1[1], lat_lon2[0], lat_lon2[1])

      ##swap args
      temp_lat_lon = lat_lon1
      lat_lon1 = lat_lon2
      lat_lon2 = temp_lat_lon

      meters2 = GeoCalc.great_circle_distance(lat_lon1[0], lat_lon1[1], lat_lon2[0], lat_lon2[1])
      expect(meters1).to be_within(10).of(meters2)
    end
  end


  # This is duplicate.  Haversine is just the name of the method for calculating GCD.
  describe '::haversine_distance' do
    it 'finds the distance between LAX and JFK and vise versa' do
      meters = GeoCalc.haversine_distance(lat_lon1[0], lat_lon1[1], lat_lon2[0], lat_lon2[1])
      expect(meters).to be_within(1000).of(3970688)
    end
  end

  describe '::great_circle_true_course_at_start' do
    it 'calculates the gc true course' do
      tc = GeoCalc.great_circle_true_course_at_start(lat_lon1[0], lat_lon1[1], lat_lon2[0], lat_lon2[1])
      expect(tc).to be_within(0.0001).of(1.150035) #radians
    end
  end

  describe '::self.offset_radial_and_distance' do

    #self.offset_radial_and_distance
  end

  describe '::rhumb_line' do
    #def self.rhumb_line(r_lat1, r_lon1, r_lat2, r_lon2)
  end
end



  #def self.great_circle_distance(r_lat1, r_lon1, r_lat2, r_lon2)
  #end

  #def self.haversine_distance(r_lat1, r_lon1, r_lat2, r_lon2)
  #end

  #def self.great_circle_true_course_at_start(r_lat1, r_lon1, r_lat2, r_lon2)
  #end


  #def self.great_circle_true_course_at_lat(r_lat1, r_lon1, r_lat2, r_lon2, r_lat_x)
  #end
  #def self.offset_radial_and_distance(r_lat, r_lon, tc, r_offset)
  #end

  #def self.rhumb_line(r_lat1, r_lon1, r_lat2, r_lon2)
  #end
