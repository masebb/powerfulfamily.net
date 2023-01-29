---
title: "Ubuntuたまに使う標準コマンド"
date: 2022-12-25T01:24:04+09:00
lastmod: 2023-01-24
draft: false
toc: true
categories: [メモ]
---
大体のコマンドはUbuntu 22.04 LTSで動かしています

メモなのでコマンドの利用方法を網羅しているものではありません

使いそうなコマンド順に適当に並べています

### ディレクトリ以下に入っているすべてのファイルの容量を表示する
```bash
 du -sh ${DIR}
```
sオプションを外せばtreeをaptで入れなくても網羅的にディレクトリ以下の全ファイルを見れる
### tar解凍
```bash
tar -xvf ${FILE}
```
### ユーザをグループに追加
```bash
 usermod -aG ${GROUP_NAME} ${USER_NAME}
```

セッションを再度張り直さないと適用されないので注意

### ユーザー名変更
クラウド上のVMでやる場合はssh等でやるとユーザプロセスが立ってしまうのでssh等で入らない(Web上とかから入る)

コンソールで入る際もrootで入る(事前にrootのパスワードを決めておく)

**ユーザー名が変わってもsudoersなどは変わってくれないので注意**(NOPASSWDにしたはずなのにパスワードが要求されるようになったりする)

```bash
#SSH等で接続
#rootのパスワード変更
sudo passwd root

#コンソール等で接続
#============ROOT===========
#ユーザー名変更
usermod -l ${NEW_USERNAME} ${OLD_USERNAME}
#ユーザーディレクトリ変更
usermod -d /home/${NEW_USERNAME} -m ${NEW_USERNAME}
#コメントを変更(オプション)
usermod -c ${NEW_USERNAME} ${NEW_USERNAME}
#確認
cat /etc/passwd
#=========END ROOT===========

#SSH等で接続
#rootのパスワードを無効化
#sudoersの変更を失念している可能性があるので必ず変更したユーザーの上でやること！
#横着してコンソール上のrootでやるな！(1敗)
sudo passwd -l root
```