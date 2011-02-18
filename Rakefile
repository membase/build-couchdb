# Master control of the build system
HERE = File.expand_path(File.dirname(__FILE__))

require "#{HERE}/build-tools/tasks/lib"
Dir[ File.dirname(__FILE__) + '/build-tools/tasks/*.rake' ].sort.each { |subtask| import subtask }
