#!ruby -n -i.bak -0

# 1-line http server:  ruby -run -ehttpd . -p8000

require 'nokogiri'
require 'uri'

prefix = URI('http://localhost:8000')

begin
  input = Nokogiri::XML::fragment($_)
  video = input.at_xpath('.//video')
  new_video_url = (prefix.merge(video['youtube_id_1_0']+'.mp4')) rescue video['source']
  video['source'] = ''
  video['html5_sources'] = %Q{["#{new_video_url}"]}
  video['sub'] = video['youtube_id_1_0']
  video['youtube_id_1_0'] = ''
  video.remove_attribute 'youtube'

  if (track = video.at_xpath('.//track'))
    track['src'] = video['track'] = prefix.merge track['src'].gsub(/^.*\//, '').to_s
  end
  
  puts input.to_xml

rescue Exception => e
  STDERR.puts e.message
  puts $_
end


# Before

# <video 
#        display_name="Video" 
#        download_track="true" 
#        download_video="true" 
#        source="http://s3.amazonaws.com/BESTech/CS169/download/CS169_v13_w1l1s2.mp4" 
#        track="http://s3.amazonaws.com/BESTech/CS169/srt/CS169_v13_w1l1s2.srt" 
#        youtube="1.00:ifajo-fiRXo" 
#        youtube_id_1_0="ifajo-fiRXo">
#   <track src="http://s3.amazonaws.com/BESTech/CS169/srt/CS169_v13_w1l1s2.srt"/>
# </video>

# After:

# <video 
#     display_name="Video" 
#     download_track="true" 
#     download_video="true" 
#     html5_sources="[&quot;http://localhost:8000/ifajo-fiRXo.mp4&quot;]"
#     source="" 
#     sub="ifajo-fiRXo" 
#     track="http://localhost:8000/CS169_v13_w1l1s2.srt" 
#     youtube_id_1_0="">
#   <source src="http://localhost:8000/ifajo-fiRXo.mp4"/>
#   <track src="http://localhost:8000/CS169_v13_w1l1s2.srt"/>
# </video>
