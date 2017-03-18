# coding: utf-8
module Chihuahua
  class Export

    include Chihuahua::Helper

    def initialize(project, *args)
      @dog = Chihuahua::Client.new.dog
      @project = project
      @args = args.last
      @project_dir = './monitors/' + @project
      @monitors_file_path = @project_dir + '/monitors.yml'
      @filter_file_path = @project_dir + '/.filter.yml'
    end

    def export_result_display(name)
      puts hl.color(name, :magenta) + ' exporting...'
    end

    def export_monitors(project)
      call_from = caller[0][/`([^']*)'/, 1]

      if FileTest.exist?(@filter_file_path) && @args == nil then
        filter = get_filter(project)
        name = filter['name']
        tags = filter['tags']
      else
        if FileTest.exist?(@filter_file_path) && @args['name'] == nil && @args['tags'] == nil then
          filter = get_filter(@project)
          name = filter['name']
          tags = filter['tags']
        else
          name = @args['name']
          tags = @args['tags']
        end
      end

      filterd_monitors = []
      begin
        @dog.get_all_monitors({:name => name, :tags => tags}).last.each do |monitor|
          export_result_display(monitor['name']) unless call_from == 'update_monitors'
          filterd_monitors << filter_monitor(monitor)
        end
      rescue => e
        puts e
      end
      return filterd_monitors
    end

    def store_monitors_data(monitors_data)
      FileUtils.mkdir_p(@project_dir) unless FileTest.exist?(@project_dir)

      unless FileTest.exist?(@filter_file_path) and @args == nil or \
        FileTest.exist?(@filter_file_path) && @args['name'] == nil && @args['tags'] == nil then
        filter = {}
        filter['name'] = @args['name']
        filter['tags'] = @args['tags']
        begin
          YAML.dump(filter, File.open(@filter_file_path, 'w'))
        rescue => e
          puts e
        end
      end

      begin
        YAML.dump(monitors_data, File.open(@monitors_file_path, 'w'))
      rescue => e
        puts e
      end
      puts 'done.'
    end
  end
end
