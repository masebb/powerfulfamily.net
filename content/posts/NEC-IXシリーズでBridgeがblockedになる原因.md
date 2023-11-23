---
title: "NEC IXシリーズでBridgeがblockedになる原因"
date: 2023-08-21T22:41:14+09:00
categories: [日記]
draft: false
toc: false
---
blocked状態だと、その名の通り、RX/TXが一切できない

公式ドキュメントにはblocked状態がいったい何なのか、ということについて一切何も書いていないんですよね。いつも引っかかっているので、大体の要因をメモ書き

![](/images/NEC-IXシリーズでBridgeがblockedになる原因/bridge-blocked.jpg)

- `bridge irb enable`の入れ忘れ
- ポートがshutdown状態の場合
