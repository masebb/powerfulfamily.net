---
title: "k8sクラスタ内でで内向きドメインを名前解決したい"
date: 2023-03-11T01:19:21+09:00
categories: [k8s]
#公開時はdraftをfalseに!!!!!!!!!!!!
draft: false
toc: true
---
k8sで自宅サーバの監視スタックを構築しているのですが、自宅に設置してある内向けDNSサーバで管理しているドメイン名を使いたいので上手いことしなければなりません。

podのDNS設定(DNSConfig)からやっても同じことですが、pod毎にやらないといけないので面倒+helmでデプロイするやつに適応するの面倒ということでk8sクラスタ全体で名前解決を担っているCoreDNSに内部ドメイン(LAN内ドメイン?)の問い合わせが来た際には内向きDNSに飛ばしてもらうということをやってもらう設定をします。動くというだけで正確性は保証しません

### 環境
```bash
$ kubectl version --short
Client Version: v1.26.1
Kustomize Version: v4.5.7
Server Version: v1.26.1
```
### 設定
このコマンドでcoreDNSのConfigMapを開く(うちの環境ではviで開いた)
```bash
kubectl edit configmap coredns -n kube-system
```
```yaml
#省略
apiVersion: v1
data:
  Corefile: |
    .:53 {
        errors
        health {
        #...省略
        cache 30
        loop
        reload
        loadbalance
    }
+    example.com {
+      forward . 10.0.0.1
+    }
```
こんな感じに書けばうまいこと行きます

あとはcoreDNSを再起動かければ終了です

```bash
kubectl rollout restart deployment/coredns -n kube-system
```