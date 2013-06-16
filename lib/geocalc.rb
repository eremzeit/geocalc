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
module GeoCalc
  METERS_PER_NMILE = 1852

  #radians refer to radians of the earth (measured how?)
  METERS_PER_RADIAN = 20001600.0 / Math::PI

  # @param r_lat1 [Integer] lat1 in radians
  # @param r_lon1 [Integer] lon1 in radians
  # @param r_lat2 [Integer] lat2 in radians
  # @param r_lon1 [Integer] lon2 in radians
  # @return [Integer] distance in meters
  def great_circle_distance(r_lat1, r_lon1, r_lat2, r_lon2)
    d_1 = 2.0 * asin(sqrt((sin((r_lat1 - r_lat2) / 2.0)) ** 2.0
    d_2 = cos(r_lat1) * cos(r_lat2) * (sin((r_lon1 - r_lon2) / 2.0)) ** 2.0 ))

    (d_1 + d_2) * METERS_PER_RADIAN
  end

  # I'm not sure how the haversine distance is different from the gc_distance
  # calculated above
  # @param r_lat1 [Integer] lat1 in radians
  # @param r_lon1 [Integer] lon1 in radians
  # @param r_lat2 [Integer] lat2 in radians
  # @param r_lon1 [Integer] lon2 in radians
  # @return [Integer] distance in meters
  def haversine_distance(r_lat1, r_lon1, r_lat2, r_lon2)
    r_dlon = r_lon2 - r_lon1
    r_dlat = r_lat2 - r_lat1

    a = (Math.sin(r_dlat / 2.0)) ** 2.0 + Math.cos(r_lat1) * Math.cos(r_lat2) * (Math.sin(r_dlon / 2.0)) ** 2.0
    c = 2.0 * Math.atan2( Math.sqrt(a), Math.sqrt(1.0 - a))

    c * METERS_PER_RADIAN
  end

  # Returns the true course when starting at r_lat1, r_lon1
  # @param r_lat1 [Integer] lat1 in radians
  # @param r_lon1 [Integer] lon1 in radians
  # @param r_lat2 [Integer] lat2 in radians
  # @param r_lon1 [Integer] lon2 in radians
  # @return [Integer] true course in radians
  def great_circle_true_course_at_start(r_lat1, r_lon1, r_lat2, r_lon2)
    if sin(r_lon2 - r_lon1) < 0.0
      tc1 = acos((sin(r_lat2) - sin(r_lat1) * cos(d)) / (sin(d) * cos(r_lat1)))
    else
      tc1 = 2.0 * pi - acos((sin(r_lat2) - sin(r_lat1) * cos(d)) / (sin(d) * cos(r_lat1)))
    end

    tc1
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
  def great_circle_true_course_at_lat(r_lat1, r_lon1, r_lat2, r_lon2, r_lat_x)
    tc1 = great_circle_true_course_at_start(r_lat1, r_lon1, r_lat2, r_lon2)
    tc_x = asin(sin(tc2) * cos(r_lat2) / cos(r_lat_x))
  end

  # Given a starting point, a true course, and an offset,
  # what is the resulting lat and lon?
  # @param r_lat1 [Integer] lat in radians
  # @param r_lon1 [Integer] lon in radians
  # @param tc [Integer] true course in radians
  # @param r_lon1 [Integer] offset
  # @return [Array] of [r_lat, r_lon]
  def offset_radial_and_distance(r_lat, r_lon, tc, r_offset)
    r_lat = asin(sin(r_lat1) * cos(r_offset) + cos(r_lat1) * sin(r_offset) * cos(tc))
    if (r_lat == 0)
      r_lon = r_lon1 #endpoint a pole
    else
      sindlon = sin(tc) * sin(r_offset) / cos(r_lat)
      cosdlon = (cos(r_offset) - sin(r_lat1) * sin(r_lat)) / (cos(r_lat1) * cos(r_lat))
      dlon = atan2(sindlon, cosdlon)
      r_lon = mod( r_lon1 - dlon + pi, 2.0 * pi ) - pi
    end

    [r_lat, r_lon]
  end

  # @param r_lat1 [Integer] lat1 in radians
  # @param r_lon1 [Integer] lon1 in radians
  # @param r_lat2 [Integer] lat2 in radians
  # @param r_lon1 [Integer] lon2 in radians
  # @return [Array]
  def rhumb_line(r_lat1, r_lon1, r_lat2, r_lon2)
    precision = 10.0 ** -15.0
    dlon_W = mod(r_lon2 - r_lon1, 2.0 * pi)
    dlon_E = mod(r_lon1 - r_lon2, 2.0 * pi)
    dphi = ln((1.0 + sin(r_lat2)) / cos(r_lat2)) - ln((1.0 + sin(r_lat1)) / cos(r_lat1))

    if (dlon_W < dlon_E) #West is the shortest
      tc = mod(atan2(-dlon_W, dphi), 2.0 * pi
    else
      tc = mod(atan2(dlon_E, dphi),2.0 * pi)
    end

    if (abs(r_lat1 - r_lat2) < sqrt(precision))
      d = min(dlon_W, dlon_E) * cos(r_lat1) #distance along parallel
    else
      d = abs((r_lat2 - r_lat1) / cos(tc))
    end

    [d, tc]
  end
end
