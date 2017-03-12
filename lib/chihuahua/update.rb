# coding: utf-8
module Chihuahua
  class Update

    include Chihuahua::Helper

    def initialize
      @dog = Chihuahua::Client.new.dog
      @exporter = Chihuahua::Export.new
    end

    def update_monitor(data)
      puts hl.color('Update line.', :yellow, :underline)
      begin
        res = @dog.update_monitor(data['id'], data['query'], :message => data['message'], :name => data['name'], :options => data['options'])
      rescue => e
        puts e
      end
      puts hl.color(res.last.to_s, :light_cyan)
    end

    def create_monitor
      puts hl.color('Add line.', :yellow, :underline)
      begin
        res = @dog.monitor(data['type'], data['query'], :message => data['message'], :name => data['name'], :options => data['options'])
      rescue => e
        puts e
      end
      puts hl.color(res.last.to_s, :light_cyan)
    end

    def update_monitors(project, dry_run)
      filter = get_filter(project)
      current_monitors = @exporter.export_monitors(filter['name'], filter['tags']) { |f| YAML.load(f) }
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
              puts hl.color('Check update line.', :gray, :underline)
              puts diff
              puts ''
            else
              update_monitor(data)
            end
          end
        else
          # 新規登録
          # --dry-run フラグのチェック
          if dry_run == nil then
            create_monitor(data)
          else
            puts hl.color('Check add line.', :gray, :underline)
            puts hl.color(YAML.dump(data), :light_cyan)
            puts ''
          end
        end
      end
      puts 'done.'
    end

  end
end
