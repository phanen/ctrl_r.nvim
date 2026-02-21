Make ctrl-r more useful.

```lua
vim.keymap.set({ 'i', 'c' }, '<c-r>', function() require('ctrl_r').get() end)
```

In terminal
```lua
-- e.g. useful combo: <Cmd>FzfLua live_grep<Cr><C-R>w
require('ctrl_r').get(regname, { win = (FzfLua and FzfLua.utils.__CTX() or {}).winid })
```

In shell (fish):
```fish
function insert_reg
    set -l reg $argv
    set -l regcontent "$(nvim --server $NVIM --clean --headless --remote-expr "v:lua.u.ctrl_r.get('$reg', v:false)")"
    # commandline -i $regcontent
end
for char in (string split '' 'abcdefghijklmnopqrstuvwxyz0123456789;?')
    bind escape,$char "_insert_reg $char"
end
```

The source, e.g. to store random message, `:ls<CR><C-R>m`:
```lua
pcall(vim.ui_attach, ns, opts, function(event, kind, ...)
  if event ~= 'msg_show' or kind == 'bufwrite' or kind == 'undo' then return end
  _G.last_msg = table.concat(vim.tbl_map(function(c) return c[2] end, ...), '')
end)
```


## Todo
* action on "paste"
* "context"/embark
* improve `=` register (completion/hl/...)

## Idea
https://www.gnu.org/software/emacs/manual/html_node/emacs/Registers.html
