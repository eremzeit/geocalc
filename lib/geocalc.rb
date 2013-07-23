#True Course (tc) is defined as the angle in radians from the course
#line and the local meridian (due north), measure clockwise.
#
# These methods were implemented based on the formula discussed here:
# http://williams.best.vwh.net/ftp/avsig/gcircle.pdf
#
# All methods below use receive their lat and lon measurements in
# radians.
#
# Their distances are converted originally from radians also.  To convert to
# linear distances, we just use the number of meters per earth
# radian (or km or feet or whatever).
#
# North latitudes and West longitudes are treated as
# positive, and South latitudes and East longitudes negative.
#
#TODO: rename this to be Rubiary
module GeoCalc
  # Radians refer to radians of the earth.  though this differs, depending on
  # whether you measure equatorally or through the poles, this is an
  # approximation
  METERS_PER_RADIAN = 180.0 * 60.0 / Math::PI * 1852.0


  # This uses the law of haversines to calculate the great circle distance.
  # @param r_lat1 [Integer] lat1 in radians
  # @param r_lon1 [Integer] lon1 in radians
  # @param r_lat2 [Integer] lat2 in radians
  # @param r_lon1 [Integer] lon2 in radians
  # @return [Integer] distance in meters
  def self.great_circle_distance(r_lat1, r_lon1, r_lat2, r_lon2)
    great_circle_distance_rads(r_lat1, r_lon1, r_lat2, r_lon2) * METERS_PER_RADIAN
  end

  # @param r_lat1 [Integer] lat1 in radians
  # @param r_lon1 [Integer] lon1 in radians
  # @param r_lat2 [Integer] lat2 in radians
  # @param r_lon1 [Integer] lon2 in radians
  # @return [Float] Distance in radians
  def self.great_circle_distance_rads(r_lat1, r_lon1, r_lat2, r_lon2)
    a = (Math.sin((r_lat1 - r_lat2) / 2.0)) ** 2.0
    b = Math.cos(r_lat1) * Math.cos(r_lat2) * (Math.sin((r_lon1 - r_lon2) / 2.0)) ** 2.0
    2.0 * Math.asin(Math.sqrt(a + b))
  end

  # I'm not sure how the haversine distance is different from the gc_distance
  # calculated above
  # Correction: once the terms are simplified, it's the same formula
  # @param r_lat1 [Integer] lat1 in radians
  # @param r_lon1 [Integer] lon1 in radians
  # @param r_lat2 [Integer] lat2 in radians
  # @param r_lon1 [Integer] lon2 in radians
  # @return [Integer] distance in meters
  def self.haversine_distance(r_lat1, r_lon1, r_lat2, r_lon2)
    r_dlon = r_lon2 - r_lon1
    r_dlat = r_lat2 - r_lat1

    a = (Math.sin(r_dlat / 2.0)) ** 2.0
    b = Math.cos(r_lat1) * Math.cos(r_lat2) * (Math.sin(r_dlon / 2.0)) ** 2.0
    r_dist = 2.0 * Math.atan2( Math.sqrt(a + b), Math.sqrt(1.0 - (a + b)))

    r_dist * METERS_PER_RADIAN
  end

  # Returns the true course when starting at r_lat1, r_lon1
  # @param r_lat1 [Integer] lat1 in radians
  # @param r_lon1 [Integer] lon1 in radians
  # @param r_lat2 [Integer] lat2 in radians
  # @param r_lon1 [Integer] lon2 in radians
  # @return [Integer] true course in radians
  def self.great_circle_true_course_at_start(r_lat1, r_lon1, r_lat2, r_lon2)

    # if starting on a pole
    if Math.cos(r_lat1) < Float::EPSILON
      if (r_lat1 > 0)
        #starting from N pole due south
        return Math::PI
      else
        # starting from S pole, so we go due north
        return 2.0 * Math::PI
      end
    end

    d = great_circle_distance_rads(r_lat1, r_lon1, r_lat2, r_lon2)

    # if not starting on a pole
    if Math.sin(r_lon2 - r_lon1) < 0.0
      return Math.acos((Math.sin(r_lat2) - Math.sin(r_lat1) * Math.cos(d)) / (Math.sin(d) * Math.cos(r_lat1)))
    else
      return 2.0 * Math::PI - Math.acos((Math.sin(r_lat2) - Math.sin(r_lat1) * Math.cos(d)) / (Math.sin(d) * Math.cos(r_lat1)))
    end
  end

  # Given two coordinates, which implicitly form a great circle, find the
  # true course at an arbitrary latitude.
  #
  # @param r_lat1 [Integer] lat1 in radians
  # @param r_lon1 [Integer] lon1 in radians
  # @param r_lat2 [Integer] lat2 in radians
  # @param r_lon1 [Integer] lon2 in radians
  # @param r_lon_x [Integer] lat that we are querying with
  # @return [Integer] true course in radians
  def self.great_circle_true_course_at_lat(r_lat1, r_lon1, r_lat2, r_lon2, r_lat_x)
    tc1 = great_circle_true_course_at_start(r_lat1, r_lon1, r_lat2, r_lon2)
    tc_x = Math.asin(Math.sin(tc2) * Math.cos(r_lat2) / Math.cos(r_lat_x))
  end

  # Given a starting point, a true course, and an offset,
  # what is the resulting lat and lon?
  # @param r_lat1 [Integer] lat in radians
  # @param r_lon1 [Integer] lon in radians
  # @param tc [Integer] true course in radians
  # @param r_lon1 [Integer] offset
  # @return [Array] of [r_lat, r_lon]
  def self.offset_radial_and_distance(r_lat, r_lon, tc, r_offset)
    r_lat = Math.asin(Math.sin(r_lat1) * Math.cos(r_offset) + Math.cos(r_lat1) * Math.sin(r_offset) * Math.cos(tc))
    if (r_lat == 0)
      r_lon = r_lon1 #endpoint a pole
    else
      sindlon = Math.sin(tc) * Math.sin(r_offset) / Math.cos(r_lat)
      cosdlon = (Math.cos(r_offset) - Math.sin(r_lat1) * Math.sin(r_lat)) / (Math.cos(r_lat1) * Math.cos(r_lat))
      dlon = Math.atan2(sindlon, cosdlon)
      r_lon = mod( r_lon1 - dlon + pi, 2.0 * pi ) - pi
    end

    [r_lat, r_lon]
  end

  # @param r_lat1 [Integer] lat1 in radians
  # @param r_lon1 [Integer] lon1 in radians
  # @param r_lat2 [Integer] lat2 in radians
  # @param r_lon1 [Integer] lon2 in radians
  # @return [Array]
  def self.rhumb_line(r_lat1, r_lon1, r_lat2, r_lon2)
    precision = 10.0 ** -15.0
    dlon_W = mod(r_lon2 - r_lon1, 2.0 * pi)
    dlon_E = mod(r_lon1 - r_lon2, 2.0 * pi)
    dphi = ln((1.0 + Math.sin(r_lat2)) / Math.cos(r_lat2)) - ln((1.0 + Math.sin(r_lat1)) / Math.cos(r_lat1))

    if (dlon_W < dlon_E) #West is the shortest
      tc = mod(Math.atan2(-dlon_W, dphi), 2.0 * pi)
    else
      tc = mod(Math.atan2(dlon_E, dphi),2.0 * pi)
    end

    if (abs(r_lat1 - r_lat2) < Math.sqrt(precision))
      d = min(dlon_W, dlon_E) * Math.cos(r_lat1) #distance along parallel
    else
      d = abs((r_lat2 - r_lat1) / Math.cos(tc))
    end

    [d * METERS_PER_RADIAN, tc]
  end


  # @param deg [Integer] degrees
  # @param min [Integer] min
  # @param sec [Integer] sec
  # @return [Float] the same measure but as a decimal
  def self.to_dec_degrees(deg, min, sec)
    Float(deg) + Float(min) / 60.0 + Float(sec) / 3600.0
  end

  # Converts radians of the earth to a quantity of meters.  This assumes that
  # a nautical mile is equal to 1852 meters.
  # @params earth_rads [Float] radians of the earth
  # @return [Float] the number of meters
  def self.earth_rads_to_meters(earth_rads)
    earth_rads * METERS_PER_RADIAN
  end
end


# Require all nested files
Dir.glob('./lib/geocalc/*.rb').each do |filename|
  require filename
end
