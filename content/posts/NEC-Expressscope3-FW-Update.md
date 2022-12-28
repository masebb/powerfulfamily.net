---
title: "NEC Express5800 R120f-1EサーバーでROM UtilityとExpressscope 3(IPMI)のアップデートをする"
date: 2022-12-28T01:24:03+09:00
draft: false
categories: [自宅サーバー]
---

Expressscope 3のファームウェアを02.18から最新の02.31にアップデートしていきます。02.31はどうやらROM Utilityが1.111.001でないとダメなようなので(Rom Utilityを最新Varにしろとだけ書いているのでどのバージョン以上なのかは不明)それも1.102.000からアップデートします

ROM Utilityのバージョンはブート画面でF4押してROM Utilityに入り、`Maintenance Utility`に入れば右上に出てきます

![RomUtilityのバージョン](/images/NEC-Expressscope3-FW-Update/RomUtil-Version.png)

 **この情報を参考にして何らかの損害を負ったとしても私は責任は負いません。** この情報はNEC公式のものでもなく、素人によるものですので参考程度にしてください

### 必要なソフトウェアをダウンロード

(一応、R120-1E用のリンクは貼っておきますが、[製品情報](https://www.support.nec.co.jp/HWSelectModelKataban.aspx)からダウンロードリンクに飛んだほうが安心だと思います(最新Varがあるかもしれないし))

- ROM Utility
[Express5800/R120f-1M Express5800/R120f-2M Express5800/R120f-1E ROM Utility(Off-line TOOL) 1.111.001](https://www.support.nec.co.jp/View.aspx?id=9010105915)

- BMC(Expressscope 3)ファームウェア
[ Express5800/R120f-1M, R120f-2M, R120f-1E, R120g-1M, R120g-2M, R120g-1E BMCファームウェア 02.31 , SDR 00.10 (オフラインアップデート版)](https://www.support.nec.co.jp/View.aspx?id=9010109882)

### 書き込み

ダウンロードしたものにはそれぞれisoファイルが入っており、それをブートすることで立ち上がったLinux(Busybox)上が勝手に色々書き込んでくれるというものです(Expressscope3のWebコンソールにBMCアップデートできるようなところがありますがあそこに書き込めるようなファイルはインターネットには見つからないので使えない)

今回買ったサーバーにはリモートマネージメント拡張ライセンスがついていたので、イメージリダイレクション機能を使ってブートをしたのでUSBメモリに焼くことがありませんでしたが、前回USBメモリーに焼いたときはとても苦労した記憶があるので少し曖昧になりますが、アドバイスを書いておこうと思います。

- isoの展開ツールでddコマンドや、BalenaEtcherを使うとうまく行かずに、Rufus(フリーソフト)を使うとうまいこと書き込んでくれてブートができるようになります
- ブートがうまく行かない場合、UEFIで`BootMode`を`Legacy`に設定するとうまく行った気がします(イメージリダイレクション使ったときはその必要無かった...記憶違いかも?)

焼いたあとはサーバにぶっ刺して待つだけで勝手に書き込んでくれます。リモートKVM機能を使っているときはBMCの再起動のため一旦リモートKVMが切断されてしばらく使えなくなることを注意してください

![アップデート成功](/images/NEC-Expressscope3-FW-Update/result-of-bmcfw-update.png)
✌

Webコンソールからバージョンが上がったことを確認して終了です

### トラブルシュート

ファームウェア更新後POSTで
```
WARNING: C501 Intel(R) Node Manager is in Recovery Mode.
```
と言われた場合は電源を引っこ抜いて30秒ほど待てば治って表示されることはなくなります

