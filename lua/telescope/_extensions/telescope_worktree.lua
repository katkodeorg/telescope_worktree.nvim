local telescope_worktree = require('telescope_worktree')

return require("telescope").register_extension {
  exports = {
    create_worktree = telescope_worktree.create_worktree
  },
}
