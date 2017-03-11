# Chihuahua

![chihuahua](https://raw.githubusercontent.com/inokappa/chihuahua/master/images/chihuahua.png)

Chihuahua は [Datadog monitors](http://docs.datadoghq.com/guides/monitoring/) を管理するツールです.

## Caution

* Datadog monitors を YAML DSL で管理してみる試みです
* Monitor Name や Monitor Tags で絞り込んで任意の Monitor のみ抽出して管理出来る筈です
* 基本的には [codenize-tools/barkdog](https://github.com/codenize-tools/barkdog) を使いましょう

## Installation

```sh
git clone ...
cd chihuahua
bundle install --path vendor/bundle
```

## Usage

```sh
export BARKDOG_API_KEY=...
export BARKDOG_APP_KEY=...

bundle exec ./bin/chihuahua init
bundle exec ./bin/chihuahua export --project=your_project_name --tags=project:foo,stage:production
vi ./monitors/your_project_name/Monitors
bundle exec ./bin/chihuahua apply --project=your_project_name --dry-run
bundle exec ./bin/chihuahua apply --project=your_project_name
```

## Help

```
$ bundle exec ./bin/chihuahua --help
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
$ bundle exec ./bin/chihuahua export --project=foo --tags=host:vagrant-ubuntu-trusty-64
Export...
4 monitors output done.

$ tree monitors/
monitors/
└── foo
    └── Monitors

1 directory, 1 file
```

### 新規作成

- YAML 定義を ./monitors/your_project_name/Monitors に追記

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

- dry-run

```sh
$ bundle exec ./bin/chihuahua apply --project=foo --dry-run
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
$ bundle exec ./bin/chihuahua apply --project=foo
Apply...
Add line.
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

- dry-run

```sh
$ bundle exec ./bin/chihuahua apply --project=foo --dry-run
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
$ bundle exec ./bin/chihuahua apply --project=foo
Apply...
Update line.
done.
```
