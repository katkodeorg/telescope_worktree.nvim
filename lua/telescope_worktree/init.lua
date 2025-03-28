local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local M = {}

M.create_worktree = function(opts)
  local handle = io.popen("git branch --all --format='%(refname:short)' 2>/dev/null")
  if not handle then
    print("Failed to list git branches.")
    return
  end

  local branches = {}
  for branch in handle:lines() do
    table.insert(branches, branch)
  end
  handle:close()

  if #branches == 0 then
    print("No branches found!")
    return
  end

  pickers
    .new(opts, {
      prompt_title = "Select Branch for Worktree",
      finder = finders.new_table({
        results = branches,
      }),

      sorter = conf.generic_sorter({}),

      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          local new_brach_input = action_state.get_current_line()
          local branch = selection and selection[1] or new_brach_input

          -- closes the popup
          actions.close(prompt_bufnr)

          if branch then
            function parse_branch_name(bn)
              -- Get the list of remotes from git
              local remotes = vim.fn.systemlist("git remote")

              -- Loop through all remotes and check if the branch name starts with any remote
              for _, remote in ipairs(remotes) do
                local remote_prefix = remote .. "/"

                -- Check if branch name starts with the remote prefix (e.g., "origin/" or "feature/")
                if bn:sub(1, #remote_prefix) == remote_prefix then
                  -- If it matches, remove the prefix and return the branch name
                  return bn:sub(#remote_prefix + 1)
                end
              end

              -- Return the branch name as is if no valid remote prefix is found
              return bn
            end

            local branch_name = parse_branch_name(branch)

            -- Get the repo name
            local repo_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")

            -- Sanitize the branch name (remove special characters, replace `/` with `_`)
            local safe_branch = branch_name:gsub("[^%w-_]", "_"):gsub("/", "_")

            local default_path = "../" .. repo_name .. "_" .. safe_branch

            -- Prompt the user for a path, defaulting to reponame_branchname
            local user_input = vim.fn.input("Worktree path: ", default_path, "file")

            -- Use user input if provided, else default to reponame_branchname
            local path = user_input ~= "" and user_input or default_path

            if path ~= "" then
              local function branch_exists_remotely(b)
                local cmd = { "git", "show-ref", "refs/remotes/" .. b }
                local result = vim.system(cmd):wait()
                return result.code == 0
              end

              local command
              if branch_exists_remotely(branch) then
                command = { "git", "worktree", "add", "--track", "-b", branch_name, path, "refs/remotes/" .. branch }
              else
                command = { "git", "worktree", "add", "-b", branch_name, path }
              end

              vim.notify("Creating worktree using: " .. table.concat(command, " "), vim.log.levels.INFO)
              local cwd = vim.fn.getcwd()

              vim.system(command, { cwd = cwd }, function(obj)
                vim.schedule(function()
                  if obj.code == 0 then
                    vim.notify("✅ Worktree created successfully at " .. path, vim.log.levels.INFO)
                  else
                    vim.notify("❌ Error creating worktree: " .. obj.stderr, vim.log.levels.ERROR)
                  end
                end)
              end)
            else
              print("Invalid path!")
            end
          end
        end)

        return true
      end,
    })
    :find()
end

return M
