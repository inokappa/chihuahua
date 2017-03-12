# coding: utf-8
module Chihuahua
  module Helper
    def create_project_root_dir
      FileUtils.mkdir_p('./monitors') unless FileTest.exist?('./monitors')
      puts 'done.'
    end

    def filter_monitor(monitor)
      filter = %w[tags query type message id name options]
      filterd_monitor = monitor.select { |key, _| filter.include? key }
      return filterd_monitor
    end

    def get_filter(project)
      filter = open('./monitors/' + project + '/.filter.yml', 'r') { |f| YAML.load(f) }
      return filter
    end

    def hl
      HighLine.new
    end

    module_function :create_project_root_dir
    module_function :filter_monitor
    module_function :get_filter
    module_function :hl
  end
end
