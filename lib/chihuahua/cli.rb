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

    desc 'export', 'Monitor 設定を export する'
    option :project, type: :string, aliases: '-p', desc: 'Project を指定.(Project 名でディレクトリを作成する)'
    option :name, type: :string, aliases: '-n', desc: 'Monitor を name キーで絞り込む.'
    option :tags, type: :array, aliases: '-t', desc: 'Monitor を tags キーで絞り込む.'
    def export
      puts 'Export...'
      exporter = Chihuahua::Export.new
      monitors_data = exporter.export_monitors(options[:name], options[:tags])
      exporter.store_monitors_data(monitors_data, options[:project], options[:name], options[:tags])
    end
#
    desc 'apply', 'Monitor 設定を apply する'
    option :project, type: :string, aliases: '-p', desc: 'Project を指定.'
    option :dry_run, type: :boolean, aliases: '-d', desc: 'apply 前の試行.'
    def apply
      if options[:dry_run] then
        puts 'Apply...(dry-run)'
      else
        puts 'Apply...'
      end
      updater = Chihuahua::Update.new
      updater.update_monitors(options[:project], options[:dry_run])
    end

    desc 'init', 'Project の Root ディレクトリ(./monitors)を作成する.'
    def init
      Chihuahua::Common.new.create_project_root_dir
    end

  end
end
