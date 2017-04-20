# coding: utf-8
module Chihuahua
  class Update

    include Chihuahua::Helper

    def initialize(project)
      @dog = Chihuahua::Client.new.dog
      @exporter = Chihuahua::Export.new(project)
      @project = project
      @project_dir = './monitors/' + @project
      @monitors_file_path = @project_dir + '/monitors.yml'
      @filter_file_path = @project_dir + '/.filter.yml'
    end

    def apply_result_display(res)
      result = res.last
      puts hl.color(result['name'], :light_cyan) + ' applying...' unless result.nil?
      puts 'applying...'
    end

    def update_monitor(data)
      puts hl.color('Update line.', :yellow, :underline)
      begin
        res = @dog.update_monitor(data['id'], data['query'], :message => data['message'], :name => data['name'], :options => data['options'])
      rescue => e
        puts e
      end
      apply_result_display(res)
    end

    def create_monitor(data)
      puts hl.color('Add line.', :yellow, :underline)
      begin
        res = @dog.monitor(data['type'], data['query'], :message => data['message'], :name => data['name'], :options => data['options'])
      rescue => e
        puts e
      end
      apply_result_display(res)
    end

    def update_monitors(dry_run)
      filter = get_filter(@project)
      # current_monitors = @exporter.export_monitors(filter['name'], filter['tags']) { |f| YAML.load(f) }
      current_monitors = @exporter.export_monitors(@project) { |f| YAML.load(f) }
      datas = open(@monitors_file_path) { |f| YAML.load(f) }
      apply_flag = []
      datas.each do |data|
        # 新規登録 or 更新のチェック(id キーが有れば更新)
        if data.has_key?('id') then
          current_monitor = YAML.dump(current_monitors.select {|m| m['id'] == data['id']}.last)
          latest_monitor = YAML.dump(data)
          diff = Diffy::Diff.new(current_monitor, latest_monitor).to_s(:color)
          # 差分の有無をチェック(diff != "\n" であれば差分が有ると判断)
          if diff != "\n" then
            # --dry-run フラグのチェック
            if dry_run then
              puts hl.color('Check update line.', :gray, :underline)
              puts diff
              puts ''
            else
              update_monitor(data)
              apply_flag << '1'
            end
          end
        else
          # 新規登録
          # --dry-run フラグのチェック
          if dry_run == nil then
            create_monitor(data)
            apply_flag << '1'
          else
            puts hl.color('Check add line.', :gray, :underline)
            puts hl.color(YAML.dump(data), :light_cyan)
            puts ''
          end
        end
      end
      unless dry_run or apply_flag.empty? then
        monitors_data = @exporter.export_monitors(@project)
        @exporter.store_monitors_data(monitors_data)
      end
      puts 'done.'
    end

  end
end
