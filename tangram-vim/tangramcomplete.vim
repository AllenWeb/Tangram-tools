""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Copyright (C) 2010 zhengqianglong@baidu.com
"
" Name: tangramcomplete.vim
" Description: A plugin for tangram library autocompletion
" Author: zhengqianglong
" Mail: zhengqianglong@baidu.com
" Last Modified: Apr 19, 2011
" Version: 2.0
" ChangeLog: 
" 
" 1. �����˽ű���֧��tangram1.1.0
"           created 1.0  2010/11/13
" --------------------------------------------------------------
" 1. �޸��˺��Ĺؼ��ʲ�ѯ�ĺ������޸���1.0�д��ڵĵ�һЩbug��e.g.
"       a)  baidu.('xx')  �޷�����g
"       b)  window.baidu.sug  ��Ĭ�ϱ��baidu.
" 2. ������onPopupPost�����ļ�飬�����1.0�д��ڵ���������
"       a)  ��û��ƥ��ʱ�������л����ƥ��ĺ�ɫ����
"       b)  ����ƥ��ʱ��Ĭ�ϵ�һ�����������ݣ���Ҫ���¼�����ѡ��
" 3. ������baidu��T���������ƿռ�֧��
"           updated to 2.0  2011/04/05
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" version checking & avoid load twice
" vim�汾��飬�����������
if exists('g:tangram_acp_loaded')
    finish
elseif v:version < 702
    echoerr 'Tangram auto complete does not support this version of vim (' . v:version . ').'
    finish
endif
let g:tangram_acp_loaded = 1

" give a off switcher, user can set g:tangram_acp_disabled = 1 to turn off this plugin
" ���أ���������g:tangram_acp_disabled = 1���رմ˹���
if exists('g:tangram_acp_disabled') && g:tangram_acp_disabled == 1
    finish
endif
let g:tangram_acp_disabled = 0

" do something when popup is show
function tangramcomplete#onPopupPost()
    echo ''
    if pumvisible()
        return "\<C-p>\<Down>"
    endif
    return "\<C-e>"
endfunction

" main function
function! tangramcomplete#CompleteTangram(findstart, base)

    if a:findstart
        " ��ȡ��ǰ�е���������
        let s:line = getline('.')
        " �������λ�õ�ǰһ���ַ�
        let s:start = col('.') - 1
        " �������λ�õ�ǰ2���ַ�
        let s:compl_begin = col('.') - 2
        " \k��ʾһ��keyword�����е�������һֱ��ǰ������ֱ������һ����keyword���ַ���ֹͣ
        " ������ƥ�����ʼλ����
        while s:start >= 0 && s:line[s:start - 1] =~ '\%(\k\|-\|\.\)'
            let s:start -= 1
        endwhile
        let b:compl_context = s:line[0:s:compl_begin]
        return s:start
    endif

    if exists("b:compl_context")
        let s:line = b:compl_context
        unlet! b:compl_context
    else
        let s:line = a:base
    endif

    let s:result = []

    " ֧��baidu��T�������ƿռ�
    if s:line =~# 'baidu\|T'
        " �洢���ƿռ�
        let s:tangram_prefix = match(s:line, 'baidu')>-1? 'baidu' : 'T'

        let s:tangram_keyword = matchstr(s:line, '\s*'.s:tangram_prefix.'\(\.\|[a-zA-Z]\)*$')
        if s:tangram_keyword != ""
            " �������������tangram���룬ȴ����baidu�ؼ��ʻ���ƥ������������zhidao.baidu.com
            let s:real_keyword = substitute(s:tangram_keyword, '\s*'.s:tangram_prefix, s:tangram_prefix, '')
            for m in g:tangram_dictionay
                " �ֵ����Ѿ����ٱ�ʶbaidu����T���ƿռ�
                if s:tangram_prefix.m['word'] =~? '^'.s:real_keyword
                    if m['word'] !~ '^'.s:tangram_prefix
                        " VIM�Ķ����������Ͳ���Ѱַ���õķ�ʽ������ͨ��deepcopy�������и���
                        let s:the_math = deepcopy(m) 
                        call extend(s:the_math, {'word' : s:tangram_prefix.m['word']})
                    endif
                    call add(s:result, s:the_math)
                endif
            endfor
            return s:result
        endif
    endif

    return []
endfunction
