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
 require 'yaml'


class Dependencies
  
  attr_accessor :packages  
  attr_accessor :frameworks
  attr_accessor :external
  attr_accessor :review_deps
  
  class CMakeDeps
    def initialize(name)
      @name = name 
      @base_dir = Dir.pwd() + '/'
      @kf5_map = YAML.load_file('frameworks.yaml')  
      @cmake_deps = run_cmakedependencies
      @kf5 = []
      @external = []
      @packages = []
    end
      
    def run_cmakedependencies        
      all = []
      #Run the cmake-dependencies.py tool from kde-dev-tools 
      
      FileUtils.cp('cmake-dependencies.py', @base_dir + @name)
      Dir.chdir(@base_dir + @name) do
        system("cmake \
               -DCMAKE_INSTALL_PREFIX:PATH=/app/usr/ \
              -DCMAKE_BUILD_TYPE=RelWithDebInfo \
              -DBUILD_TESTING=FALSE"
        )
        system("make -j8")
        all = `python3 cmake-dependencies.py | grep '\"project\": '`.sub('\\', '').split(',')
      end      
      all
    end 
    
    def parse_section(section, dep, a)    
      h = @kf5_map[dep]
      unless h[section].nil?        
        h[section]
        if ( section == "distro_packages" )
           a |= h[section]    
        else ( a.include? dep )
          a.delete dep
          a |= h[section]
          a.push dep
        end
      end
      a
    end

    def get_kf5      
      oddballs = []
      kf5_base = []
      all_deps = get_cmakedeps
      all_deps.each do |name|        
        if ( name == "ecm" )
          name = "extra-cmake-modules"
          kf5_base.push name
        end
        if ( name == "phonon4qt5experimental" || name == "phonon4qt5")
          name = "phonon"
          kf5_base.push name
        end
        if ( name =~ /kf5/)
          oddballs = ["ksolid","kthreadweaver","ksonnet","kattica"]
          name = name.sub("kf5", "k")
          oddballs.each do |oddball|
            if ( name == oddball)
              name = name.sub("k", '') 
            end
          end
          kf5_base.push name
        end                   
      end
      kf5_base.delete 'k'
      kf5_base.sort!     
      kf5_base.each do |dep|
        @kf5 |= parse_section("kf5_deps", dep, @kf5)
      end
      @kf5           
    end
    
    def get_packages(kf5_deps)
      kf5_deps.each do |dep|
        @packages |= parse_section("distro_packages", dep, @packages)
      end  
      @packages    
    end  
    
    def get_external(kf5_deps)
      kf5_deps.each do |dep|
        @external |= parse_section("external", dep, @external)
      end  
      @external
    end
    
    def get_cmakedeps
      all_deps = []
      @cmake_deps.each do |dep|
        parts = dep.sub('{', '').sub('}', '').split(',')        
        parts.each do |project|        
          a = project.split.each_slice(3).map{ |x| x.join(' ')}.to_s
          if a.to_s.include? "project"
            name = a.gsub((/[^0-9a-z ]/i), '').downcase
            name.slice! "project "           
            all_deps.push name
          end
        end        
      end
      all_deps
    end
    
    def get_deps_intervention_required 
      non_kf5 = []
      all_deps = get_cmakedeps
      all_deps.each do |name| 
        non_kf5.push name
        if ( name =~ /qt5/ || name =~ /kf5/ || name =~ /ecm/ || name == 'packagehandlestandardargs' )         
          non_kf5.delete name
        end        
      end
      puts non_kf5
      non_kf5
    end
    
  end
end


#   
#   def get_cmakedeps
#     kde_deps = CMakeDeps.new('blinken')
#     kde_deps.frameworks = get_kf5
#     puts kde_deps.frameworks
# #     cmake_deps = ''
# #     
# #           else
# #             @dependencies.push name
# #             
# #           end         
# #         end
# #       end
# #     end

#   end   
  
  
#   
#   def gather_deps
#     require 'erb'
#     require 'yaml'
#     
#     get_cmakedeps     
#     
#     @kf5_dependencies.each do |dep|
#       dependencies = parse_section("distro_packages", dep)
#       frameworks = parse_section("kf5_deps", dep)
#       external = parse_section("external", dep)
#     end
#      File.write('dependencies', ERB.new(File.read('dependencies.erb')).result(binding))
#   end
#   
# end
# 
# 
# 
#   
#   
# 
# #   
# 
# #     puts @dependencies
# #     @dependencies = ""
# #     @dependencies =+ distro_packages.join(' ').to_s + ' ' + dependencies.to_s
# #     @frameworks = kf5_dependencies.join(' ').to_s
# # 
# #      puts @dependencies
# #      puts @frameworks
# #      
# #      File.write('dependencies', render)  
# #      
# #    end    
# #       
# #       unless h["kf5_deps"].nil?
# #        if ( kf5_dependencies.include? dep )
# #          kf5_dependencies.pop dep
# #          kf5_dependencies |= h["kf5_deps"]
# #          kf5_dependencies.push dep
# #        else
# #          kf5_dependencies |= h["kf5_deps"] 
# #          kf5_dependencies.push dep
# #        end
# #       end
# #      end
# #     end
# 
#   
#   #dependencies from the cmake parsing does not match anything from a distro, so 
#   # these still need to be verified by hand and assigned the proper packages. I see no way around this.
  

  
