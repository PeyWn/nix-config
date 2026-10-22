{ ... }:
{
  homeManagerModules.lazyvim = { pkgs, scheme, ... }:
    let
      isEverforest = scheme.slug == "everforest-dark" || scheme.slug == "everforest-light";

      lazyvimColorschemePlugin =
        if isEverforest then ''
          return {
            "sainnhe/everforest",
            lazy = false,
            priority = 1000,
            config = function()
              vim.g.everforest_background = "soft"
              vim.o.background = "${if scheme.variant == "dark" then "dark" else "light"}"
              vim.cmd.colorscheme("everforest")
            end
          }
        ''
        else ''
          return {
            "lifepillar/vim-solarized8",
            lazy = false,
            priority = 1000,
            config = function()
              vim.g.solarized_visibility = "high"
              vim.o.background = "${if scheme.variant == "dark" then "dark" else "light"}"
              vim.cmd.colorscheme("solarized8_flat")
            end
          }
        '';
    in
    {
      programs.lazyvim = {
        enable = true;
        pluginSource = "latest";

        extras = {
          ai.claudecode.enable = true;
          lang.nix.enable = true;
          lang.json.enable = true;
          lang.yaml.enable = true;
          lang.markdown.enable = true;
          lang.typescript = {
            enable = true;
            installDependencies = true;
            installRuntimeDependencies = true;
          };
          lang.dotnet.enable = true;
          lang.rust.enable = true;
          lang.toml.enable = true;
          lang.docker.enable = true;
          formatting.prettier.enable = true;
          linting.eslint.enable = true;
          dap.core.enable = true;
        };

        extraPackages = with pkgs; [
          nixd
          vtsls
          alejandra
          prettierd
          eslint
          vscode-langservers-extracted
          ripgrep
          fd
        ];

        plugins = {
          env = ''
            return {
              "tpope/vim-dotenv",
              lazy = false,
              config = function()
                vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
                  pattern = { ".env*", ".env.*" },
                  command = "set filetype=dotenv | setlocal commentstring=#\\ %s",
                })
              end,
            }
          '';
          diffview = ''
            return {
              {
                "sindrets/diffview.nvim",
                cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory", "DiffviewRefresh" },
                keys = {
                  {
                    "<leader>gdd",
                    function()
                      if next(require("diffview.lib").views) == nil then
                        vim.cmd("DiffviewOpen")
                      else
                        vim.cmd("DiffviewClose")
                      end
                    end,
                    desc = "Toggle Diffview",
                  },
                  { "<leader>gdf", "<cmd>DiffviewFileHistory %<cr>", desc = "File history (buffer)" },
                  { "<leader>gdF", "<cmd>DiffviewFileHistory<cr>", desc = "File history (repo)" },
                  { "<leader>gdt", "<cmd>DiffviewToggleFiles<cr>", desc = "Toggle file panel" },
                  { "<leader>gdr", "<cmd>DiffviewRefresh<cr>", desc = "Refresh" },
                  { "<leader>gdh", function() require("gitsigns").diffthis() end, desc = "Diff This" },
                  { "<leader>gdH", function() require("gitsigns").diffthis("~") end, desc = "Diff This ~" },
                },
              },
              -- free up <leader>gd for the diff group, move snacks pickers into it
              {
                "folke/snacks.nvim",
                keys = {
                  { "<leader>gd", false },
                  { "<leader>gD", false },
                  { "<leader>gds", function() Snacks.picker.git_diff() end, desc = "Hunks (picker)" },
                  { "<leader>gdS", function() Snacks.picker.git_diff({ base = "origin", group = true }) end, desc = "Hunks vs origin (picker)" },
                },
              },
              {
                "folke/which-key.nvim",
                opts = { spec = { { "<leader>gd", group = "diff" } } },
              },
            }
          '';
          lsp = ''
            return {
              {
                "neovim/nvim-lspconfig",
                opts = {
                  codelens = {
                    enabled = true,
                  },
                  inlay_hints = {
                    enabled = false,
                    exclude = { "javascript", "javascriptreact" },
                  },
                  folds = {
                    enabled = true,
                  },
                  servers = {
                    nixd = {
                      cmd = { "devenv", "lsp" },
                    },
                  },
                },
              },
            }
          '';
          claudecode = ''
            return {
              "coder/claudecode.nvim",
              dependencies = { "folke/snacks.nvim" },
              opts = {
                terminal = {
                  provider = "external",
                  provider_opts = {
                    external_terminal_cmd = "tmux split-window -h %s"
                  }
                }
              },
            }
          '';
          colorscheme = lazyvimColorschemePlugin;
        };
      };

      home.sessionVariables.EDITOR = "nvim";
    };
}
