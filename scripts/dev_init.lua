local source = debug.getinfo(1, 'S').source:sub(2)
local root = vim.fn.fnamemodify(source, ':p:h:h')
local user_init = vim.fs.joinpath(vim.fn.stdpath('config'), 'init.lua')
local notes_dir = vim.env.TAXON_DEV_NOTES_DIR or vim.fs.joinpath(root, '.tmp', 'taxon-notes')

local function source_user_init(path)
  if vim.uv.fs_stat(path) == nil then
    return
  end

  local ok, err = pcall(dofile, path)
  if ok then
    return
  end

  vim.schedule(function()
    vim.notify(
      'Taxon dev init: failed to load ' .. path .. '\n' .. tostring(err),
      vim.log.levels.WARN
    )
  end)
end

source_user_init(user_init)

vim.opt.runtimepath:prepend(root)
vim.opt.packpath = vim.o.runtimepath

dofile(vim.fs.joinpath(root, 'plugin', 'taxon.lua'))

require('taxon').setup({
  notes_dir = notes_dir,
})

vim.schedule(function()
  vim.notify('Taxon dev: notes_dir=' .. notes_dir, vim.log.levels.INFO)
end)
