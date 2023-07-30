---
title: "PowerToys Runの検索結果に手動で入れたアプリケーションを出す方法"
date: 2023-07-31T02:07:56+09:00
categories: [Windows]
draft: false
toc: false
---
### 環境
- Windows 11 Pro 22H2 22621.1992
- PowerToys v0.71.0
---
この世に星の数ほどあるWindowsアプリには、大きく2つ種類があり1つはダウンロードするとインストーラーが落ちてくるやつ、もう1つはzipファイルで落ちてくるやつ。

このzipファイルでそのまんまexeファイルが落ちてくるやつがちょいと面倒で、自分で適当なフォルダに置かなければなりません。自分は適当に`C:Program Files(x86)`に入れているのですが、大変便利なおそらくMacのSpotlightのパクリであるPowerToys Runの検索結果にここに置いただけのアプリケーションが出てきません。てっきりpath配下のexeファイル見ているだけだと思ったらそうでは無いようです

色々調べてみると出てきました。PowerToys Runの話はしていませんが、おそらくコア的なのは同じでしょう

[［Windows 10］アプリやプログラムを検索結果に出るようにするには？ | 日経クロステック（xTECH）](https://xtech.nikkei.com/it/atcl/column/15/112000265/060300064/)

> ファイルショートカット（.lnkファイル）を`%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu` に置く

記事が古いのか、**私の環境では`%USERPROFILE%\AppData\Roaming\Microsoft\Windows\スタートメニュ\プログラム\`がそれっぽいやつで、そこにショートカットを入れると解決しました。**

でも、ここに全てのアプリケーションのショートカットがあるわけではないので、また別のところも見ているのかな? Windowsよくわからんですね。

