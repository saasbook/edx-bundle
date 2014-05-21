EdX Bundler
===========

These scripts will help you create an edX course whose video and
subtitle assets reside locally, for example, on a DVD.

You might want this if, for example, you're trying to use the course in
a location whose Internet connection doesn't support streaming video.

Note, this only "localizes" the video and subtitles.  It expects that
the rest of the course will be served through the edX platform as usual.

Requirements
============

Because I'm lazy, this uses all four major scripting languages -- shell,
Ruby, Python, and Perl.  Deal with it.  You therefore need:

 * bash
 * Ruby 1.9+ (`ruby -v` to check)
 * The Nokogiri gem (`gem list nokogiri` to see if you have it; `gem
 install nokogiri`, possibly as root, if you don't)
 * Perl, any version >=5 (`perl -v` to check)
 * The [rg3.github.io/youtube-dl/](`youtube-dl`) Python script (which in turn relies on Python 2.6+; `python --version` to check)
 * Comfort using shell scripts and other power tools.  No GUI here.  If
 step 1 below looks alien to you, stop and get help.

What to do 
==========

There are three main sets of steps:
0. Modify the course definition (XML) to point to videos locally rather than on YouTube
1. Download the actual videos from YouTube
2. Run a local Web server to serve those videos from local storage when you open the course

## Modify the course definition

The first set of steps modifies the XML files exported by Studio to
point to local copies of the videos and video transcript (.srt) files.
As a side effect, it also converts the XML markup in the  `.xml` files describing video assets to use what appears to be the newer XML schema exported by Studio.  (At the end of this file are the details of what this means.)

0. Install the contents of this repo in a directory of your choice, which we'll refer to as `$BUNDLE_PATH` henceforth.
1. Export your edX course from Studio as a tar archive, un-gzip it, and change into its
toplevel directory.  You should see subdirectories `video` and `drafts`
in particular.
2. Run this command:
```sh
find video drafts/video -name '*.xml' | xargs ruby $BUNDLE_PATH/edx-localize.rb
```
3. If all goes well, run the following command to delete the backup files:
```sh
find video drafts/video -name '*.bak' -delete
```
4. Tar up the course directory and re-import it into Studio.

You should now have a course that can be deployed as usual (on Edge or wherever) but expects to find all its videos on a web server listening on `localhost:8000`.

## Download all the videos

The next set of steps downloads the actual videos from YouTube.  This
could take a long time to run, since it will download '''every video in
your course''' to local storage:

5. Make sure `youtube-dl` is in your `$PATH`.
6. From the 

## Run a local webserver

Finally, change to the directory where you downloaded all the videos and run

```sh        
 ruby -run -ehttpd . -p8000
```

Or if you prefer:

```python
python -m SimpleHTTPServer 8000
```

You'd better be running a firewall so that the only access to this webserver is from localhost.  If you prefer a different one-line web server, (https://gist.github.com/willurd/5720255)[here's a whole list of them.]

Appendix: old vs. new <video> tags in XML
=========================================

Especially for older courses that predate Studio authoring, the video tags sometimes look like this (newlines added for clarity):


```xml
<video 
       display_name="Video (5:59)" 
       download_track="true" 
       download_video="true" 
       source="http://s3.amazonaws.com/BESTech/CS169/download/CS169_v13_w1l1s2.mp4" 
       track="http://s3.amazonaws.com/BESTech/CS169/srt/CS169_v13_w1l1s2.srt" 
       youtube="1.00:ifajo-fiRXo" 
       youtube_id_1_0="ifajo-fiRXo">
  <track src="http://s3.amazonaws.com/BESTech/CS169/srt/CS169_v13_w1l1s2.srt"/>
</video>
```

As best I can tell, the `source` attribute identifies the video file and the `track` attribute (if present) identifies the transcript file.  I don't know why there is sometimes a redundant `<track>` element and sometimes not.

When a video file is inserted via Studio, the exported markup looks like this--the `html5_sources` attribute appears to be an XML-escaped list of video source files (though I've yet to see an example where the list has more than 1 element), the `sub` attribute appears to be the root filename, the `youtube` element is gone, the `youtube_id_1_0` element is present but empty, and the `track` attribute has been removed in favor of leaving only the `<track>` element:

```xml
<video 
    display_name="Video" 
    download_track="true" 
    download_video="true" 
    html5_sources="[&quot;http://localhost:8000/ifajo-fiRXo.mp4&quot;]"
    source="" 
    sub="ifajo-fiRXo" 
    track="http://localhost:8000/CS169_v13_w1l1s2.srt" 
    youtube_id_1_0="">
  <source src="http://localhost:8000/ifajo-fiRXo.mp4"/>
  <track src="http://localhost:8000/CS169_v13_w1l1s2.srt"/>
</video>
```

The `edx-localize.rb` script uses Nokogiri to perform this simple transformation.
