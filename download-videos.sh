#!/bin/bash

mkdir mp4
for i in `find video drafts/video -name '*.xml' | xargs perl -ne 'print "$1\n" if /sub="([^\"]+)"/'`
do
echo youtube-dl http://youtu.be/$i -o mp4/$i.mp4
done
