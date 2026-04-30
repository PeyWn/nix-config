{ inputs, ... }:
{
  flake.modules.homeManager.lazyvim = { pkgs, ... }: {
    imports = [ inputs.lazyvim-nix.homeManagerModules.default ];

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
      };

      extraPackages = with pkgs; [
        # LSP
        nixd
        vtsls


        # Formatters
        alejandra

        # Linters
        eslint

        # Tools
        ripgrep
        fd
      ];

      plugins = {
        env = ''
          return {
            "tpope/vim-dotenv",
            lazy = false, -- load immediately
            config = function()
              -- Automatically set filetype for .env files
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
      };
    };

    home.sessionVariables.EDITOR = "nvim";
  };
}
