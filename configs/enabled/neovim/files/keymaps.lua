-- Keybindings

-- Set leader keys explicitly
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- File tree toggle
vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { noremap = true, silent = true })

-- Directory picker - search only directories in home
vim.keymap.set("n", "<leader>cd", function()
  require("telescope.builtin").find_files({
    cwd = vim.fn.expand("$HOME"),
    find_command = { "fd", "-t", "d" },
    attach_mappings = function(prompt_bufnr, map)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      
      local change_cwd = function()
        local selection = action_state.get_selected_entry()
        if selection then
          local path = selection.path or selection[1]
          if path and path ~= "" then
            vim.cmd("cd " .. vim.fn.fnamemodify(path, ":p"))
            print("Changed directory to: " .. vim.fn.fnamemodify(path, ":p"))
          end
        end
        actions.close(prompt_bufnr)
      end
      
      map("n", "<CR>", change_cwd)
      map("i", "<CR>", change_cwd)
      return true
    end,
  })
end, { noremap = true, silent = true })

-- Find files from $HOME (default)
vim.keymap.set("n", "<leader>f", function()
  require("telescope.builtin").find_files({
    search_dirs = { vim.fn.expand("$HOME") }
  })
end, { noremap = true, silent = true })

-- Directory picker → find files from chosen directory (starts at $HOME)
vim.keymap.set("n", "<leader>F", function()
  require("telescope.builtin").find_files({
    search_dirs = { vim.fn.expand("$HOME") },
    attach_mappings = function(prompt_bufnr, map)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      
      local enter = function()
        local selection = action_state.get_selected_entry()
        local path = selection.Path
        if path and path:is_dir() then
          actions.close(prompt_bufnr)
          vim.defer_fn(function()
            require("telescope.builtin").find_files({
              search_dirs = { selection[1] }
            })
          end, 10)
        else
          actions.select(prompt_bufnr)
        end
      end
      
      map("i", "<CR>", enter)
      return true
    end
  })
end, { noremap = true, silent = true })

-- Find files from current directory
vim.keymap.set("n", "<leader>ff", function()
  require("telescope.builtin").find_files({})
end, { noremap = true, silent = true })

-- Xcode-compatible: find files from current directory
vim.keymap.set("n", "<D-S-o>", function()
  require("telescope.builtin").find_files({})
end, { noremap = true, silent = true })

-- Live grep
vim.keymap.set("n", "<leader>fg", function()
  require("telescope.builtin").live_grep({})
end, { noremap = true, silent = true })

-- Save / Quit
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")
