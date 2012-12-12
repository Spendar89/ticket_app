module SearchesHelper
  def seat_view_url(venue, section)
    url = open("http://api.avf.ms/venue.php?jsoncallback=?key=33970eb4232b8bd273dd548da701abd2&venue=#{URI.escape(venue)}&section=#{section}").read
    hash = JSON.parse("{#{url.scan(/"image":"\w+-\d+.jpg"/)[0]}}")
    return "http://aviewfrommyseat.com/wallpaper/#{hash['image']}" if !hash['image'].nil?
    return false
  end
end
