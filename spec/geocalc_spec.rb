describe GeoSpec do
  #LAX in Los Angeles
  let(:lat_lon1) { [0.592539, 2.066470] }

  #JFK in new york city
  let(:lat_lon2) { [0.709186, 1.287762] }

  # Dehli International Airpoint
  let(:lat_lon3) { [0.49848882836961156, 1.3459954931303668] }

  describe '::great_circle_distance' do
    it 'finds the distance between LAX and JFK and vise versa' do
      meters = GeoSpec.great_circle_distance(lat_lon1[0], lat_lon1[1], lat_lon2[0], lat_lon2[1])
      expect(meters).to be_within(100).of(3970688)
    end
  end

  describe '::haversine_distance' do
    meters = GeoSpec.haversine_distance(lat_lon1[0], lat_lon1[1], lat_lon2[0], lat_lon2[1])
    expect(meters).to be_within(100).of(3970688)
  end

  describe '::great_circle_true_course_at_start' do
    tc = GeoSpec.great_circle_true_course_at_start(lat_lon1[0], lat_lon1[1], lat_lon2[0], lat_lon2[1])
    expect(tc).to be_within(0.0001).of(1.150035) #radians
  end


  describe '::great_circle_true_course_at_lat' do
    def self.great_circle_true_course_at_lat(lat_lon1[0], lat_lon1[1], lat_lon2[0], lat_lon2[1])
  end

  describe '::self.offset_radial_and_distance' do

    #self.offset_radial_and_distance
  end

  describe '::rhumb_line' do
    #def self.rhumb_line(r_lat1, r_lon1, r_lat2, r_lon2)
  end
end



  def self.great_circle_distance(r_lat1, r_lon1, r_lat2, r_lon2)
  end

  def self.haversine_distance(r_lat1, r_lon1, r_lat2, r_lon2)
  end

  def self.great_circle_true_course_at_start(r_lat1, r_lon1, r_lat2, r_lon2)
  end


  def self.great_circle_true_course_at_lat(r_lat1, r_lon1, r_lat2, r_lon2, r_lat_x)
  end
  def self.offset_radial_and_distance(r_lat, r_lon, tc, r_offset)
  end

  def self.rhumb_line(r_lat1, r_lon1, r_lat2, r_lon2)
  end
