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

require_relative 'gatherdeps.rb'
require_relative 'builddocker.rb'
require 'fileutils'

app_name = 'blinken'
version = ''

if not File.exists?(app_name)
    system("git clone http://anongit.kde.org/#{app_name} #{app_name}")
    Dir.chdir(app_name) do
      system("git submodule init")
      system("git submodule update") 
      version = `git describe | sed -e 's/-g.*$// ; s/^v//'`
    end
end

deps = Dependencies.new(app_name)
deps.gather_deps
puts deps.dependencies
puts deps.frameworks
# recipe = Recipe.new(app_name, version)
# builder = CI.new
# builder.run = [CI::Build.new()]
# builder.cmd = %w[bash -ex /in/Recipe]
# builder.create_container
