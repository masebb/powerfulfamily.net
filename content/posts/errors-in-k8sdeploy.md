---
title: "Kubernatesデプロイでハマった！"
date: 2023-01-30T17:54:28+09:00
categories: [k8s]
#公開時はdraftをfalseに!!!!!!!!!!!!
draft: false
toc: true
---

Kubernates(k8s)に入門してみようということで、Oracle Cloud上のAlwaysFreeリソースにある監視基盤をk8sの上に載せようと思い立ち、今ある監視基盤を破壊し、VMを分けてkubeadmで順調にインストールして1,2日で復旧できるだろ...と思っていた時期が私にもありました。

### 日本語の公式ドキュメントは見ない
kubernatesの公式ドキュメントには様々な言語の種類があるようですが、[少なくとも日本語のドキュメント](https://kubernetes.io/ja/docs/home/)は英語版最新バージョンに沿った翻訳はされておらず、ところどころ古い内容があるので、基本的に英語版を参照するようにしたほうがいいかと思います

### デプロイ時に参照するドキュメント
ここでのデプロイとは、Ubuntu22.04上でのkubeadmを用いた典型的なk8sクラスターのデプロイです

- kubeadmやその他ツールのインストール : [Installing kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
- containerdのインストール時のレポジトリ情報(Dockerのレポジトリを入れるのでDockerのサイトです) : [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
- 諸々のホストOSの設定(地味に重要。必ずすべて読む) : [Container Runtimes](https://kubernetes.io/docs/setup/production-environment/container-runtimes/)
- クラスタの作成 : [Creating a cluster with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)

~~(もう少し一つにまとめてくれないかな〜)~~

### なぜかデプロイできなかった
kube-apiserverポッドが何故か再起動しまくり(CrashLoopBackoff状態)、その他podもCrashLoopBackoff状態になりました

kube-apiserverがないともちろんクラスター間などもできないのでエラー出まくりでkubectl等の各ツールも`Connection refused`で使えない状態になってしまうといった状況でした

結果としてこれの原因はContainerdの設定ミス(設定無しで行けると思っていた)でした。上記にもある[Container Runtimes](https://kubernetes.io/docs/setup/)に書いてあるCgroup driversの設定を関係ないものだと思い、していませんでした

どうやら`/etc/containerd/config.toml`を色々いじる必要があるそうです。aptでcontainerd.ioを取得すると、初期コンフィグは色々省略されているみたいなので下記コマンドでcontainerdのデフォルトコンフィグに書き換えます
```bash
 containerd config default | sudo tee /etc/containerd/config.toml
```
その後に、再度コンフィグを開いて `SystemdCgroup = False`と書いてある所を`True`に置き換え、containerdデーモンを再起動します

これで自分は解決しました(ドキュメントに書いてあることです...自分は[Radditのスレッド](https://www.reddit.com/r/kubernetes/comments/wor4kb/k8s_on_debian_bullseye_all_control_plane/)でここをいじらないといけないことを知りました)

### kube-apiserverが使えないときのデバッグ
kube-apiserverがCrashBackLoopoff状態に陥っているときは、kubectlなんてもちろん使えません。なのでpodのログを見ることすら困難に陥ります

その状態の場合はコンテナ内のログを収集することで最低限何もログが取得できないということを回避できます

Containerdの場合は以下のコマンドでコンテナのリストが取得できますので、あとはDockerコマンドと同じ要領で`crictl logs ${CONTAINER_ID}`を実行することでコンテナ内で発生したログをkube-apiserverなしで取得できます

```bash
sudo crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock ps -a
```