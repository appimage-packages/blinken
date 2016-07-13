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

#attempt to get deps. NOTE: This is for ubuntu/debian based distro
require 'fileutils'


class Dependencies
  def initialize(name)
    @name = name
    @kf5_dependencies = []
    @dependencies = []
  end
    
  attr_accessor :cmake
  attr_accessor :wayland
  attr_accessor :boost
  attr_accessor :frameworks
  attr_accessor :external
  
  def render
    ERB.new(File.read('dependencies.erb')).result(binding)
  end
  
  def get_cmakedeps
    cmake_deps = ''
    oddballs = []
        
   #Run the cmake-dependencies.py tool from kde-dev-tools 
   FileUtils.cp('cmake-dependencies.py', @name)
   Dir.chdir(@name) do
    system("cmake \
    -DCMAKE_INSTALL_PREFIX:PATH=/app/usr/ \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DPACKAGERS_BUILD=1 \
    -DBUILD_TESTING=FALSE"
    )
    system("make -j8")
    cmake_deps = `python3 cmake-dependencies.py | grep '\"project\": '`.sub('\\', '').split(',')
   end
    cmake_deps.each do |dep|
      parts = dep.sub('{', '').sub('}', '').split(',')
      parts.each do |project|        
        a = project.split.each_slice(3).map{ |x| x.join(' ')}.to_s
        if a.to_s.include? "project"
          name = a.gsub((/[^0-9a-z ]/i), '').downcase
          name.slice! "project "
          if ( name == "ecm" )
            name = "extra-cmake-modules"
            @kf5_dependencies.push name
          end
          if ( name =~ /kf5/)
            oddballs = ["ksolid","kthreadweaver","ksonnet","kattica"]
            name = name.sub("kf5", "k")
            oddballs.each do |oddball|
              if ( name == oddball)
                name = name.sub("k", '')                  
              end
            end
            @kf5_dependencies.push name
          else
            @dependencies.push name
            if ( name =~ /qt5/ )
              @dependencies.delete name  
            end 
          end         
        end
      end
    end
    @kf5_dependencies.delete 'k'
    @kf5_dependencies.sort!
    puts @kf5_dependencies
    #Cleanup
    FileUtils.remove_dir(@name)
  end   
  
  def parse_depsection(section, dep)
    kf5_map = YAML.load_file('frameworks.yaml') 
    #p "Gathering dependencies of " dep
    p dep
    h = kf5_map[dep]
    p h["distro_packages"]
#     unless h["distro_packages"].nil? 
#       p " Distribution Packages for #{dep}: "
#       p h["distro_packages"]
#       section |= h["distro_packages"]
#       p "Accumalated packages: "
#       p section
#     end 
  end
  
  def gather_deps
    require 'erb'
    require 'yaml'
    
    get_cmakedeps
    distro_packages = []
     
    
    @kf5_dependencies.each do |dep|
      @dependencies = parse_depsection(distro_packages, dep)
    end
  end
  
end


  
  

#   

#     puts @dependencies
#     @dependencies = ""
#     @dependencies =+ distro_packages.join(' ').to_s + ' ' + dependencies.to_s
#     @frameworks = kf5_dependencies.join(' ').to_s
# 
#      puts @dependencies
#      puts @frameworks
#      
#      File.write('dependencies', render)  
#      
#    end    
#       
#       unless h["kf5_deps"].nil?
#        if ( kf5_dependencies.include? dep )
#          kf5_dependencies.pop dep
#          kf5_dependencies |= h["kf5_deps"]
#          kf5_dependencies.push dep
#        else
#          kf5_dependencies |= h["kf5_deps"] 
#          kf5_dependencies.push dep
#        end
#       end
#      end
#     end

  
  #dependencies from the cmake parsing does not match anything from a distro, so 
  # these still need to be verified by hand and assigned the proper packages. I see no way around this.
  

  
