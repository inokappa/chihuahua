# coding: utf-8
module Chihuahua
  class Update

    def initialize
      @dog = Chihuahua::Client.new.dog
      @exporter = Chihuahua::Export.new
      @common = Chihuahua::Common.new
    end

    def update_monitors(project, dry_run)
      filter = @common.get_filter(project)
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
              puts @common.hl.color('Check update line.', :gray, :underline)
              puts diff
              puts ''
            else
              puts @common.hl.color('Update line.', :yellow, :underline)
              begin
                res = @dog.update_monitor(data['id'], data['query'], :message => data['message'], :name => data['name'], :options => data['options'])
              rescue => e
                puts e
              end
              puts @common.hl.color(res.last.to_s, :light_cyan)
            end
          end
        else
          # 新規登録
          # --dry-run フラグのチェック
          if dry_run == nil then
            puts @common.hl.color('Add line.', :yellow, :underline)
            begin
              res = @dog.monitor(data['type'], data['query'], :message => data['message'], :name => data['name'], :options => data['options'])
            rescue => e
              puts e
            end
            puts @common.hl.color(res.last.to_s, :light_cyan)
          else
            puts @common.hl.color('Check add line.', :gray, :underline)
            puts @common.hl.color(YAML.dump(data), :light_cyan)
            puts ''
          end
        end
      end
      puts 'done.'
    end

  end
end
