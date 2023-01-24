#!/bin/bash
#依存 : imagemagic,jpegoptim
#TODO Dockerコンテナにする?
set -e
set -u

usage="Usage: addImage.sh 画像ファイル名 画像名(拡張子は入れない) 記事名(フォルダ名) サイズ(imagemagick)"

if [ ! $# -eq 4 ]; then
  echo "$usage"
  exit 1
fi

imgsrc="$1"
imgname="$2"
posttitle="$3"
resizearg="$4"

dstDir="static/images/${posttitle}"
dst="${dstDir}/${imgname}.jpg"

mkdir -p "$dstDir"

#Exif消去
convert -resize "$resizearg" -auto-orient "$imgsrc" -strip "$dst"
#圧縮
jpegoptim --max=80 "$dst"