# Operating within the OS
require 'erb'

namespace :environment do

  directory "#{BUILD}/bin"

  # Make sure the PATH is correct
  task :path => ["#{BUILD}/bin", :known_distro] do
    old_path = ENV['PATH'].split(/:/)
    path_dirs_for_distro().each do |dir|
      ENV['PATH'] = "#{dir}:#{ENV['PATH']}" unless old_path.include? dir
    end
  end

  desc 'Output a shell script suitable to use this software (best with --silent)'
  task :code => :path do
    puts "export PATH='#{ENV['PATH']}'"
  end

  desc 'Run a subshell with this environment loaded'
  task :shell => :path do
    sh "bash"
  end

  desc 'Install a helper script for a shell to source to use the installed software'
  task :install => :known_distro do
    # If an install (unfortunately called "build") location was specified, put this script
    # there, prioritizing the couch install location over the Erlang one if they differ.
    install_dir = (COUCH_BUILD != BUILD) ? COUCH_BUILD : BUILD
    install_env_script(:to => install_dir)
  end

  desc 'Output the ./configure command to build couchdb'
  task :configure => :known_distro do
    if DISTRO[0] == :solaris
      run_task("environment:path")
      puts "export PATH=\"#{ENV['PATH']}\""
    else
      puts "export PATH=\"#{BUILD}/bin:$PATH\""
    end
    puts "export DYLD_LIBRARY_PATH=\"#{BUILD}/lib:$DYLD_LIBRARY_PATH\"" if DISTRO[0] == :osx
    puts(configure_cmd(".", :prefix => false))
  end

end
