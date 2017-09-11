vim-clang-tags
==============

vim-clang-tags is a Vim plugin to use [clang-tags](http://johnzeng.github.io/clang-tags/). You can use :ClangTagsGrep command to populate Vim's location list with all uses of the symbol under the cursor.

## Options

### g:clang_tags_force_update_every_query
default: 1
when setting this, this plugin will do update every time you call ':ClangTagsGrep'

## Commands

### ClangTagsGrep
Find all usage of the word under the cursor

### ClangTagsUpdate
Force clang tags to update the database
