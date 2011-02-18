# Build toolchain

require 'tmpdir'
require 'fileutils'
require 'net/http'

def download_autoconf(version)
  olddir = Dir::getwd
  Dir::chdir 'dependencies'

  return if File.directory? "autoconf-#{version}"

  puts "Downloading autoconf #{version}"
  Net::HTTP.start("ftp.gnu.org") do |http|
    resp = http.get("/gnu/autoconf/autoconf-#{version}.tar.gz")
    IO.popen("tar xzf -", "wb") do |pipe|
      pipe.write(resp.body)
    end
  end
ensure
  Dir::chdir olddir
end

namespace :toolchain do

  autotools_versions = %w[ 2.13 2.59 ]

  autotools_versions.each { |v| download_autoconf v }

  autotools_versions.each do |version|

    label = "AUTOCONF_#{version.gsub(/\W/, '')}"
    raise "Woah, why am I bothering to build autoconf #{version}? There is no #{label} constant" unless Object.const_defined? label

    packages = [ package_dep('/opt/csw/bin/gm4'  => 'gm4' , :distros => [:solaris]), package_dep('/opt/csw/bin/gsed' => 'gsed', :distros => [:solaris]) ]

    file Object.const_get(label) => packages do |task|
      Rake::Task['environment:path'].invoke
      Dir.mktmpdir "autoconf-#{version}_build" do |dir|
        Dir.chdir dir do
          fakes = %w[ makeinfo help2man ]
          begin
            fakes.each do |name|
              fake = File.new("#{BUILD}/bin/#{name}", 'w')
              fake.chmod 0700
              fake.close
            end

            show_file('config.log') do
              sh "#{DEPS}/autoconf-#{version}/configure --prefix=#{BUILD} --program-suffix=#{version}"
            end
            gmake
            gmake "install"
            record_manifest task.name
          ensure
            fakes.each do |name|
              FileUtils.rm_f "#{BUILD}/bin/#{name}"
            end
          end
        end
      end
    end
  end

  task :clean do
    %w[ info share/emacs share/autoconf ].each do |dir|
      FileUtils.rm_rf "#{BUILD}/#{dir}"
    end

    autotools_versions.each do |ver|
      Dir.glob("#{BUILD}/bin/*#{ver}").each { |file| FileUtils.rm_f file }
    end
  end

end
