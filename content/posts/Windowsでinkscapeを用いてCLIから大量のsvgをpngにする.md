---
title: "Windowsでinkscapeを用いてPowerShellから大量のsvgをpngにする"
date: 2023-04-29T16:20:24+09:00
categories: [inkscape]
toc: false
---
どうやらInkscapeはパターンマッチングなどができないっぽいのでforeachでゴリ押しです
```powershell
$files = Get-Item *.svg
foreach ($f in $files){
   inkscape.exe --export-type="png" --export-width="512" $f
   echo $f
}
```
### 参考
[Using the Command Line - Inkscape Wiki](https://wiki.inkscape.org/wiki/index.php/Using_the_Command_Line)
