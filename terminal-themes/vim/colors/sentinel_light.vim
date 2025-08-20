" Sentry Sentinel Light - Vim Colorscheme
" Author: Sentry
" Description: Beautiful, accessible light theme inspired by Sentry's brand colors
" Version: 1.0.0

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'sentinel_light'
set background=light

" Sentry Brand Colors
let s:bg_primary     = '#FFFFFF'
let s:bg_secondary   = '#F8F9FA'
let s:bg_tertiary    = '#E5E7EB'
let s:fg_primary     = '#1F2937'
let s:fg_secondary   = '#374151'
let s:fg_tertiary    = '#6B7280'
let s:fg_muted       = '#9CA3AF'

let s:sentry_purple  = '#36166B'
let s:sentry_pink    = '#FF45A8'
let s:sentry_orange  = '#EE8019'
let s:border         = '#D1D5DB'

let s:green          = '#92DD00'
let s:yellow         = '#EE8019'
let s:red            = '#DC2626'
let s:blue           = '#2563EB'
let s:cyan           = '#0891B2'
let s:purple         = '#6E47AE'

" Helper function for setting highlights
function! s:hi(group, guifg, guibg, attr, guisp)
  if a:guifg != ""
    exec "hi " . a:group . " guifg=" . a:guifg
  endif
  if a:guibg != ""
    exec "hi " . a:group . " guibg=" . a:guibg
  endif
  if a:attr != ""
    exec "hi " . a:group . " gui=" . a:attr
  endif
  if a:guisp != ""
    exec "hi " . a:group . " guisp=" . a:guisp
  endif
endfunction

" Basic UI
call s:hi('Normal',       s:fg_primary,   s:bg_primary,   'NONE', '')
call s:hi('Cursor',       s:bg_primary,   s:sentry_pink,  'NONE', '')
call s:hi('CursorLine',   '',             s:bg_secondary, 'NONE', '')
call s:hi('CursorColumn', '',             s:bg_secondary, 'NONE', '')
call s:hi('LineNr',       s:fg_muted,     '',             'NONE', '')
call s:hi('CursorLineNr', s:fg_secondary, '',             'bold', '')
call s:hi('Visual',       '',             s:sentry_purple.'20', 'NONE', '')
call s:hi('Search',       s:bg_primary,   s:sentry_pink.'40',   'NONE', '')
call s:hi('IncSearch',    s:bg_primary,   s:sentry_pink,        'NONE', '')

" Status Line
call s:hi('StatusLine',   s:bg_primary,   s:bg_tertiary,  'NONE', '')
call s:hi('StatusLineNC', s:fg_tertiary,  s:bg_secondary, 'NONE', '')
call s:hi('VertSplit',    s:border,       '',             'NONE', '')

" Popup Menu
call s:hi('Pmenu',        s:fg_primary,   s:bg_secondary, 'NONE', '')
call s:hi('PmenuSel',     s:bg_primary,   s:sentry_purple.'40', 'NONE', '')
call s:hi('PmenuSbar',    '',             s:border,       'NONE', '')
call s:hi('PmenuThumb',   '',             s:fg_tertiary,  'NONE', '')

" Tabs
call s:hi('TabLine',      s:fg_tertiary,  s:bg_secondary, 'NONE', '')
call s:hi('TabLineFill',  '',             s:bg_primary,   'NONE', '')
call s:hi('TabLineSel',   s:bg_primary,   s:bg_tertiary,  'bold', '')

" Folds
call s:hi('Folded',       s:fg_tertiary,  s:bg_secondary, 'NONE', '')
call s:hi('FoldColumn',   s:fg_muted,     s:bg_primary,   'NONE', '')

" Diff
call s:hi('DiffAdd',      '',             s:green.'20',   'NONE', '')
call s:hi('DiffChange',   '',             s:yellow.'20',  'NONE', '')
call s:hi('DiffDelete',   s:red,          s:red.'20',     'NONE', '')
call s:hi('DiffText',     '',             s:yellow.'40',  'NONE', '')

" Sign Column
call s:hi('SignColumn',   '',             s:bg_primary,   'NONE', '')

" Error/Warning
call s:hi('Error',        s:red,          '',             'bold', '')
call s:hi('ErrorMsg',     s:red,          '',             'bold', '')
call s:hi('WarningMsg',   s:yellow,       '',             'bold', '')
call s:hi('Todo',         s:sentry_pink,  '',             'bold', '')

" Syntax Highlighting
" Comments
call s:hi('Comment',      s:fg_muted,     '',             'italic', '')

" Constants
call s:hi('Constant',     s:purple,       '',             'NONE', '')
call s:hi('String',       s:green,        '',             'NONE', '')
call s:hi('Character',    s:green,        '',             'NONE', '')
call s:hi('Number',       s:yellow,       '',             'NONE', '')
call s:hi('Boolean',      s:yellow,       '',             'NONE', '')
call s:hi('Float',        s:yellow,       '',             'NONE', '')

" Identifiers
call s:hi('Identifier',   s:fg_primary,   '',             'NONE', '')
call s:hi('Function',     s:sentry_pink,  '',             'bold', '')

" Statements
call s:hi('Statement',    s:sentry_purple, '',            'bold', '')
call s:hi('Conditional',  s:sentry_purple, '',            'bold', '')
call s:hi('Repeat',       s:sentry_purple, '',            'bold', '')
call s:hi('Label',        s:sentry_purple, '',            'bold', '')
call s:hi('Operator',     s:fg_tertiary,   '',            'NONE', '')
call s:hi('Keyword',      s:sentry_purple, '',            'bold', '')
call s:hi('Exception',    s:sentry_purple, '',            'bold', '')

" PreProc
call s:hi('PreProc',      s:sentry_orange, '',            'NONE', '')
call s:hi('Include',      s:sentry_orange, '',            'NONE', '')
call s:hi('Define',       s:sentry_orange, '',            'NONE', '')
call s:hi('Macro',        s:sentry_orange, '',            'NONE', '')
call s:hi('PreCondit',    s:sentry_orange, '',            'NONE', '')

" Types
call s:hi('Type',         s:sentry_orange, '',            'NONE', '')
call s:hi('StorageClass', s:sentry_purple, '',            'bold', '')
call s:hi('Structure',    s:sentry_orange, '',            'NONE', '')
call s:hi('Typedef',      s:sentry_orange, '',            'NONE', '')

" Special
call s:hi('Special',      s:sentry_pink,   '',            'NONE', '')
call s:hi('SpecialChar',  s:sentry_pink,   '',            'NONE', '')
call s:hi('Tag',          s:sentry_pink,   '',            'NONE', '')
call s:hi('Delimiter',    s:fg_tertiary,   '',            'NONE', '')
call s:hi('SpecialComment', s:fg_tertiary, '',            'italic', '')
call s:hi('Debug',        s:sentry_pink,   '',            'NONE', '')

" Underlined
call s:hi('Underlined',   s:blue,          '',            'underline', '')

" Ignore
call s:hi('Ignore',       s:fg_muted,      '',            'NONE', '')

" Git Gutter
call s:hi('GitGutterAdd',    s:green,  '', 'NONE', '')
call s:hi('GitGutterChange', s:yellow, '', 'NONE', '')
call s:hi('GitGutterDelete', s:red,    '', 'NONE', '')

" NERDTree
call s:hi('NERDTreeDir',     s:sentry_purple, '', 'bold', '')
call s:hi('NERDTreeFile',    s:fg_secondary,  '', 'NONE', '')
call s:hi('NERDTreeExecFile', s:green,        '', 'NONE', '')

" Language-specific

" HTML
call s:hi('htmlTag',        s:fg_tertiary,   '', 'NONE', '')
call s:hi('htmlEndTag',     s:fg_tertiary,   '', 'NONE', '')
call s:hi('htmlTagName',    s:sentry_pink,   '', 'NONE', '')
call s:hi('htmlArg',        s:sentry_orange, '', 'NONE', '')

" CSS
call s:hi('cssClassName',   s:sentry_purple, '', 'NONE', '')
call s:hi('cssIdentifier',  s:sentry_purple, '', 'NONE', '')
call s:hi('cssProperty',    s:fg_secondary,  '', 'NONE', '')
call s:hi('cssValue',       s:green,         '', 'NONE', '')

" JavaScript
call s:hi('jsFunction',     s:sentry_purple, '', 'bold', '')
call s:hi('jsArrowFunction', s:sentry_purple, '', 'bold', '')
call s:hi('jsThis',         s:sentry_pink,   '', 'italic', '')
call s:hi('jsSuper',        s:sentry_pink,   '', 'italic', '')

" Python
call s:hi('pythonFunction', s:sentry_pink,   '', 'bold', '')
call s:hi('pythonClass',    s:sentry_orange, '', 'bold', '')
call s:hi('pythonSelf',     s:sentry_pink,   '', 'italic', '')

" Markdown
call s:hi('markdownH1',     s:sentry_purple, '', 'bold', '')
call s:hi('markdownH2',     s:sentry_purple, '', 'bold', '')
call s:hi('markdownH3',     s:sentry_purple, '', 'bold', '')
call s:hi('markdownLink',   s:blue,          '', 'underline', '')
call s:hi('markdownCode',   s:green,         '', 'NONE', '')

" JSON
call s:hi('jsonKeyword',    s:sentry_pink,   '', 'NONE', '')
call s:hi('jsonString',     s:green,         '', 'NONE', '')

" Cleanup
unlet s:bg_primary s:bg_secondary s:bg_tertiary
unlet s:fg_primary s:fg_secondary s:fg_tertiary s:fg_muted
unlet s:sentry_purple s:sentry_pink s:sentry_orange s:border
unlet s:green s:yellow s:red s:blue s:cyan s:purple
