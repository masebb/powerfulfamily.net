---
title: "argocd-image-updaterが動かなかった"
date: 2024-04-13
categories: [k8s]
draft: false
toc: false
---

```
time="2024-04-13T10:40:00Z" level=warning msg="skipping app 'powerfulfamily-blog' of type '' because it's not of supported source type" application=powerfulfamily-blog
```

こんな事を言われて、イメージがプッシュされても拾ってきてくれません

[Multiple helm sources: skipping app of type '' because it's not of supported source type · Issue #558 · argoproj-labs/argocd-image-updater](https://github.com/argoproj-labs/argocd-image-updater/issues/558)

どうやら、Multiple Sourcesに対応していないみたいです。私はそもそもMultiple Sourcesを使っていないのにMultiple Sourcesを使っているやつからコピペしたことによって`sources`の中に1つだけsourceがあるという状態になっていたので、それを消して普通のArgocd Applicationにすれば動きました

