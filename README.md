# telescope_worktree.nvim

*telescope_worktree* is a [Telescope](https://github.com/nvim-telescope/telescope.nvim) extension that searches a Git branch (Remote or local) and creates a new worktreee in the directory specified.

<img width="1440" alt="image" src="https://github.com/user-attachments/assets/529ce3bf-889d-40b4-afad-96bb4efbb783" />


The [telescope_worktree.nvim](https://github.com/katkodeorg/telescope_worktree.nvim) extension is excellent for working with feature branches, where changing the branch requires a build or compile to work with the changes. It leverages git worktrees to work on multiple branches simultaneously and independently.


The extension uses this command to create a [git-worktree](https://git-scm.com/docs/git-worktree) from the remote branch
```bash
git worktree add --track -b <branch> <path> <remote>/<branch>
```

## Installation 

You can install these plugin using your favorite vim package manager, e.g.
[vim-plug](https://github.com/junegunn/vim-plug) and
[lazy](https://github.com/folke/lazy.nvim).

**lazy**:
```lua
{ 'katkodeorg/telescope_worktree.nvim' },
```

**vim-plug**
```VimL
Plug 'https://github.com/katkodeorg/telescope_worktree.nvim'
```


## Usage

Activate the `telescope_worktree.nvim` extension by adding

```lua
{
    'nvim-telescope/telescope.nvim',
    dependencies = {
--     ...
      { 'katkodeorg/telescope_worktree.nvim' },
--     ...
    },
--  ...
}
```

Somewhere after your `require('telescope').setup()` call add:
```lua
pcall(require('telescope').load_extension, 'telescope_worktree')
```

Example to bind it to `<leader>wt` use:

```lua
local extensions = require('telescope').extensions
vim.keymap.set('n', '<leader>wt', function()
  extensions.telescope_worktree.create_worktree()
end, { desc = '[W]ork tree [C]reate' })
```

