---
title: "スーパーオタクﾊﾟｿｺﾝｶﾀｶﾀneovimerへの道"
date: 2023-04-13T22:49:43+09:00
categories: [Neovim]
#公開時はdraftをfalseに!!!!!!!!!!!!
draft: false
toc: true
---
いちいちあれ何だっけとググるのは馬鹿らしいのでここにvimのコマンドとかショートカットとか全部メモする
## 基本操作
### 挿入
- 冒頭から挿入: `I`
- 末尾から挿入: `A`
- 次の行で挿入: `o`
### カーソル移動
- 行末に移動: `$` ←めんど
- 行頭に移動: `0`
- 1ページ進む: `<C-f>`
- 1ページ戻る: `<C-b>`
### 行操作
- 一行削除: `dd`
### コピペ
- ヤンク: `yy`
- その場にペースト: `p`
- 上の行にペースト: `P`
## ペイン操作
- 上下分割: `<C-w>-s`
- 左右分割: `<C-w>-v`
- 縦に小さくする: `<C-w>--`
- 縦に大きくする: `<C-w>-+`
- 閉じる: `<C-w>-c`
## 元に戻したりやり直したり
- Undo: `u`
- Redo: `<C-r>`
## 諸々
- 一文字消す: `x`
- ターミナルモードからコマンドモードに戻る: ~~`C-\-n`←めんどい~~
  - ESCキーをうまいこと使えるようにした [neovimターミナルモードエスケープと即座に確定するマッピング](https://zenn.dev/fuzmare/articles/vim-term-escape)

## 参考にしたWeb
- [キーマップの基本 (map, noremap) - まくまくVimノート](https://maku77.github.io/vim/keymap/basic.html)
- [【Neovim】toggleterm.nvimとlazygitを組み合わせてgit操作を快適にする](https://zenn.dev/stafes_blog/articles/524e4c8c80db24#lazygit%E3%81%AE%E8%A8%AD%E5%AE%9A)

## 導入したPlugin一覧
- [coc.nvim](https://github.com/neoclide/coc.nvim) 
- [vimdoc-ja](https://github.com/vim-jp/vimdoc-ja)
- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
- [lexima.vim](https://github.com/cohama/lexima.vim)
  - かっこを閉じてくれるやつ
- [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)
  - alpha-nvimが依存
- [alpha-nvim](https://github.com/goolord/alpha-nvim)
- [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim)

- [fern.vim](https://github.com/lambdalisue/fern.vim)
  - nerd化のため以下のプラグインを導入
  - [nerdfont.vim](https://github.com/lambdalisue/nerdfont.vim)
  - [glyph-palette.vim](https://github.com/lambdalisue/glyph-palette.vim)
    - nerdfontに色を付けるためのもの?
  - [fern-renderer-nerdfont.vim](https://github.com/lambdalisue/fern-renderer-nerdfont.vim)
  - [fern-git-status.vim](https://github.com/lambdalisue/fern-git-status.vim)
