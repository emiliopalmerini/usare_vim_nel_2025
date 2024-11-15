return {
	"nvim-telescope/telescope.nvim",
	event = "VimEnter",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",

			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		{ "nvim-telescope/telescope-ui-select.nvim" },
		"nvim-telescope/telescope-smart-history.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
		"kkharji/sqlite.lua",
	},
	config = function()
		require("custom.telescope")
	end,
}
