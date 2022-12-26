---
title: "Docker-Compose早見表"
date: 2022-12-25T01:24:03+09:00
draft: false
categories: [メモ]
---

```yaml
services:
  ${サービス名}:
    image: ${イメージ名}
    #コンテナ名はコンテナ間通信したいときとかに便利
    container_name: ${コンテナ名}
    #no/on-failure/always/unless-stopped
    restart: always
    #yes/no 参考 : [DockerのTTYって何?](https://zenn.dev/hohner/articles/43a0da20181d34)
    tty: yes
    ports:
      - ${ホスト側}:${コンテナ側}
    #依存関係にあるコンテナ(DB等)が起動してから起動するように
    depends_on:
      - ${コンテナ名}
    enviroment:
      ${環境変数名}: ${値}
    volumes:
      #volume/bind/tmpfs/npipe(通常はbind?)
      - type: bind
        source: ${ホスト側ディレクトリ}
        target: ${コンテナ側ディレクトリ}
    networks:
      - ${ネットワーク名}
      - default
networks:
  #任意のネットワークの作成
  ${ネットワーク名}:

  #デフォルトで作成されるネットワークの各種設定(ここではmtuの設定をしている)
  default:
    driver_opts:
      com.docker.network.driver.mtu: ${MTU値}
```

## メモ
- versionは非推奨らしい(常に最新の書き方に追従すべきだから)
- volumesは`Long syntax`のほうが安全(短いやつ(`${ホスト側ディレクトリ}:${コンテナ側ディレクトリ}`)だとホスト側にディレクトリがない場合勝手に作ってしまうため、パスの設定を間違っているとドツボにはまる)