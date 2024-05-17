---
title: "LubuntuにTigerVNCでVNCサーバーを立てる"
date: 2024-05-17T14:48:09+09:00
categories: [日記]
draft: false
toc: false
---

余っているタブレット端末にLubuntuを突っ込み、それをキオスク端末にするのにメンテ用VNCサーバーを立てることにしました。

## インストール/動作確認

tigervnc-scraping-serverを入れないと、新規セッションでのVNCとなってしまい、メンテには適さないのでそれも突っ込んでおきます

```bash
sudo apt install tigervnc-standalone-server tigervnc-scraping-server
```

これによって、GUI上のターミナルエミュレータで以下を実行すると0.0.0.0でVNCサーバーが立ち上がります

```bash
x0vncserver -localhost no
```

SSHなどの上で実行する場合、どのディスプレイをスクレイピングするかの指定が必要です

```bash
x0vncserver -localhost no -display :0
```

## 自動起動

xprofileでやるのが一番楽なのですが、エラーがいまいちどこに出ているのかわからないので、行儀よくsystemdでやることにしました。ArchWikiに載っていたもの([TigerVNC - ArchWiki](https://wiki.archlinux.jp/index.php/TigerVNC#x0vncserver_.E3.82.92.E7.9B.B4.E6.8E.A5.E5.AE.9F.E8.A1.8C.E3.81.97.E3.81.A6.E3.83.AD.E3.83.BC.E3.82.AB.E3.83.AB.E3.83.87.E3.82.A3.E3.82.B9.E3.83.97.E3.83.AC.E3.82.A4.E3.82.92.E5.88.B6.E5.BE.A1.E3.81.99.E3.82.8B))ををコピペしたところ色々エラーが出たのでコネコネし、なんとか動くところまでもっていきました。

エラーの例 : 

 - Authorization required, but no authorization protocol specified

 - x0vncserver: The HOME environment variable must be set.

 - No display given and no DISPLAY environment variable!


```txt
[Unit]
Description=Remote desktop service (VNC)

[Service]
Type=simple
User={{ユーザー名}}
Type=forking
Requires=xdg-desktop-autostart.target
Environment=HOME=/home/{{動かしたいユーザ名}} #いらないかも
ExecStart=/usr/bin/x0vncserver -localhost no -display :0

[Install]
WantedBy=default.target
```
