#!/bin/bash
apt-get -y install software-properties-common libyaml-dev libstemmer-dev itstool
add-apt-repository -y ppa:jonathonf/gtk3.18 && apt-get update && apt-get -y install libglib2.0-dev && add-apt-repository -y -r ppa:jonathonf/gtk3.18
git clone https://github.com/ximion/appstream
cd appstream && mkdir build && cd build && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DQT=ON ../ && make && make install && rm -rfv /appstream
