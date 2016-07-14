#!/usr/bin/env ruby
# frozen_string_literal: true
# 
# Copyright (C) 2016 Scarlett Clark <sgclark@kde.org>
# Copyright (C) 2015-2016 Harald Sitter <sitter@kde.org>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) version 3, or any
# later version accepted by the membership of KDE e.V. (or its
# successor approved by the membership of KDE e.V.), which shall
# act as a proxy defined in Section 6 of version 3 of the license.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library.  If not, see <http://www.gnu.org/licenses/>.
require 'erb'
require 'yaml'

class Recipe
  def initialize(name, version)
    @name = name  
    @proper_name = @name.capitalize
    @version = version
  end

  attr_accessor :proper_name
  
  attr_accessor :version
  attr_accessor :summary
  attr_accessor :description

#  attr_accessor :apps
        
  def render
    ERB.new(File.read('Recipe.erb')).result(binding)
  end
  
  

appimage = Recipe.new

#Needed to add ability to pull in external builds that are simply to old
#in Centos.
appimage.external = 'libarchive,https://github.com/libarchive/libarchive,true,""'
appimage.cmake = true
appimage.wayland = false
appimage.boost = false
#Run gatherdeps local to get dep lists. TO_DO: run on jenkins.
appimage.dependencies = 'bzip2-devel liblzma-devel xz-devel media-player-info.noarch libfam-devel'
appimage.frameworks = 'attica extra-cmake-modules karchive kcoreaddons kauth kcodecs kconfig kdoctools kguiaddons ki18n kwidgetsaddons kconfigwidgets kwindowsystem kcrash kcompletion kitemviews kiconthemes kdbusaddons kservice kjobwidgets solid kxmlgui kbookmarks kio ktextwidgets knewstuff kglobalaccel'
#appimage.apps = [Recipe::App.new("#{appimage.name}")]
File.write('Recipe', appimage.render)
    
end
