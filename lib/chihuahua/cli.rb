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
      monitors_data = export_monitors(options[:name], options[:tags])
      store_monitors_data(monitors_data, options[:project], options[:name], options[:tags])
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
      api_key = ENV['DATADOG_API_KEY']
      app_key = ENV['DATADOG_APP_KEY']
      Dogapi::Client.new(api_key, app_key)
    end

    def coloring
      HighLine.new
    end

    def create_project_root_dir
      FileUtils.mkdir_p('./monitors') unless FileTest.exist?('./monitors')
      puts 'done.'
    end

    def filter_monitor(monitor)
      filter= %w[tags query type message id name options]
      filterd_monitor = monitor.select { |key, _| filter.include? key }
      return filterd_monitor
    end

    def store_monitors_data(monitors_data, project, name, tags)
      project_dir = './monitors/' + project
      FileUtils.mkdir_p(project_dir) unless FileTest.exist?(project_dir)

      filter = {}
      filter['name'] = name
      filter['tags'] = tags
      begin
        # YAML.dump(JSON.load(filter.to_json), File.open(project_dir + '/.filter.yml', 'w'))
        YAML.dump(filter, File.open(project_dir + '/.filter.yml', 'w'))
      rescue => e
        puts e
      end

      begin
        # YAML.dump(JSON.load(monitors_data.to_json), File.open(project_dir + '/monitors.yml', 'w'))
        YAML.dump(monitors_data, File.open(project_dir + '/monitors.yml', 'w'))
      rescue => e
        puts e
      end
      puts monitors_data.length.to_s + ' monitors output done.'
    end

    def export_monitors(name = nil, tags = nil)
      filterd_monitors = []
      begin
        dog.get_all_monitors({:name => name, :tags => tags}).last.each do |monitor|
          filterd_monitors << filter_monitor(monitor)
        end
      rescue => e
        puts e
      end
      return filterd_monitors
    end

    def get_filter(project)
      filter = open('./monitors/' + project + '/.filter.yml', 'r') { |f| YAML.load(f) }
      return filter
    end

    def update_monitors(project, dry_run)
      filter = get_filter(project)
      current_monitors = export_monitors(filter['name'], filter['tags']) { |f| YAML.load(f) }
      datas = open('./monitors/' + project + '/monitors.yml', 'r') { |f| YAML.load(f) }
      datas.each do |data|
        # 新規登録 or 更新のチェック(id キーが有れば更新)
        if data.has_key?('id') then
          current_monitor = YAML.dump(current_monitors.select {|m| m['id'] == data['id']}.last)
          latest_monitor = YAML.dump(data)
          diff = Diffy::Diff.new(current_monitor, latest_monitor).to_s(:color)
          # 差分の有無をチェック(diff != "\n" であれば差分が有ると判断)
          if diff != "\n" then
            # --dry-run フラグのチェック
            if dry_run != nil then
              puts coloring.color('Check update line.', :gray, :underline)
              puts diff
              puts ''
            else
              puts coloring.color('Update line.', :yellow, :underline)
              begin
                res = dog.update_monitor(data['id'], data['query'], :message => data['message'], :name => data['name'], :options => data['options'])
              rescue => e
                puts e
              end
              puts coloring.color(res.last.to_s, :light_cyan)
            end
          end
        else
          # 新規登録
          # --dry-run フラグのチェック
          if dry_run == nil then
            puts coloring.color('Add line.', :yellow, :underline)
            begin
              res = dog.monitor(data['type'], data['query'], :message => data['message'], :name => data['name'], :options => data['options'])
            rescue => e
              puts e
            end
            puts coloring.color(res.last.to_s, :light_cyan)
          else
            puts coloring.color('Check add line.', :gray, :underline)
            puts coloring.color(YAML.dump(data), :light_cyan)
            puts ''
          end
        end
      end
      puts 'done.'
    end

  end
end
