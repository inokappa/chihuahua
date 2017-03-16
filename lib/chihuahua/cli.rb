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
      puts Chihuahua::VERSION
    end

    desc 'export', 'Monitors 定義を export する'
    option :project, type: :string, aliases: '-p', desc: 'Project を指定.(Project 名でディレクトリを作成する)'
    option :name, type: :string, aliases: '-n', desc: 'Monitor を name キーで絞り込む.'
    option :tags, type: :array, aliases: '-t', desc: 'Monitor を tags キーで絞り込む.'
    def export
      unless options[:project] then
        puts 'Project 名がセットされていません. (--project xxxxxx)'
        exit 1
      end

      puts 'Export...'
      # exporter = Chihuahua::Export.new(options[:project])
      args = {}
      args['name'] = options[:name]
      args['tags'] = options[:tags]
      p args.class
      exporter = Chihuahua::Export.new(options[:project], args)
      monitors_data = exporter.export_monitors(options[:project])
      exporter.store_monitors_data(monitors_data)
    end
#
    desc 'apply', 'Monitors 定義を apply する'
    option :project, type: :string, aliases: '-p', desc: 'Project を指定.'
    option :dry_run, type: :boolean, aliases: '-d', desc: 'apply 前の試行.'
    def apply
      if options[:dry_run] then
        puts 'Apply...(dry-run)'
      else
        puts 'Apply...'
      end
      updater = Chihuahua::Update.new(options[:project])
      updater.update_monitors(options[:dry_run])
    end

    desc 'generate', 'Monitors 定義の雛形を生成する.'
    option :project, type: :string, aliases: '-p', desc: 'Project を指定.'
    def generate
      #
    end

    desc 'init', 'Project の Root ディレクトリ(./monitors)を作成する.'
    def init
      Chihuahua::Helper.create_project_root_dir
    end

  end
end
