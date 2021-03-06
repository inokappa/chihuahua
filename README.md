# Chihuahua

![chihuahua](https://raw.githubusercontent.com/inokappa/chihuahua/master/images/chihuahua.png)

Chihuahua は [Datadog monitors](http://docs.datadoghq.com/guides/monitoring/) を管理するツールです.

## Caution

* Datadog monitors を YAML DSL で管理してみる試みです
* Monitor Name や Monitor Tags で絞り込んで任意の Monitor のみ抽出して管理出来る筈です
* 基本的には [codenize-tools/barkdog](https://github.com/codenize-tools/barkdog) を使いましょう

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'chihuahua'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install chihuahua
```


## Usage

```sh
export DATADOG_API_KEY=...
export DATADOG_APP_KEY=...

bundle exec chihuahua init
bundle exec chihuahua export --project=your_project_name --tags=project:foo,stage:production --dry-run
bundle exec chihuahua export --project=your_project_name --tags=project:foo,stage:production
vi ./monitors/your_project_name/monitors.yml
bundle exec chihuahua apply --project=your_project_name --dry-run
bundle exec chihuahua apply --project=your_project_name
```

## Help

```
$ bundle exec chihuahua --help
Commands:
  chihuahua apply           # Monitor 設定を apply する
  chihuahua export          # Monitor 設定を export する
  chihuahua help [COMMAND]  # Describe available commands or one specific command
  chihuahua init            # Project の Root ディレクトリ(./monitors)を作成する.
  chihuahua version         # version 情報を出力.
```

## Chihuahua example

### 書き出し

```sh
#
# 初回の書き出し
#
$ bundle exec chihuahua export --project=foo --tags=host:vagrant-ubuntu-trusty-64
Export...
4 monitors output done.

$ tree -a monitors/
monitors/
└── foo
    ├── .filter.yml
    └── monitors.yml

1 directory, 2 files

#
# 2 回目以降、絞込の条件（--name や --tags に変更が無い場合）
#
$ bundle exec chihuahua export --project=foo

```



### 新規作成

- YAML 定義を ./monitors/your_project_name/monitors.yml に追記

```yaml
- query: avg(last_1m):avg:system.load.5{host:vagrant-ubuntu-trusty-64} > 1
  message: |-
    CPU load is very high on {{host.name}}
    @slack-datadog-notification
  name: Test 5 [{{#is_alert}}CRITICAL{{/is_alert}}{{#is_warning}}WARNING{{/is_warning}}]
    CPU load is very high on {{host.name}}
  type: metric alert
  options:
    thresholds:
      critical: 1.0
      warning: 0.8
```

詳細は http://docs.datadoghq.com/ja/api/?lang=ruby#monitor-create を御確認ください.

- dry-run

```sh
$ bundle exec chihuahua apply --project=foo --dry-run
Apply...(dry-run)
Check add line.
---
query: avg(last_1m):avg:system.load.5{host:vagrant-ubuntu-trusty-64} > 1
message: |-
  CPU load is very high on {{host.name}}
  @slack-datadog-notification
name: Test 5 [{{#is_alert}}CRITICAL{{/is_alert}}{{#is_warning}}WARNING{{/is_warning}}]
  CPU load is very high on {{host.name}}
type: metric alert
options:
  thresholds:
    critical: 1.0
    warning: 0.8
```

- apply

```sh
$ bundle exec chihuahua apply --project=foo
Apply...
Add line.
...
... Latest Monitors List ...
...
done.
```

### 更新

- thresholds を追記

```yaml
- tags: []
  query: avg(last_1m):avg:system.load.5{host:vagrant-ubuntu-trusty-64} > 1
  message: |-
    CPU load is very high on {{host.name}}
    @slack-datadog-notification
  id: 12345678
  name: Test3 [{{#is_alert}}CRITICAL{{/is_alert}}{{#is_warning}}WARNING{{/is_warning}}]
    CPU load is very high on {{host.name}}
  type: metric alert
  options:
    notify_audit: false
    locked: false
    silenced: {}
    new_host_delay: 300
    require_full_window: true
    notify_no_data: false
    thresholds:
      critical: 1.0
      warning: 0.8
```

詳細は http://docs.datadoghq.com/ja/api/?lang=ruby#monitor-edit を御確認ください.

- dry-run

```sh
$ bundle exec chihuahua apply --project=foo --dry-run
Apply...(dry-run)
Check update line.
 ---
 tags: []
 query: avg(last_1m):avg:system.load.5{host:vagrant-ubuntu-trusty-64} > 1
 message: |-
   CPU load is very high on {{host.name}}
   @slack-datadog-notification
 id: 12345678
 name: Test3 [{{#is_alert}}CRITICAL{{/is_alert}}{{#is_warning}}WARNING{{/is_warning}}]
   CPU load is very high on {{host.name}}
 type: metric alert
 options:
   notify_audit: false
   locked: false
   silenced: {}
   new_host_delay: 300
   require_full_window: true
   notify_no_data: false
+  thresholds:
+    critical: 1.0
+    warning: 0.8
```

- apply

```sh
$ bundle exec chihuahua apply --project=foo
Apply...
Update line.
...
... Latest Monitors List ...
...
done.
```
