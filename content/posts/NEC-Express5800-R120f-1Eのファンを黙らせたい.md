---
title: "NEC Express5800 R120f-1Eのファンを黙らせたい"
date: 2023-03-24T09:46:36+09:00
categories: [自宅サーバー]
#公開時はdraftをfalseに!!!!!!!!!!!!
draft: false
toc: true
---
NECのサーバを自宅サーバに導入しているのですが、昔導入していたHPE Proliant DL160 Gen9サーバに比べてアイドル時のファンが非常にうるさいです。6000~7000rpmでファンが常時回っており、温度に対して明らかに過剰な冷却です[^1]。その分、Boot時には静かなのでいいのですが...(HPEはUEFIが立ち上がるまで?ファンがフル回転)

そのためサーバは部屋の外に追いやっており、冷房はもちろんないので、夏になるとなんかサーバラック周辺が暖かくなってしまいます。これは機器のことを考えるとあまり好ましい状況ではなく、これによって部品の寿命が縮んでしまい[^2]故障する可能性を考えると精神衛生上あまり良くないため、部屋の中に入れたいのですがねれなくなるのは嫌なのでうまいことファンを黙らせる必要があります。

HPEのサーバではなんとBMC(ILO4)のファームウェアをゴニョゴニョしてファンを黙らせるというソフトウェア(https://github.com/kendallgoto/ilo4_unlock)があるそうです。NECのサーバは海外シェアが低すぎて[^3]そのようなソフトウェアの類は一切出ていませんが、このポストではそれを実現するためハードウェアの改造やソフトウェアでゴニョゴニョするためにハードウェアの構成などをメモします
### ハードウェアハックの可能性
フロント部分にファンコントローラーが裏側にあり、HDDなどをくっつけるSAS接続のコントローラ?スイッチ?が表側に実装された基板があります。そこからよくわからないコネクタが伸びていてファンが接続されています。ファンを駆動させるのにこんなにピン数はいらないはずなのですがいっぱいピンがありますね...謎です

![ファン基板?](/images/NEC-Express5800-R120f-1Eのファンを黙らせたい/FanControl-Board.jpg)
全景を写した写真

もしファンがBMCから操作されているのであれば右のカラフルなコネクターか真ん中の40pinぐらいありそうなコネクターを抜いてみるとおそらくファンが全力回転とかを始めるのでそれによってソフトウェアから操作可能なのか、それとも独立して制御しているのかの2択が絞れます。←あとでやる

その基板にはコントローラらしきチップがあり、どうやらこのチップはCPLDというFPGA的なやつだそうです。これのプログラムを吸い出して書き換えれば...とか思いましたが、おそらくこいつのインターフェースとなるJTAGとか触ったことないですしそもそもFPGAとか触ったこともないので無理筋ですね...
![ファンコントローラー?](/images/NEC-Express5800-R120f-1Eのファンを黙らせたい/ALTERA-Max-2-Chip.jpg)
EPM570T100CSN

という訳でハードウェアハックの可能性としては抵抗を挟む、それでだめだったら(ファンの目標回転数と現在値を照らし合わせしているなどでエラー状態になるなど)別のマイコンでファンを制御しつつ、ファン端子には偽造信号を流しておく、ぐらいのとてもハックとは言えない脳筋技しか思いつきませんんでした

### ソフトウェアハックの可能性
NECのサーバと言っても結局の所、HPEなどとは違い既存チップ/ソフトウェアの組み合わせですので色々調べ上げてググれば解決する可能性があります。

BMCはExpressscopeEngine3とか言っていますが、中身のコントローラーはEmulex Pilot 3というチップが載っていると[Express5800/R120f-1E スペック詳細/アーキテクチャ図](https://www.support.nec.co.jp/View.aspx?id=3140104058)に書いてあります。実際それらしきチップが乗っています。
![チップの画像](/images/NEC-Express5800-R120f-1Eのファンを黙らせたい/Emulex-Pilot-3-Chip.jpg)
SE-SM4310-P02

[詳細が書かれたpdf](http://static6.arrow.com/aropdfconversion/d9c5a9a2212525e49808fc165fad39e728574631/7201870254756275elx_ds_all_pilot3.pdf)

[MAX2についての日本語での情報](https://optimize.ath.cx/max2/index.html)

よくあるファンを黙らせる手法としてipmitoolのrawコマンドを打って、というのがありますがその手法はGoogle検索の限りでは見つかりませんでした。

ExpressscopeEngine3からファンの回転数等の情報が見れるのですが、どのような通信をしているのか見てみるとどうやら/rpc/getsensors.aspに通信をすることでファンの回転数を取得しているようです。また  /rpc/ipmicmd.aspで生のipmiのコマンドを実行することもできるみたいです。

![通信](/images/NEC-Express5800-R120f-1Eのファンを黙らせたい/communications.jpg)

またExpressscopeEngine3はJavaScriptのソースコードは難読化(minify化)されておらず、コメントも含めて読むことが可能になっています。
![JavaScriptコード](/images/NEC-Express5800-R120f-1Eのファンを黙らせたい/javascript-codes.jpg)
Advanced Fan Control機能という機能があるらしいがこのサーバだと使えないようで表示されない

Twitterのツイートによると日立のHA8000シリーズのサーバーとWebUIが酷似しているらしく、恐らく同じソフトウェアとチップが使われているようです。でもJavaScriptの一番上のAuthorには日本人ぽい名前が書いてあるのでNECが日立にソフトウェアを提供したんですかね?

{{< tweet user="uhehehe366" id="1030679417608011777" >}}

このツイートのリプにはNECと日立はMBがGIGABYTEとの情報もありますね

{{< tweet user="gogotea3" id="1030681815193796608" >}}

色々見ましたが、IPMIとのHTTP通信からファンを制御できるとは考えづらいので、無理筋ですね

他にもipmitoolとかipmiutilとかで色々触ってみましたが、ファンが操作できる雰囲気ではなかったです。ですが、BMCのファームウェア更新はLinuxイメージが配られていて、そいつを立ち上げるとBMCが更新されるという仕組みなのでそいつをうまいこと解析すればLinuxからゴニョゴニョできるかも?

### 結論
ハードウェア脳筋ハックが一番現実的?

### 付録 : ipmitool sensorの結果
```text
$ sudo ipmitool sensor
Processor1 VCCIN | 1.805      | Volts      | ok    | na        | 1.241     | 1.316     | 2.030     | 2.124     | na
Processor2 VCCIN | 1.795      | Volts      | ok    | na        | 1.241     | 1.316     | 2.030     | 2.124     | na
Processor1 VPP1  | 2.535      | Volts      | ok    | na        | 2.119     | 2.249     | 2.743     | 2.873     | na
Processor2 VPP1  | 2.548      | Volts      | ok    | na        | 2.119     | 2.249     | 2.743     | 2.873     | na
Processor1 VPP2  | 2.548      | Volts      | ok    | na        | 2.119     | 2.249     | 2.743     | 2.873     | na
Processor2 VPP2  | 2.535      | Volts      | ok    | na        | 2.119     | 2.249     | 2.743     | 2.873     | na
Processor1 VDDQ1 | 1.215      | Volts      | ok    | na        | 0.980     | 1.039     | 1.372     | 1.441     | na
Processor2 VDDQ1 | 1.225      | Volts      | ok    | na        | 0.980     | 1.039     | 1.372     | 1.441     | na
Processor1 VDDQ2 | 1.225      | Volts      | ok    | na        | 0.980     | 1.039     | 1.372     | 1.441     | na
Processor2 VDDQ2 | 1.215      | Volts      | ok    | na        | 0.980     | 1.039     | 1.372     | 1.441     | na
Processor VCCIO  | 1.039      | Volts      | ok    | na        | 0.892     | 0.941     | 1.147     | 1.205     | na
Baseboard 1.5V   | 1.480      | Volts      | ok    | na        | 1.274     | 1.343     | 1.646     | 1.725     | na
Baseboard 1.5VSB | 1.470      | Volts      | ok    | na        | 1.274     | 1.343     | 1.646     | 1.725     | na
Baseboard 1.8VSB | 1.784      | Volts      | ok    | na        | 1.529     | 1.617     | 1.980     | 2.068     | na
Baseboard 3.3V   | 3.271      | Volts      | ok    | na        | 2.781     | 2.939     | 3.602     | 3.760     | na
Baseboard 3.3VSB | 3.286      | Volts      | ok    | na        | 2.781     | 2.939     | 3.602     | 3.760     | na
Baseboard 5V     | 5.085      | Volts      | ok    | na        | 4.458     | 4.724     | 5.423     | 5.688     | na
Baseboard 5VSB   | 4.892      | Volts      | ok    | na        | 4.458     | 4.724     | 5.423     | 5.688     | na
Baseboard 12V    | 12.036     | Volts      | ok    | na        | 10.915    | 11.505    | 13.275    | 13.865    | na
Baseboard VBAT   | 3.095      | Volts      | ok    | na        | 2.387     | 2.495     | 3.496     | 3.573     | na
POWER            | 215.000    | Watts      | ok    | na        | na        | na        | na        | na        | na
Processor1 POWER | 31.000     | Watts      | ok    | na        | na        | na        | na        | na        | na
Processor2 POWER | 48.000     | Watts      | ok    | na        | na        | na        | na        | na        | na
Proc1 Margin     | -18.000    | degrees C  | ok    | na        | na        | na        | na        | na        | na
Proc2 Margin     | -12.000    | degrees C  | ok    | na        | na        | na        | na        | na        | na
Chipset Temp     | 41.000     | degrees C  | ok    | na        | na        | na        | na        | na        | na
Baseboard Temp1  | 43.000     | degrees C  | ok    | na        | 2.000     | 5.000     | 88.000    | 94.000    | na
FntPnl Amb Temp  | 26.000     | degrees C  | ok    | na        | 2.000     | 5.000     | 44.000    | 47.000    | na
CPU1_DIMM Temp   | 39.000     | degrees C  | ok    | na        | 2.000     | 5.000     | 88.000    | 94.000    | na
CPU2_DIMM Temp   | 39.000     | degrees C  | ok    | na        | 2.000     | 5.000     | 88.000    | 94.000    | na
PSU1 Temp1       | 39.000     | degrees C  | ok    | na        | na        | na        | na        | na        | na
PSU1 Temp2       | 53.000     | degrees C  | ok    | na        | na        | na        | na        | na        | na
PSU2 Temp1       | 38.000     | degrees C  | ok    | na        | na        | na        | na        | na        | na
PSU2 Temp2       | 54.000     | degrees C  | ok    | na        | na        | na        | na        | na        | na
DAC LSI Temp     | 80.000     | degrees C  | ok    | na        | na        | na        | na        | na        | na
DAC CV Temp      | 28.000     | degrees C  | ok    | na        | na        | na        | na        | na        | na
Drive Temp       | 34.000     | degrees C  | ok    | na        | na        | na        | na        | na        | na
P1 Therm Ctrl %  | 0.000      | percent    | ok    | na        | na        | na        | 29.640    | 49.530    | na
P2 Therm Ctrl %  | 0.000      | percent    | ok    | na        | na        | na        | 29.640    | 49.530    | na
System FAN1R     | 6410.256   | RPM        | ok    | na        | na        | na        | 2300.331  | na        | na
System FAN2R     | 6325.911   | RPM        | ok    | na        | na        | na        | 2300.331  | na        | na
System FAN3R     | 6243.756   | RPM        | ok    | na        | na        | na        | 2300.331  | na        | na
System FAN4R     | 6410.256   | RPM        | ok    | na        | na        | na        | 2300.331  | na        | na
System FAN5R     | 6410.256   | RPM        | ok    | na        | na        | na        | 2300.331  | na        | na
System FAN6R     | 6496.881   | RPM        | ok    | na        | na        | na        | 2300.331  | na        | na
System FAN7R     | 6496.881   | RPM        | ok    | na        | na        | na        | 2300.331  | na        | na
System FAN8R     | 6496.881   | RPM        | ok    | na        | na        | na        | 2300.331  | na        | na
System FAN1F     | 7344.301   | RPM        | ok    | na        | na        | na        | 3519.144  | na        | na
System FAN2F     | 7188.039   | RPM        | ok    | na        | na        | na        | 3519.144  | na        | na
System FAN3F     | 7188.039   | RPM        | ok    | na        | na        | na        | 3519.144  | na        | na
System FAN4F     | 7344.301   | RPM        | ok    | na        | na        | na        | 3519.144  | na        | na
System FAN5F     | 7344.301   | RPM        | ok    | na        | na        | na        | 3519.144  | na        | na
System FAN6F     | 7344.301   | RPM        | ok    | na        | na        | na        | 3519.144  | na        | na
System FAN7F     | 7344.301   | RPM        | ok    | na        | na        | na        | 3519.144  | na        | na
System FAN8F     | 7344.301   | RPM        | ok    | na        | na        | na        | 3519.144  | na        | na
Power Unit       | 0x0        | discrete   | 0x0080| na        | na        | na        | na        | na        | na
Power Unit Redun | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na
BMC Watchdog     | 0x0        | discrete   | 0x0080| na        | na        | na        | na        | na        | na
Scrty Violation  | 0x0        | discrete   | 0x0080| na        | na        | na        | na        | na        | na
Physical Scrty   | 0x0        | discrete   | 0x0080| na        | na        | na        | na        | na        | na
POST Error       | na         | discrete   | na    | na        | na        | na        | na        | na        | na
Critical Int     | 0x0        | discrete   | 0x0080| na        | na        | na        | na        | na        | na
Memory           | 0x0        | discrete   | 0x0080| na        | na        | na        | na        | na        | na
Memory           | na         | discrete   | na    | na        | na        | na        | na        | na        | na
Logging Disabled | 0x0        | discrete   | 0x0080| na        | na        | na        | na        | na        | na
Processor 1 Stat | 0x0        | discrete   | 0x8080| na        | na        | na        | na        | na        | na
Processor 2 Stat | 0x0        | discrete   | 0x8080| na        | na        | na        | na        | na        | na
Chip Set         | 0x0        | discrete   | 0x0080| na        | na        | na        | na        | na        | na
Power Supply 1   | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na
Power Supply 2   | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na
System Event     | 0x0        | discrete   | 0x0080| na        | na        | na        | na        | na        | na
Button           | 0x0        | discrete   | 0x0080| na        | na        | na        | na        | na        | na
Proc Missing     | 0x0        | discrete   | 0x0080| na        | na        | na        | na        | na        | na
CPU1_DIMM1 Stat  | 0x0        | discrete   | 0x0480| na        | na        | na        | na        | na        | na
CPU1_DIMM2 Stat  | 0x0        | discrete   | 0x0480| na        | na        | na        | na        | na        | na
CPU1_DIMM3 Stat  | 0x0        | discrete   | 0x0480| na        | na        | na        | na        | na        | na
CPU1_DIMM4 Stat  | 0x0        | discrete   | 0x0480| na        | na        | na        | na        | na        | na
CPU1_DIMM5 Stat  | 0x0        | discrete   | 0x0080| na        | na        | na        | na        | na        | na
CPU1_DIMM6 Stat  | 0x0        | discrete   | 0x0080| na        | na        | na        | na        | na        | na
CPU1_DIMM7 Stat  | 0x0        | discrete   | 0x0080| na        | na        | na        | na        | na        | na
CPU1_DIMM8 Stat  | 0x0        | discrete   | 0x0080| na        | na        | na        | na        | na        | na
CPU2_DIMM1 Stat  | 0x0        | discrete   | 0x0480| na        | na        | na        | na        | na        | na
CPU2_DIMM2 Stat  | 0x0        | discrete   | 0x0480| na        | na        | na        | na        | na        | na
CPU2_DIMM3 Stat  | 0x0        | discrete   | 0x0480| na        | na        | na        | na        | na        | na
CPU2_DIMM4 Stat  | 0x0        | discrete   | 0x0480| na        | na        | na        | na        | na        | na
CPU2_DIMM5 Stat  | 0x0        | discrete   | 0x0080| na        | na        | na        | na        | na        | na
CPU2_DIMM6 Stat  | 0x0        | discrete   | 0x0080| na        | na        | na        | na        | na        | na
CPU2_DIMM7 Stat  | 0x0        | discrete   | 0x0080| na        | na        | na        | na        | na        | na
CPU2_DIMM8 Stat  | 0x0        | discrete   | 0x0080| na        | na        | na        | na        | na        | na
OptFAN 1U FAN1RF | 0x0        | discrete   | 0x0480| na        | na        | na        | na        | na        | na
OptFAN 1U FAN2RF | 0x0        | discrete   | 0x0480| na        | na        | na        | na        | na        | na
OptFAN 1U FAN3RF | 0x0        | discrete   | 0x0480| na        | na        | na        | na        | na        | na
OptFAN 1U FAN4RF | 0x0        | discrete   | 0x0480| na        | na        | na        | na        | na        | na
OptFAN 1U FAN5RF | 0x0        | discrete   | 0x0480| na        | na        | na        | na        | na        | na
OptFAN 1U FAN6RF | 0x0        | discrete   | 0x0480| na        | na        | na        | na        | na        | na
OptFAN 1U FAN7RF | 0x0        | discrete   | 0x0480| na        | na        | na        | na        | na        | na
OptFAN 1U FAN8RF | 0x0        | discrete   | 0x0480| na        | na        | na        | na        | na        | na
ACPI State       | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na
SMI Timeout      | 0x0        | discrete   | 0x0080| na        | na        | na        | na        | na        | na
Sensor Failure   | 0x0        | discrete   | 0x0080| na        | na        | na        | na        | na        | na
Drive 0 Status   | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na
Drive 1 Status   | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na
Drive 2 Status   | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na
Drive 3 Status   | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na
Drive 4 Status   | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na
Drive 5 Status   | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na
Drive 6 Status   | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na
Drive 7 Status   | 0x0        | discrete   | 0x0180| na        | na        | na        | na        | na        | na
Mem Rdnt Config  | 0x0        | discrete   | 0x0080| na        | na        | na        | na        | na        | na
Memory Resized   | na         | discrete   | na    | na        | na        | na        | na        | na        | na
System Init      | na         | discrete   | na    | na        | na        | na        | na        | na        | na
Boot Error       | na         | discrete   | na    | na        | na        | na        | na        | na        | na
OS Boot          | na         | discrete   | na    | na        | na        | na        | na        | na        | na
OS Stop          | na         | discrete   | na    | na        | na        | na        | na        | na        | na
```
[^1]: HPEはPCIに刺さっているボードとかの温度とかHDDの温度を取得したりしてファンの制御を細かくやっているという説もある(https://kazblog.hateblo.jp/entry/2019/02/15/224944)
[^2]: 酷使された中古しかいないので既に寿命は終わっているという説もある
[^3]: 最近はクラウドだかなんだかで市場全体が縮小したのかなんなのかで最新のNECのサーバの中身はHPEのGen10サーバといった形になってしまっています