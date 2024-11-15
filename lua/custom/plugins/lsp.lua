return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"folke/neodev.nvim",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			{ "j-hui/fidget.nvim", opts = {} },
			{ "https://git.sr.ht/~whynothugo/lsp_lines.nvim" },

			-- Autoformatting
			"stevearc/conform.nvim",

			-- Schema information
			"b0o/SchemaStore.nvim",
		},
		config = function()
			require("neodev").setup({
				-- library = {
				--   plugins = { "nvim-dap-ui" },
				--   types = true,
				-- },
			})

			local capabilities = nil
			if pcall(require, "cmp_nvim_lsp") then
				capabilities = require("cmp_nvim_lsp").default_capabilities()
			end

			require("mason").setup()
			local mason_registry = require("mason-registry")

			local function get_omnisharp_path()
				local omnisharp_pkg = mason_registry.get_package("omnisharp")
				return omnisharp_pkg:get_install_path() .. "/libexec/OmniSharp.dll"
			end

			local lspconfig = require("lspconfig")
			local servers = {
				omnisharp = {
					cmd = { "dotnet", get_omnisharp_path() },
					settings = {
						FormattingOptions = {
							EnableEditorConfigSupport = true,
							OrganizeImports = nil,
						},
						MsBuild = {
							LoadProjectsOnDemand = nil,
						},
						RoslynExtensionsOptions = {
							EnableAnalyzersSupport = nil,
							EnableImportCompletion = nil,
							AnalyzeOpenDocumentsOnly = nil,
						},
						Sdk = {
							IncludePrereleases = true,
						},
					},
				},

				gopls = {
					settings = {
						gopls = {
							hints = {
								assignVariableTypes = true,
								compositeLiteralFields = true,
								compositeLiteralTypes = true,
								constantValues = true,
								functionTypeParameters = true,
								parameterNames = true,
								rangeVariableTypes = true,
							},
						},
					},
				},

				lua_ls = {
					server_capabilities = {
						semanticTokensProvider = vim.NIL,
					},
				},

				rust_analyzer = true,
				pyright = true,
				biome = true,
				tsserver = {
					server_capabilities = {
						documentFormattingProvider = false,
					},
				},
				jsonls = {
					server_capabilities = {
						documentFormattingProvider = false,
					},
					settings = {
						json = {
							schemas = require("schemastore").json.schemas(),
							validate = { enable = true },
						},
					},
				},
				yamlls = {
					settings = {
						yaml = {
							schemaStore = {
								enable = false,
								url = "",
							},
						},
					},
				},
				elixirls = {
					cmd = { "/Users/emiliopalmerini/.local/share/nvim/mason/bin/elixir-ls" },
					root_dir = require("lspconfig.util").root_pattern({ "mix.exs" }),
					server_capabilities = {
						documentFormattingProvider = false,
					},
				},
				tailwindcss = {
					init_options = {
						userLanguages = {
							elixir = "phoenix-heex",
							eruby = "erb",
							heex = "phoenix-heex",
						},
					},
					settings = {
						tailwindCSS = {
							experimental = {
								classRegex = {
									[[class: "([^"]*)]],
								},
							},
						},
					},
				},
			}

			local servers_to_install = vim.tbl_filter(function(key)
				local t = servers[key]
				if type(t) == "table" then
					return not t.manual_install
				else
					return t
				end
			end, vim.tbl_keys(servers))

			local ensure_installed = {
				"stylua",
				"lua_ls",
				"delve",
				"omnisharp",
			}

			vim.list_extend(ensure_installed, servers_to_install)
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			for name, config in pairs(servers) do
				if config == true then
					config = {}
				end
				config = vim.tbl_deep_extend("force", {}, {
					capabilities = capabilities,
				}, config)

				lspconfig[name].setup(config)
			end

			local disable_semantic_tokens = {
				lua = true,
			}

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local bufnr = args.buf
					local client = assert(vim.lsp.get_client_by_id(args.data.client_id), "must have valid client")

					local settings = servers[client.name]
					if type(settings) ~= "table" then
						settings = {}
					end

					local builtin = require("telescope.builtin")

					vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
					vim.keymap.set("n", "gd", builtin.lsp_definitions, { buffer = 0 })
					vim.keymap.set("n", "gr", builtin.lsp_references, { buffer = 0 })
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = 0 })
					vim.keymap.set("n", "gi", builtin.lsp_implementations, { buffer = 0 })
					vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, { buffer = 0 })
					vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = 0 })

					vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, { buffer = 0 })
					vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, { buffer = 0 })
					vim.keymap.set("n", "<space>wd", builtin.lsp_document_symbols, { buffer = 0 })

					local filetype = vim.bo[bufnr].filetype
					if disable_semantic_tokens[filetype] then
						client.server_capabilities.semanticTokensProvider = nil
					end

					-- Override server capabilities
					if settings.server_capabilities then
						for k, v in pairs(settings.server_capabilities) do
							if v == vim.NIL then
								---@diagnostic disable-next-line: cast-local-type
								v = nil
							end

							client.server_capabilities[k] = v
						end
					end
				end,
			})

			-- Autoformatting Setup
			local conform = require("conform")
			conform.setup({
				formatters_by_ft = {
					lua = { "stylua" },
					blade = { "blade-formatter" },
				},
			})

			conform.formatters.injected = {
				options = {
					ignore_errors = false,
					lang_to_formatters = {
						sql = { "sleek" },
					},
				},
			}

			vim.api.nvim_create_autocmd("BufWritePre", {
				callback = function(args)
					require("conform").format({
						bufnr = args.buf,
						lsp_fallback = true,
						quiet = true,
					})
				end,
			})

			require("lsp_lines").setup()
			vim.diagnostic.config({ virtual_text = true, virtual_lines = false })

			vim.keymap.set("", "<leader>l", function()
				local config = vim.diagnostic.config() or {}
				if config.virtual_text then
					vim.diagnostic.config({ virtual_text = false, virtual_lines = true })
				else
					vim.diagnostic.config({ virtual_text = true, virtual_lines = false })
				end
			end, { desc = "Toggle lsp_lines" })
		end,
	},
}
