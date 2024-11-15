vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.inccommand = "split"

vim.opt.smartcase = true
vim.opt.ignorecase = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.signcolumn = "yes"
vim.opt.shada = { "'10", "<0", "s10", "h" }

vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.smartindent = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.updatetime = 50
vim.opt.conceallevel = 0

vim.opt.showmode = false
vim.opt.scrolloff = 8

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
