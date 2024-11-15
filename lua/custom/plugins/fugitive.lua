return {
	"tpope/vim-fugitive",
	config = function()
		vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

		local emilio_fugitive = vim.api.nvim_create_augroup("emilio_fugitive", {})

		local autocmd = vim.api.nvim_create_autocmd
		autocmd("BufWinEnter", {
			group = emilio_fugitive,
			pattern = "*",
			callback = function()
				if vim.bo.ft ~= "fugitive" then
					return
				end

				local bufnr = vim.api.nvim_get_current_buf()
				local opts = { buffer = bufnr, remap = false }
				vim.keymap.set("n", "<leader>gp", function()
					vim.cmd.Git("push")
				end, opts)

				vim.keymap.set("n", "<leader>gf", function()
					vim.cmd.Git("push --force")
				end, opts)

				-- rebase always
				vim.keymap.set("n", "<leader>gP", function()
					vim.cmd.Git({ "pull" })
				end, opts)

				vim.keymap.set("n", "<leader>gt", ":Git push -u origin ", opts)
			end,
		})
	end,
}
