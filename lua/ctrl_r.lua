local M = {}
local api, fn = vim.api, vim.fn

local H = {}

---@param str string
---@return string
local getreg = function(str) return H[str] and H[str]() or fn.getreg(str) end

---@see nvim_input: no undopoint
---@see vim.paste: not dot-repeatable
---@param name? string
---@param ctx? vim.context.mods
---@return string?
M.get = function(name, ctx)
  name = name or fn.keytrans(fn.getcharstr())
  name = name:lower()
  if name == '=' then
    return api.nvim_feedkeys(vim.keycode('<c-r>='), 'nt', false)
  elseif name == '<c-r>' then
    return api.nvim_feedkeys(vim.keycode('<c-r>'), 'nt', false)
  end
  local res = (vim._with or require('ctrl_r.with'))(ctx or {}, function() return getreg(name) end)
  api.nvim_paste(res, false, -1)
  return res
end

H.f = function()
  local info = require('fzf-lua').get_info()
  return info.query or info.last_query or ''
end

H.w = function()
  local buf = api.nvim_win_get_buf(fn.win_getid(fn.winnr('#')))
  local name = api.nvim_buf_get_name(buf)
  return require('ctrl_r.path').HOME_to_tilde(name)
end

H.m = function() return _G.last_msg or '' end

local invald_pos = { 0, 0, 0, 0 }
H.v = function()
  local pos1, pos2 = fn.getpos("'<"), fn.getpos("'>")
  if vim.deep_equal(pos1, invald_pos) or vim.deep_equal(pos2, invald_pos) then return '' end
  return (vim._with or require('ctrl_r.with'))({ wo = { ve = 'all' } }, function()
    local inclusive = vim.o.sel:sub(1, 1) ~= 'e'
    local res =
      fn.getregion(fn.getpos("'<"), fn.getpos("'>"), { eol = true, exclusive = not inclusive })
    return table.concat(res, '\n')
  end)
end

H['?'] = function()
  local reg = fn.getreg('/')
  local res = reg:gsub('^\\V', '')
  res = res:gsub('^\\<(.*)\\>$', '%1')
  res = res:gsub('\\\\', '\\')
  res = res:gsub('\\n', '\n')
  res = res:gsub('/s%+%d+$', '')
  return res
end

H[';'] = function() return fn.histget(':', -1) end

H['<c-w>'] = function() return fn.expand('<cword>') end

return M
