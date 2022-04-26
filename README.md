# nippo

Googleカレンダーから情報を取得し、以下のような日報を生成するRuby製コマンドラインツールです

```
# 本日の業務

* [MTG] 朝会
* [MTG] 開発定例
* [MTG] 1 on 1
* 機能Aのテストコード

# 明日の予定

* [MTG] 朝会
* [MTG] 1 on 1
* 機能B実装

# 一言

弱い者ほど相手を許すことができない。許すということは、強さの証だ。
```

# 使い方

* [Google Calendar APIのクイックスタートの記事](https://developers.google.com/calendar/quickstart/ruby) の `Step 1` を参考に、このリポジトリ内に `credentials.json` を作成
* `make`
* `make init`
  - `.settings.yml` が作られるので、ファイルの中の例に従って `calendar_id` を更新してください
* `./nippo.rb`
  - 初回だけキー作成を行う必要があるので、案内に従って作成（ `token.yaml` が作られます）

# 参考
このツールの作成記です
[Googleカレンダーと連携した日報生成ツールをRubyで作る - Qiita](https://qiita.com/nakahashi/items/ecb55867998e74bdbfd0)
