return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	dependencies = { "nvim-treesitter/nvim-treesitter-context" },
	config = function()
		require("nvim-treesitter.configs").setup({
			modules = {},
			ignore_install = {},
			-- A list of parser names, or "all"
			ensure_installed = {
				"javascript",
				"typescript",
				"c_sharp",
				"lua",
				"rust",
				"go",
				"markdown",
				"markdown_inline",
				"json",
			},
			sync_install = true,
			auto_install = true,
			indent = {
				enable = true,
			},
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = { "markdown" },
			},
		})
	end,
}
