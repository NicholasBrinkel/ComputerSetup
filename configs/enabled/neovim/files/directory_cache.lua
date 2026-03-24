-- Directory cache module for fast directory switching
-- Cache file: ~/.cache/nvim/directories.txt

local M = {}

local CACHE_DIR = vim.fn.stdpath("cache")
local CACHE_FILE = CACHE_DIR .. "/directories.txt"

local function ensure_cache_dir()
  local uv = vim.uv or vim.loop
  local stat = uv.fs_stat(CACHE_DIR)
  if not stat then
    uv.fs_mkdir(CACHE_DIR, 493)
  end
end

function M.build_cache(callback)
  ensure_cache_dir()
  local uv = vim.uv or vim.loop
  
  local output = vim.fn.system({ "fd", ".", "/" })
  local lines = vim.fn.split(output, "\n")
  local valid_lines = {}
  for _, line in ipairs(lines) do
    if line ~= "" and line ~= nil then
      local stat = uv.fs_stat(line)
      if stat and stat.type == "directory" then
        table.insert(valid_lines, line)
      end
    end
  end
  local file = io.open(CACHE_FILE, "w")
  if file then
    for _, line in ipairs(valid_lines) do
      file:write(line .. "\n")
    end
    file:close()
  end
  if callback then
    callback()
  end
end

function M.validate_cache(callback)
  local uv = vim.uv or vim.loop
  local stat = uv.fs_stat(CACHE_FILE)
  
  if not stat then
    M.build_cache(callback)
    return
  end
  
  local file = io.open(CACHE_FILE, "r")
  if not file then
    M.build_cache(callback)
    return
  end
  
  local existing_dirs = {}
  for line in file:lines() do
    if line ~= "" then
      existing_dirs[line] = true
    end
  end
  file:close()
  
  local valid_dirs = {}
  local stale_count = 0
  
  for dir, _ in pairs(existing_dirs) do
    local s = uv.fs_stat(dir)
    if s and s.type == "directory" then
      valid_dirs[dir] = true
    else
      stale_count = stale_count + 1
    end
  end
  
  if stale_count > 0 then
    local file = io.open(CACHE_FILE, "w")
    if file then
      for dir, _ in pairs(valid_dirs) do
        file:write(dir .. "\n")
      end
      file:close()
    end
  end
  
  local output = vim.fn.system({ "fd", ".", "/" })
  local lines = vim.fn.split(output, "\n")
  local new_count = 0
  
  for _, line in ipairs(lines) do
    if line ~= "" and not existing_dirs[line] then
      local s = uv.fs_stat(line)
      if s and s.type == "directory" then
        local file = io.open(CACHE_FILE, "a")
        if file then
          file:write(line .. "\n")
          file:close()
          new_count = new_count + 1
        end
      end
    end
  end
  
  if callback then
    callback()
  end
end

function M.load_cache()
  local uv = vim.uv or vim.loop
  local stat = uv.fs_stat(CACHE_FILE)
  
  if not stat then
    return {}
  end
  
  local file = io.open(CACHE_FILE, "r")
  if not file then
    return {}
  end
  
  local dirs = {}
  for line in file:lines() do
    if line ~= "" then
      table.insert(dirs, line)
    end
  end
  file:close()
  
  return dirs
end

function M.get_cache_file()
  return CACHE_FILE
end

return M
