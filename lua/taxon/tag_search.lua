local M = {}

local function resolve_telescope(telescope)
  if telescope ~= nil then
    return telescope
  end

  local ok_pickers, pickers = pcall(require, 'telescope.pickers')
  local ok_finders, finders = pcall(require, 'telescope.finders')
  local ok_config, config = pcall(require, 'telescope.config')
  local ok_actions, actions = pcall(require, 'telescope.actions')
  local ok_action_state, action_state = pcall(require, 'telescope.actions.state')

  if not (ok_pickers and ok_finders and ok_config and ok_actions and ok_action_state) then
    return nil, 'missing-telescope'
  end

  return {
    action_state = action_state,
    actions = actions,
    config = config,
    finders = finders,
    pickers = pickers,
  }
end

function M.build_entries(tags)
  vim.validate({
    tags = { tags, 'table' },
  })

  local entries = {}

  for _, current_tag in ipairs(tags) do
    local spaced_tag = current_tag:gsub('/', ' / ')

    table.insert(entries, {
      display = current_tag,
      ordinal = string.format('%s %s', current_tag, spaced_tag),
      tag = current_tag,
    })
  end

  return entries
end

function M.pick(entries, opts)
  vim.validate({
    entries = { entries, 'table' },
    opts = { opts, 'table', true },
  })

  opts = opts or {}

  local telescope, err = resolve_telescope(opts.telescope)
  if telescope == nil then
    return nil, err
  end

  local finder = telescope.finders.new_table({
    results = entries,
    entry_maker = function(entry)
      return {
        display = entry.display,
        ordinal = entry.ordinal,
        value = entry,
      }
    end,
  })

  local picker = telescope.pickers.new({}, {
    prompt_title = opts.prompt_title or 'Taxon Tag Search',
    finder = finder,
    sorter = telescope.config.values.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      telescope.actions.select_default:replace(function()
        local selection = telescope.action_state.get_selected_entry()

        telescope.actions.close(prompt_bufnr)

        if selection == nil or selection.value == nil or opts.on_select == nil then
          return
        end

        opts.on_select(selection.value)
      end)

      return true
    end,
  })

  picker:find()
  return true
end

return M
