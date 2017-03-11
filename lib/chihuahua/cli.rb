# coding: utf-8
require 'thor'
require 'dogapi'
require 'yaml'
require 'json'
require 'diffy'
require 'highline'

module Chihuahua
  class CLI < Thor
    default_command :version
    # class_option :api_key
    # class_option :app_key

    desc 'version', 'version 情報を出力.'
    def version
      puts VERSION
    end

    desc 'export', 'Monitor 設定を export する'
    option :project, type: :string, aliases: '-p', desc: 'Project を指定.(Project 名でディレクトリを作成する)'
    option :name, type: :string, aliases: '-n', desc: 'Monitor を name キーで絞り込む.'
    option :tags, type: :array, aliases: '-t', desc: 'Monitor を tags キーで絞り込む.'
    def export
      puts coloring.color('Export...', :green, :bold, :underline)
      export_monitors(options[:project], options[:name], options[:tags])
    end

    desc 'apply', 'Monitor 設定を apply する'
    option :project, type: :string, aliases: '-p', desc: 'Project を指定.'
    option :dry_run, type: :boolean, aliases: '-d', desc: 'apply 前の試行.'
    def apply
      if options[:dry_run] then
        puts coloring.color('Apply...(dry-run)', :green, :bold, :underline)
      else
        puts coloring.color('Apply...', :green, :bold, :underline)
      end
      update_monitors(options[:project], options[:dry_run])
    end

    desc 'init', 'Project の Root ディレクトリ(./monitors)を作成する.'
    def init
      create_project_root_dir
    end

    private

    def dog
      api_key = ENV['BARKDOG_API_KEY']
      app_key = ENV['BARKDOG_APP_KEY']
      Dogapi::Client.new(api_key, app_key)
    end

    def coloring
      HighLine.new
    end

    def create_project_root_dir
      FileUtils.mkdir_p('./monitors') unless FileTest.exist?('./monitors')
    end

    def filter_monitor(monitor)
      filter= %w[tags query type message id name options]
      filterd_monitor = monitor.select { |key, _| filter.include? key }
      return filterd_monitor
    end

    def export_monitors(project, name = nil, tags = nil)
      filterd_monitors = []
      begin
        dog.get_all_monitors({:name => name, :tags => tags}).last.each do |monitor|
          filterd_monitors << filter_monitor(monitor)
        end
      rescue => e
        puts e
      end

      project_dir = './monitors/' + project
      FileUtils.mkdir_p(project_dir) unless FileTest.exist?(project_dir)

      begin
        YAML.dump(JSON.load(filterd_monitors.to_json), File.open(project_dir + '/Monitors', 'w'))
      rescue => e
        puts e
      end
      puts filterd_monitors.length.to_s + ' monitors output done.'
    end

    def get_current_monitor(id)
      begin
        monitor = dog.get_monitor(id).last
      rescue => e
        puts e
      end
      return filter_monitor(monitor)
    end

    def update_monitors(project, dry_run)
      datas = open('./monitors/' + project + '/Monitors', 'r') { |f| YAML.load(f) }
      datas.each do |data|
        if data.has_key?('id') then
          current = YAML.dump(get_current_monitor(data['id']))
          latest = YAML.dump(data)
          diff = Diffy::Diff.new(current, latest).to_s(:color)
          if diff != "\n" then
            if dry_run != nil then
              puts coloring.color('Check update line.', :gray, :underline)
              puts diff
              puts ''
            else
              puts coloring.color('Update line.', :yellow, :underline)
              begin
                dog.update_monitor(data['id'], data['query'], :message => data['message'], :name => data['name'])
              rescue => e
                puts e
              end
              puts 'done.'
            end
          end
        else
          if dry_run == nil then
            puts coloring.color('Add line.', :yellow, :underline)
            begin
              dog.monitor(data['type'], data['query'], :message => data['message'], :name => data['name'])
            rescue => e
              puts e
            end
            puts 'done.'
          else
            puts coloring.color('Check add line.', :gray, :underline)
            puts coloring.color(YAML.dump(data), :light_cyan)
            puts ''
          end
        end
      end
    end

  end
end
