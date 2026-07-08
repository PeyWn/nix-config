{ ... }:
{
  flake.modules.nixos.home = { pkgs, username, scheme, ... }:
    let
      isEverforest = scheme.slug == "everforest" || scheme.slug == "everforest-light";

      lazyvimColorschemePlugin =
        if isEverforest then ''
          return {
            "sainnhe/everforest",
            lazy = false,
            priority = 1000,
            config = function()
              vim.g.everforest_background = "medium"
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
      home-manager.users.${username} = {
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
                      enbaled = true,
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
    };
}
