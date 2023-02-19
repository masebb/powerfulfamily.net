---
title: "パナソニック製PoEスイッチを購入"
date: 2023-02-11T08:54:16+09:00
categories: [自宅サーバー]
#公開時はdraftをfalseに!!!!!!!!!!!!
draft: false
toc: true
---
## 環境
- 製品名 GA-ML12THPoE+
- ファームウェアバージョン V2.0.0.01 (後にFWバージョンV3.0.0.06に上げますが、設定内容は変わらないものと思われます)

定価19万円の現行機種?が運良く安く手に入ったので設定をしていこうと思ったのですが、思ったより情報が少なかったのでここに色々メモって行こうと思います。

![設置されたGA-ML12THPoE+](/images/panasonic-poe-switch-first-config/placed.jpg)
(設置されたGA-ML12THPoE+とスマホスタンドにくくりつけられるArubaの無線APくん)
## 参考になるマニュアル

- [[pdf]CLIリファレンス](https://panasonic.co.jp/ew/pewnw/ns/mno/pdf/pn26xx9x_exp_cli.pdf)
- [[pdf]WebGUIリファレンス](https://panasonic.co.jp/ew/pewnw/ns/mno/pdf/pn26xx9x_exp_web.pdf)
- [GA-MLシリーズ設定例](https://panasonic.co.jp/ew/pewnw/f/inquiry/setting/index_gamllist.html)

## よく使うコマンド
### 設定を保存
```md
copy running-config startup-config
```
### 稼働中の設定を表示
```md
show running-config
```
### コンフィグモード中に特権モードのコマンドを実行する
```md
do show running-config
```
### インターフェース指定
```md
interface GigabitEthernet インターフェースユニットID/オープンスロットID/ポートID
!省略形
interface giインターフェースユニットID/オープンスロットID/ポートID
!範囲指定
interface range giインターフェースユニットID/オープンスロットID/ポートID始-ポートID終
```
以下はマニュアルをめちゃ適当解釈 :
- インターフェースユニットID : スタックID
- オープンスロットID : スロットにに刺した拡張ボードのID
- ポートID : ポート番号

なお、自分が利用する機種にはスタック機能はなく、スロットなんてものもないのでインターフェースユニットIDは常に1でオープンスロットIDも常に0という形になりますので、ポートIDだけが変数という形になります

## 設定

### ファンの回転数を変更
```md
!最低に変更
fanspeed min
```
### ユーザー設定
```md
!ユーザ作成
username ユーザー名 password パスワード
!一番偉くする
username ユーザー名 privilege 15
!危ないのでパスワードをハッシュ化
service user-account encryption
```
### VLAN設定
機器管理用のVLANを設定します
```md
!範囲指定,複数指定可能
vlan VLAN番号始まり-終わり,次のVLAN番号
```
### IPアドレス付与
自身は機器管理をするセグメントをデフォルトVLAN(vlan1)に割り当てていないので、別のVLANをinterfaceとして設定し、そこにIPを設定する必要があります。その場合、一度vlan1インターフェースを削除して別のvlanインターフェースを作るという作業が必要みたいです。

```md
no interface vlan1
interface vlan[VLAN番号]
ip address IPアドレス マスク
```

### トランクポートの設定(タグVLANを食わせる)
(めちゃくちゃ適当です。どれぐらい適当かというと、必要そうな設定をコマンドリファレンス斜め読みして適当につっこんで通信てきたらOKぐらいのノリです)
```md
switchport mode trunk
switchport trunk native vlan tag
switchport trunk allowed vlan add VLAN番号
!範囲指定,複数指定も可能
switchport trunk allowed vlan add VLAN番号始まり-終わり,次のVLAN番号
!おかしなVLAN番号の通信をDrop
acceptable-frame tagged-only
```

それをしていない場合、`ERROR: Table full.`と表示され、vlanインターフェースが追加できません
### sshの設定
```md
ip ssh server
ssh user ユーザー名 authentication-method password
```

公開鍵認証もできそうな感じですがめんどくさいので...
## ファームウェアアップデート
WebGUIが~~NEC IXシリーズとは違い~~便利そうなので、使ってみようと`ip http server`とやりましたが ~~、なぜかスイッチのIPアドレスにアクセスしたら、login.htmlにリダイレクトされ、404 NotFoundと書かれたものが帰ってくるだけで、再起動かけても直らなかったのでファームアプデします。(この時気づいたのですが、V2.0.0.01ってもしかして一番最初のリリースなのかも...)~~

**Webサーバはファームウエアのバージョンが3.0.0.00以上で対応**だそうです。なのでファームウェアを上げないと使えないみたいです。どうして非対応バージョンなのに`ip http server`打てたんだ...

ファームウェアとか気にせず買っていましたが、Panasonicはファームウェアは無償公開のようです!無償公開ありがとう〜〜〜〜

[設定例](https://panasonic.co.jp/ew/pewnw/f/inquiry/setting/gaml_setting30.html)にしたがってtftpでファームウェアをダウンロードし、アップデートします

...と行きたかったところですが、問題が発生しました
```md
 Transmission start...

 ERROR: TFTP Connection Failed.
```
と一定時間経つと表示され、ファームウェアのTFTP転送が必ず失敗するということになりました。この問題はどうやらTFTPサーバーで定番のWindowsソフト、[Tftpd64](https://pjo2.github.io/tftpd64/)を使うと発生するようで、Ubuntu上でtftpサーバー(今回は手軽に動かしたかったのでDockerイメージになってるtftpサーバーの[pghalliday/tftp](https://hub.docker.com/r/pghalliday/tftp)を使う)を動かしたら普通に転送されました。詳細不明です...
