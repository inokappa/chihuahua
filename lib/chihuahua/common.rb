# coding: utf-8
module Chihuahua
  class Common

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

  end
end
