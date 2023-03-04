---
title: "PowerDNSとPowerDNS-AdminでGUIで操作できるいい感じの内部用DNSサーバーを建てる"
date: 2023-03-04T00:54:13+09:00
categories: [自宅サーバー]
#公開時はdraftをfalseに!!!!!!!!!!!!
draft: false
toc: true
---
## 環境

Ubuntu 20.04.5 LTS

## 前準備
### systemd-resolvedが53番ポートをListenするのをやめさせる
今回はDNSサーバーを53番ポートで立てたいのですが、Ubuntuの場合53番はデフォルトでは既に使用されているため、競合が発生しそのままサーバーを立ててれません

`/etc/systemd/resolved.conf` の`DNSStubListener`をデフォルトの`yes`から`no`に変えてあげることで127.0.0.53:53をLISTENさせるのをやめさせることができます。

ですが、これを無効化しても全アプリケーションは127.0.0.53:53を見に行くままなのでもちろん名前解決ができなくなります。

なのでnetplanに書いたDNSサーバーに直でアクセスしてもらうために下のようなコマンドを打ち、シンボリックリンクを貼ってnetplanに書いた情報を見に行ってもらいます
```bash
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
```

## docker-compose.yamlを書く
```yaml
services:
  powerdns-auth:
    image: powerdns/pdns-auth-47:4.7.3
    container_name: powerdns_auth
    environment:
      - PDNS_AUTH_API_KEY=適当に生成したキー
    ports:
      - "53:53"
      - "53:53/udp"
    volumes:
      - type: bind
        source: pdns-auth-data/
        target: /var/lib/powerdns/
    restart: always
  powerdns-admin:
    image: powerdnsadmin/pda-legacy:v0.3.0
    container_name: powerdns_admin
    ports:
      - "9191:80"
    environment:
      - SECRET_KEY=上記のキーと同じもの
    volumes:
      - type: bind
        source: pda-data/
        target: /data
    restart: always
```
これを`docker-compose up -d`すれば完成です。サーバアドレス:9191にブラウザでアクセスすればPowerDNS-Adminにアクセスできます
### docker-composeの例示、詳細のリンク
- https://github.com/PowerDNS/pdns/

PowerDNSをDockerで扱う方法がDocker-README.mdに、docker-compose.yamlファイルにdocker-composeでの例示があります

- https://github.com/PowerDNS-Admin/PowerDNS-Admin

PowerDNS-AdminでのDockerでの使い方がReadme.mdに、docker-compose.yamlファイルにdocker-composeでの例示があります

## 参考
- [How to correctly disable systemd-resolved on port 53 for avoiding clash with dnsmasq in Ubuntu 20.04…? - Unix & Linux Stack Exchange](https://unix.stackexchange.com/questions/615819/how-to-correctly-disable-systemd-resolved-on-port-53-for-avoiding-clash-with-dns)
- [Ubuntu 18.04 の systemd-resolved で local DNS stub listener の利用をやめる](https://qiita.com/shora_kujira16/items/31d09b373809a5a44ae5)