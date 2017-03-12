# coding: utf-8
module Chihuahua
  class Export

    include Chihuahua::Helper

    def initialize
      @dog = Chihuahua::Client.new.dog
    end

    def export_monitors(name = nil, tags = nil)
      filterd_monitors = []
      begin
        @dog.get_all_monitors({:name => name, :tags => tags}).last.each do |monitor|
          filterd_monitors << filter_monitor(monitor)
        end
      rescue => e
        puts e
      end
      return filterd_monitors
    end

    def store_monitors_data(monitors_data, project, name, tags)
      raise 'Project 名がセットされていません.' unless project
      project_dir = './monitors/' + project
      FileUtils.mkdir_p(project_dir) unless FileTest.exist?(project_dir)

      filter = {}
      filter['name'] = name
      filter['tags'] = tags
      begin
        YAML.dump(filter, File.open(project_dir + '/.filter.yml', 'w'))
      rescue => e
        puts e
      end

      begin
        YAML.dump(monitors_data, File.open(project_dir + '/monitors.yml', 'w'))
      rescue => e
        puts e
      end
      puts monitors_data.length.to_s + ' monitors output done.'
    end
  end
end
