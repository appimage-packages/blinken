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
    system("git clone http://anongit.kde.org/#{app_name}")
    Dir.chdir(app_name) do
      system("git submodule init")
      system("git submodule update") 
      version = `git describe | sed -e 's/-g.*$// ; s/^v//'`
    end
end

deps = Dependencies.new
cmake_deps = Dependencies::CMakeDeps.new(app_name)

#Retrieve all the framework dependencies with cmake-dependencies.py ( tool from kde-dev-tools)
#Then it is searched in the frameworks.yaml for dependencies of dependencies. This list needs to be 
#maintained as dependencies change. TO-DO research a way to automate that?
#Return as a string so it is usable in the Recipe.erb
deps.frameworks = cmake_deps.get_kf5.join(' ').to_s
# From the above frameworks list we now want to gete any package dependencies needed.
deps.packages = cmake_deps.get_packages(cmake_deps.get_kf5).join(' ').to_s
# Finally we need a list of dependencies that will need to be built from source ( aka centos package is too old.
deps.external = cmake_deps.get_external(cmake_deps.get_kf5)
# These deps are generated with the cmae tool but there is no sane way to get package names or determine automically
# if they need to be source builds... So we can print them and then place them in the appropriate dependency group. 
deps.review_deps = cmake_deps.get_deps_intervention_required
p '====== NEEDS REVIEW ======'
puts deps.review_deps

p '====== FRAMEWORKS DEPS ======'
puts deps.frameworks
p '====== DISTRIBUTION PACKAGES ======'
#Add any packages from review then print
deps.packages = deps.packages + ' gettext python33'
puts deps.packages
p '====== NEEDS SOURCE BUILDS ======'
puts deps.external

#Cleanup
FileUtils.remove_dir(app_name)
recipe = Recipe.new(app_name, version)
builder = CI.new
builder.run = [CI::Build.new()]
builder.cmd = %w[bash -ex /in/Recipe]
builder.create_container
