# vim-plug-helper #

装的插件多了以后管理配置是个很麻烦的事。如果你像我一样使用[vim-plug](https://github.com/junegunn/vim-plug)来管理插件的话，这个辅助插件也许可以帮到你。

本插件实现了两个功能:

* 打开插件的GitHub页面(如果是本地插件则用系统默认的文件管理器打开所在路径)
* 快速在插件载入处和插件配置处切换

## 打开Github页面 ##

移动光标到插件载入处按gl

![](https://raw.githubusercontent.com/jiazhoulvke/vim-plug-helper.vim/master/screenshots/gl.gif)

## 跳转 ##

移动光标到插件载入处按gs，会跳转到插件配置处，再按gs会跳回原位

![](https://raw.githubusercontent.com/jiazhoulvke/vim-plug-helper.vim/master/screenshots/gs.gif)

## 注意事项 ##

我的配置都是这样的: 

```vim

" limelight: {{{3
autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!
" }}}

" tcomment: {{{3
let g:tcomment_maps = 0
nmap <silent> <space>c <Plug>TComment_gcc
xmap <silent> <space>c <Plug>TComment_gcc
nmap <silent> <M-/> <Plug>TComment_gcc
xmap <silent> <M-/> <Plug>TComment_gcc
" }}}

" indentLine: {{{3
let g:indentLine_char = '┊'
let g:indentLine_fileType = ['c', 'cpp', 'python', 'php', 'javascript', 'typescript', 'html', 'xml', 'vue']
let g:indentLine_fileTypeExclude = ['text']
let g:indentLine_bufTypeExclude = ['help', 'terminal']
let g:indentLine_bufNameExclude = ['_.*', 'NERD_tree.*']
" }}}

" vim-sleuth: {{{3
let g:sleuth_automatic = 1
" }}}

```

可以看出，插件的配置都是用maker折叠的, 只要符合是符合规律的配置都可以定位得到,大括号至少要有一对。

其中插件名不一定要完整的写出来(当然为了防止有重名插件的情况，写完整插件名是最好的)

比如你载入了一个插件:

```vim
Plug 'rhysd/clever-f.vim'
```
它的配置可以这样写:

```vim
" rhysd/clever-f.vim: {{{1
nmap f <Plug>(clever-f-f)
" }}}
```

也可以写:

```vim
" clever-f.vim: {{{
nmap f <Plug>(clever-f-f)
" }}}
```

后缀如果是.vim或者.nvim的话可以省略:

```vim
" clever-f {{{
nmap f <Plug>(clever-f-f)
" }}}
```

如果插件名前面是vim-的话，也可以省略:

```vim
Plug 'tpope/vim-surround'

" surround {{{
nmap ds <Plug>Dsurround
nmap cs <Plug>Csurround
nmap yss <Plug>Yssurround
nmap ys <Plug>Ysurround
xmap S <Plug>VSurround
}}}
```

## 配置 ##

默认绑定了两个快捷键:

* gl 打开插件的GitHub页面
* gs 跳转

默认只会对文件名为init.vim,ginit.vim,.vimrc,_vimrc生效

你可以通过这行代码禁用默认的按键绑定:

`let g:vim_plug_helper_no_maps = 1`

然后自己绑定按键到这两个函数:

* `VimPlugHelperOpenLink`
* `VimPlugHelperSwitch`

比如:

```vim
let g:vim_plug_helper_no_maps = 1

function! s:VPHSetting()
	nnoremap<silent><buffer> <C-l> :call VimPlugHelperOpenLink()<CR>
	nnoremap<silent><buffer> <C-s> :call VimPlugHelperSwitch()<CR>
endfunction

au! BufRead,BufEnter init.vim,ginit.vim,.vimrc,_vimrc call s:VPHSetting()
```
