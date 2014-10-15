#!/bin/sh

grunt build
cd dist/build
meteor bundle sound-duel-fuld.tgz
scp sound-duel-fuld.tgz ubuntu@sd.dr.demo.bitblueprint.com:/home/ubuntu/sound-duel-fuld/
cd ../../
