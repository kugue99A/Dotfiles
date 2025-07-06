local M = {}
local telescope = require("telescope")
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

-- Smart find files: recent files first, then all files
function M.smart_find_files()
  local opts = {
    prompt_title = "Smart Find Files (Recent + All)",
    finder = finders.new_table({
      results = M.get_smart_files(),
    }),
    sorter = conf.generic_sorter({}),
    previewer = conf.file_previewer({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.cmd("edit " .. selection[1])
        end
      end)
      return true
    end,
  }
  
  pickers.new({}, opts):find()
end

-- Get combined list of recent files and all files
function M.get_smart_files()
  local recent_files = {}
  local all_files = {}
  
  -- Get recent files from oldfiles
  local oldfiles = vim.v.oldfiles or {}
  for _, file in ipairs(oldfiles) do
    if vim.fn.filereadable(file) == 1 and not string.match(file, "^/tmp") then
      -- Make path relative if it's in current directory
      local relative_path = vim.fn.fnamemodify(file, ":.")
      if string.len(relative_path) < string.len(file) then
        table.insert(recent_files, relative_path)
      else
        table.insert(recent_files, file)
      end
    end
  end
  
  -- Limit recent files to avoid too many results
  local max_recent = 20
  if #recent_files > max_recent then
    for i = 1, max_recent do
      table.insert(all_files, "📁 " .. recent_files[i])
    end
  else
    for _, file in ipairs(recent_files) do
      table.insert(all_files, "📁 " .. file)
    end
  end
  
  -- Add separator
  table.insert(all_files, "─────────────────────────")
  
  -- Get current directory files (limited)
  local handle = io.popen("find . -type f -not -path '*/.*' -not -path '*/node_modules/*' | head -50")
  if handle then
    for line in handle:lines() do
      -- Remove leading ./
      local clean_path = string.gsub(line, "^%./", "")
      -- Skip if already in recent files
      local is_recent = false
      for _, recent in ipairs(recent_files) do
        if recent == clean_path or recent == line then
          is_recent = true
          break
        end
      end
      if not is_recent then
        table.insert(all_files, clean_path)
      end
    end
    handle:close()
  end
  
  return all_files
end

-- Smart live grep: start with recent files, expand to all
function M.smart_live_grep()
  local opts = {
    prompt_title = "Smart Live Grep",
    search_dirs = M.get_recent_dirs(),
  }
  
  builtin.live_grep(opts)
end

-- Get directories from recent files
function M.get_recent_dirs()
  local dirs = {}
  local seen = {}
  
  local oldfiles = vim.v.oldfiles or {}
  for _, file in ipairs(oldfiles) do
    if vim.fn.filereadable(file) == 1 then
      local dir = vim.fn.fnamemodify(file, ":h")
      if not seen[dir] and vim.fn.isdirectory(dir) == 1 then
        table.insert(dirs, dir)
        seen[dir] = true
      end
    end
  end
  
  -- Add current directory if not present
  local cwd = vim.fn.getcwd()
  if not seen[cwd] then
    table.insert(dirs, 1, cwd)
  end
  
  return dirs
end

return M