---------- jh custom keymap start ----------
vim.keymap.set('i', 'jk', '<Esc>')
vim.keymap.set('i', 'kj', '<Esc>')
vim.keymap.set('t', 'jk', [[<C-\><C-n>]], { noremap = true })
vim.keymap.set('t', 'kj', [[<C-\><C-n>]], { noremap = true })

-- easy python run
vim.keymap.set('c', 'py', '!python %', { noremap = true })

-- easy directory move
vim.keymap.set('c', 'C', 'cd %:p:h', { noremap = true })

-- netrw
vim.keymap.set('c', 'E', 'Ex', { noremap = true })

-- easy cursor open
vim.keymap.set('c', 'cu', '!cursor .', { noremap = true })

-- tree style
vim.g.netrw_liststyle = 3

-- Comment with vscode keymap
vim.keymap.set('n', '<C-_>', 'gcc', { noremap = false, remap = true, desc = 'Toggle comment line' })
vim.keymap.set('v', '<C-_>', 'gc',  { noremap = false, remap = true, desc = 'Toggle comment selection' })

-- save with ctr+s
vim.keymap.set({ 'n', 'i', 'v' }, '<C-s>', '<Esc>:w<CR>', { noremap = true, silent = true })

-- half page up keymap: deprecated due to neoscroll
-- vim.keymap.set({ 'n', 'v' }, '<C-f>', '<C-u>', { noremap = true, silent = true })
-- vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'FileType' }, {
--   callback = function(args)
--     vim.keymap.set({ 'n', 'i' }, '<C-f>', '<C-u>', {
--       buffer = args.buf,
--       noremap = true,
--       silent = true,
--     })
--   end,
-- })
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lazy', 'mason' },
  callback = function(args)
    vim.schedule(function()
      vim.keymap.set({ 'n', 'i' }, '<C-f>', function() require('neoscroll').ctrl_u({ duration = 12.5; easing = 'cubic' }) end, {
        buffer = args.buf,
        noremap = true,
        silent = true,
      })
    end)
  end,
})

-- H-M, L-M midpoint
vim.keymap.set({ 'n', 'v' }, 'HH', function()
  vim.cmd 'normal! H'
  local high = vim.fn.line '.'
  vim.cmd 'normal! M'
  local mid = vim.fn.line '.'
  local target = math.floor((high + mid) / 2)
  vim.cmd('normal! ' .. target .. 'G')
end, { noremap = true, silent = true, desc = 'Move to H-M midpoint' })
vim.keymap.set({ 'n', 'v' }, 'LL', function()
  vim.cmd 'normal! L'
  local low = vim.fn.line '.'
  vim.cmd 'normal! M'
  local mid = vim.fn.line '.'
  local target = math.floor((low + mid) / 2)
  vim.cmd('normal! ' .. target .. 'G')
end, { noremap = true, silent = true, desc = 'Move to L-M midpoint' })

-- Visual markers for fast move
vim.api.nvim_set_hl(0, "HMLMarkHL", { fg = "#f5f2f0", bold = true })
vim.fn.sign_define("HMLMark", { text = "", texthl = "", numhl = "HMLMarkHL" })
local function update_hml_signs()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.fn.sign_unplace("HMLGroup", { buffer = bufnr })
  local topline = vim.fn.line("w0")
  local botline = vim.fn.line("w$")
  local midline = math.floor((topline + botline) / 2)
  local hh = math.floor((topline + midline) / 2)
  local ll = math.floor((botline + midline) / 2)
  for _, lnum in ipairs({ topline, midline, botline, hh, ll }) do
    if lnum ~= vim.fn.line('.') then
      pcall(function()
        vim.fn.sign_place(0, "HMLGroup", "HMLMark", bufnr, { lnum = lnum, priority = 90 })
      end)
    end
  end
end
vim.api.nvim_create_autocmd({ "CursorMoved", "WinScrolled", "BufWinEnter" }, {
  callback = update_hml_signs,
})

-- for useful terminal
vim.api.nvim_create_user_command('T', function()
  vim.cmd 'split | terminal'
  vim.cmd 'startinsert'
end, {})

-- sizing window
vim.keymap.set('n', '<Up>', '4<C-w>+', { noremap = true, silent = true })
vim.keymap.set('n', '<Down>', '4<C-w>-', { noremap = true, silent = true })
vim.keymap.set('n', '<Right>', '4<C-w>>', { noremap = true, silent = true })
vim.keymap.set('n', '<Left>', '4<C-w><', { noremap = true, silent = true })

-- move fast to git diff hunk
vim.keymap.set('n', ']c', function()
  if vim.wo.diff then
    return ']c'
  end
  vim.schedule(function()
    require('gitsigns').nav_hunk 'next'
  end)
  return '<Ignore>'
end, { expr = true, desc = 'next_hunk' })
vim.keymap.set('n', '[c', function()
  if vim.wo.diff then
    return '[c'
  end
  vim.schedule(function()
    require('gitsigns').nav_hunk 'prev'
  end)
  return '<Ignore>'
end, { expr = true, desc = 'prev_hunk' })

-- easy git diff
vim.api.nvim_create_user_command('Gitdiff', function()
  vim.cmd 'vs'
  vim.cmd 'Gitsigns show'
  vim.cmd 'diffthis'
  vim.cmd 'wincmd h'
  vim.cmd 'diffthis'
end, {})

-- Neotree open/close and focus/unfocus
vim.keymap.set('n', '<Space>E', function()
  vim.cmd('Neotree toggle')
  vim.cmd('wincmd =')
end, { noremap = true, silent = true, desc = 'Neotree toggle and resize windows' })
-- Check if the current window's filetype is neo-tree, then act conditionally
vim.keymap.set('n', '<Space>e', function()
  local buftype = vim.api.nvim_get_option_value('filetype', { buf = 0 })
  if buftype == "neo-tree" then
    vim.cmd('wincmd p')
  else
    vim.cmd('Neotree focus')
  end
end, { noremap = true, silent = true, desc = 'Neotree focus or previous window' })

-- Custom python REPL: auto terminal create or find existing terminal
local eol = vim.fn.has('win32') == 1 and '\r\n' or '\n'
local function get_or_open_terminal()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == 'terminal' then
      local job_id = vim.b[buf].terminal_job_id
      if job_id then
        return job_id, buf
      end
    end
  end
  local launched_ipy = false
  local term_cmd = nil
  if vim.fn.executable 'ipython' == 1 then
    term_cmd = 'ipython'
    launched_ipy = true
  elseif vim.fn.executable 'python' == 1 then
    vim.fn.system({ 'python', '-c', 'import IPython' })
    if vim.v.shell_error == 0 then
      term_cmd = 'python -m IPython'
      launched_ipy = true
    else
      term_cmd = 'python'
      launched_ipy = false
    end
  elseif vim.fn.executable 'py' == 1 then
    vim.fn.system({ 'py', '-c', 'import IPython' })
    if vim.v.shell_error == 0 then
      term_cmd = 'py -m IPython'
      launched_ipy = true
    else
      term_cmd = 'py'
      launched_ipy = false
    end
  else
    term_cmd = 'python'
    launched_ipy = false
  end
  vim.cmd('sp | term ' .. term_cmd)
  vim.schedule(function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-w>k', true, false, true), 'n', false)
  end)
  local new_buf = vim.api.nvim_get_current_buf()
  vim.b.terminal_is_ipython = launched_ipy
  return vim.b.terminal_job_id, new_buf
end
local function is_ipython_buf(buf)
  if buf and vim.b[buf] and type(vim.b[buf].terminal_is_ipython) ~= 'nil' then
    return vim.b[buf].terminal_is_ipython
  end
  if buf then
    local prompt_lines = vim.api.nvim_buf_get_lines(buf, -2, -1, false)
    local last_line = prompt_lines[1] or ''
    if last_line:find('In %[%n+%]:%s*$') or last_line:find('In %[%d+%]:%s*$') then
      return true
    end
  end
  return false
end
local function get_repl_eol(term_buf)
  if is_ipython_buf(term_buf) then
    return '\n'
  end
  return eol
end
-- Normal mode: run current line
vim.keymap.set('n', '<CR>', function()
  if vim.bo.filetype ~= "python" then return end
  local job_id, term_buf = get_or_open_terminal()
  local line = vim.fn.getline '.'
  if term_buf then
    local prompt_lines = vim.api.nvim_buf_get_lines(term_buf, -2, -1, false)
    local last_line = prompt_lines[1] or ""
    if last_line:find(">>>%s*$") or last_line:find("In %[%d+%]:%s*$") or last_line:find("%s*%.%.%.:%s*$") then
      line = line:gsub('^%s+', '')
    end
  end
  local repl_eol = get_repl_eol(term_buf)
  vim.fn.chansend(job_id, line .. repl_eol)
  vim.schedule(function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-w>j', true, false, true), 'n', false)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('i', true, false, true), 'n', false)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes([[<C-\><C-n>]], true, false, true), 't', false)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-w>k', true, false, true), 'n', false)
    vim.api.nvim_feedkeys('j', 'n', false)
  end)
end, { desc = 'Send current line to terminal ipython' })
-- Visual mode: run selected lines
vim.keymap.set('v', '<CR>', function()
  if vim.bo.filetype ~= "python" then return end
  local job_id, _ = get_or_open_terminal()
  local repl_eol = get_repl_eol(_)
  local mode = vim.fn.mode()
  local selection
  if mode == 'v' or mode == 'V' then
    local reg_backup = vim.fn.getreg('"')
    vim.cmd('normal! ""y')
    selection = vim.fn.getreg('"')
    vim.fn.setreg('"', reg_backup)
  else
    selection = ""
  end
  local lines = {}
  for line in selection:gmatch("([^\n]+)") do
    table.insert(lines, line)
  end
  local min_indent = math.huge
  for _, line in ipairs(lines) do
    if line:match('%S') then
      local _, spaces = line:find('^%s*')
      if spaces and spaces < min_indent then min_indent = spaces end
    end
  end
  min_indent = min_indent == math.huge and 0 or min_indent
  local prev_indent = min_indent
  for _, line in ipairs(lines) do
    local curr_indent = #(line:match('^%s*'))
    if curr_indent == min_indent and prev_indent > min_indent then
      vim.fn.chansend(job_id, repl_eol)
    end
    local deindented = (min_indent > 0) and line:gsub('^' .. string.rep(' ', min_indent), '') or line
    vim.fn.chansend(job_id, deindented .. repl_eol)
    prev_indent = curr_indent
  end
  vim.fn.chansend(job_id, repl_eol)
  local end_line = vim.fn.line("'>")
  vim.schedule(function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-w>j', true, false, true), 'n', false)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('i', true, false, true), 'n', false)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes([[<C-\><C-n>]], true, false, true), 't', false)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-w>k', true, false, true), 'n', false)
    vim.api.nvim_win_set_cursor(0, {end_line, 1})
    vim.api.nvim_feedkeys('j', 'n', false)
  end)
end, { desc = 'Send visual selection to terminal ipython' })

-- Open unsupported format in exteranl program
vim.api.nvim_create_user_command('O', function()
  vim.cmd '!start "" "%"'
end, {})

---------- jh custom keymap end ----------

-- Set tab as 4-spaces always
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
-- If there is a problem try followings
-- :set noexpandtab tabstop=4 shiftwidth=4 softtabstop=4
-- :retab

-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
vim.opt.number = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.wrap = false
vim.opt.sidescroll = 1
vim.opt.sidescrolloff = 5

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = false

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 150

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
-- vim.opt.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.opt.confirm = true

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

--  Use CTRL+<hjkl> to switch between windows
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require('lazy').setup({
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      -- this setting is independent of vim.opt.timeoutlen
      delay = 0,
      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },

      -- Document existing key chains
      spec = {
        { '<leader>c', group = '[C]ode', mode = { 'n', 'x' } },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',
        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',
        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- [[ Configure Telescope ]]
      require('telescope').setup {
        -- defaults = {
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
        -- },
        -- pickers = {}
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Buffers',
        }
      end, { desc = '[S]earch [/] in Open Buffers' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by nvim-cmp
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      if vim.g.vscode then
        return
      end
      require('mason-lspconfig').setup {
        ensure_installed = { 'pyright' },
        automatic_installation = true,
      }
      require('mason-tool-installer').setup {
        ensure_installed = {
          'ruff',
          'black',
        },
        automatic_installation = true,
      }
      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              ---@diagnostic disable-next-line: param-type-mismatch
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        -- clangd = {},
        -- gopls = {},
        pyright = {},
        -- rust_analyzer = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`ts_ls`) will work just fine
        -- ts_ls = {},
        --

        lua_ls = {
          -- cmd = { ... },
          -- filetypes = { ... },
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --
      -- To check the current status of installed tools and/or manually install
      -- other tools, you can run
      --    :Mason
      --
      -- You can press `g?` for help in this menu.
      --
      -- `mason` had to be setup earlier: to configure its options see the
      -- `dependencies` table for `nvim-lspconfig` above.
      --
      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
        'black',
        'ruff',
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = { 'pyright' }, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        automatic_installation = true,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = false,
      -- format_on_save = function(bufnr)
      --   -- Disable "format_on_save lsp_fallback" for languages that don't
      --   -- have a well standardized coding style. You can add additional
      --   -- languages here or re-enable it for the disabled ones.
      --   local disable_filetypes = { c = true, cpp = true }
      --   if disable_filetypes[vim.bo[bufnr].filetype] then
      --     return nil
      --   else
      --     return {
      --       timeout_ms = 5000,
      --       lsp_format = 'fallback',
      --     }
      --   end
      -- end,
      formatters_by_ft = {
        lua = { 'stylua' },
        -- Conform can also run multiple formatters sequentially
        python = { 'ruff_fix', 'black' },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
      },
      'saadparwaiz1/cmp_luasnip',

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp-signature-help',
    },
    config = function()
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert {
          -- Select the [n]ext item
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ['<C-y>'] = cmp.mapping.confirm { select = true },

          -- If you prefer more traditional completion keymaps,
          -- you can uncomment the following lines
          ['<CR>'] = cmp.mapping.confirm { select = true },
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ['<C-Space>'] = cmp.mapping.complete {},

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },
        sources = {
          {
            name = 'lazydev',
            -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
            group_index = 0,
          },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
          { name = 'nvim_lsp_signature_help' },
        },
      }
    end,
  },

  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('tokyonight').setup {
        styles = {
          comments = { italic = false }, -- Disable italics in comments
        },
      }

      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      -- jh memorize: (visual mode)sa, (normal mode)sd, (normal mode)sr -> add, delete, replace
      require('mini.surround').setup {
        custom_surroundings = {
          ['('] = { output = { left = '(', right = ')' } },
          ['['] = { output = { left = '[', right = ']' } },
          ['{'] = { output = { left = '{', right = '}' } },
        },
      }

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'python' },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },
  {
    'goolord/alpha-nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'MaximilianLloyd/ascii.nvim',
    },
    config = function()
      require('alpha').setup(require('alpha.themes.dashboard').config)
    end,
    opts = function()
      local dashboard = require 'alpha.themes.dashboard'
      dashboard.section.header.val = require('ascii').art.text.neovim.sharp
      dashboard.section.buttons.val = {}
      local footers = {
        'Head up and play smart',
        'Eyes on the road',
        'Wait for the wind, Power of consistency, Positive thinking',
        'Always stay humble, and learn from everyone as if they were your teacher',
        'You don\'t need more time. You need more focus'
      }
      math.randomseed(os.time())
      dashboard.section.footer.val = footers[math.random(1, #footers)]
      local total_lines = vim.o.lines
      local header_lines = #dashboard.section.header.val
      local footer_lines = 1
      local vertical_space = total_lines - (header_lines + footer_lines)
      local top_padding = math.floor(vertical_space / 2.5)
      local between_padding = 3
      dashboard.config.layout = {
        { type = 'padding', val = top_padding },
        dashboard.section.header,
        { type = 'padding', val = between_padding },
        dashboard.section.footer,
      }
      return dashboard.opts
    end,
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    cmd = 'Neotree',
    config = function()
      require('neo-tree').setup {
        filesystem = {
          follow_current_file = { enabled = true },
          filtered_items = { hide_dotfiles = false },
          window = {
            -- custom key mappings
            mappings = {
              ['<C-f>'] = 'scroll_up',
              ['H'] = 'first_sibling',
              ['hh'] = 'toggle_hidden',
              ['e'] = 'expand_all_nodes',
            },
          },
        },
      }
    end,
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      require('nvim-autopairs').setup {}
    end,
  },
  {
    'karb94/neoscroll.nvim',
    event = 'VimEnter',
    config = function()
      require('neoscroll').setup {
        mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>', 'zt', 'zz', 'zb' },
        hide_cursor = true,
        stop_eof = true,
        respect_scrolloff = false,
        cursor_scrolls_alone = true,
        duration_multiplier = 0.05,
        easing = 'cubic',
        pre_hook = nil,
        post_hook = nil,
        performance_mode = true,
        ignored_events = { 'WinScrolled', 'CursorMoved' },
      }
      local neoscroll = require('neoscroll')
      local keymap = {
        ["<C-f>"] = function() neoscroll.ctrl_u({ duration = 12.5; easing = 'cubic' }) end;
      }
      local modes = { 'n', 'v', 'x' }
      for key, func in pairs(keymap) do
          vim.keymap.set(modes, key, func)
      end
    end,
  },
  {
    'sphamba/smear-cursor.nvim',
    opts = {},
    init = function()
      -- enable by default
      require('smear_cursor').setup {
        stiffness = 0.8,
        trailing_stiffness = 0.5,
        distance_stop_animating = 0.5,
      }
    end,
  },
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
