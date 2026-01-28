{
  nixvim,
  system,
  gdb,
  mdx07-simserver,
  vimPlugins,
}:
nixvim.legacyPackages.${system}.makeNixvimWithModule {
  inherit system;
  module = _: {
    opts = {
      termguicolors = false;
    };

    userCommands = {
      "MDx07StartSimserver" = {
        command.__raw = ''
          function()
            vim.system({'${mdx07-simserver}/bin/simserver'})
          end
        '';
        desc = "Start the MDx07 simserver";
      };
      "MDx07StopSimserver" = {
        command.__raw = ''
          function()
            vim.system({'pkill', 'simserver'})
          end
        '';
        desc = "Stop the MDx07 simserver";
      };
      "MDx07ToggleUI" = {
        command.__raw = ''
          function()
            require('dapui').toggle()
          end
        '';
        desc = "Toggle the debugging UI";
      };
    };

    lsp = {
      servers = {
        asm_lsp.enable = true;
        clangd.enable = true;
      };
    };

    plugins = {
      lspconfig.enable = true;

      treesitter = {
        enable = true;
        grammarPackages = with vimPlugins.nvim-treesitter.builtGrammars; [
          asm
          c
          make
        ];

        settings.highlight.enable = true;
      };

      dap = {
        enable = true;
        signs = {
          dapBreakpoint.text = "";
          dapBreakpoint.texthl = "DapBreakpoint";
          dapStopped.text = "";
          dapStopped.texthl = "DapUIPlayPause";
        };
        adapters.mdx07-gdb.__raw = ''
          {
            type = "executable",
            command = "${gdb}/bin/gdb",
            args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
          }
        '';
        configurations.asm = [
          {
            name = "(MDx07) Debug program on simserver:1234";
            type = "mdx07-gdb";
            request = "attach";
            cwd = "\${workspaceFolder}";
            program = "\${workspaceFolder}/build/\${workspaceFolderBasename}.elf";
            target = "localhost:1234";
          }
        ];
        luaConfig.post = ''
          local dap = require('dap')
          local dapui = require('dapui')
          dap.listeners.after.attach["mdx07-handlers"] = function()
            local repl = require('dap.repl')
            repl.execute('monitor reset halt')
            repl.execute('load')
            repl.execute('break main')
            repl.execute('continue')
          end
          dap.listeners.after.reset["mdx07-handlers"] = function()
            local repl = require('dap.repl')
            repl.execute('monitor reset halt')
            repl.execute('load')
            repl.execute('break main')
            repl.execute('continue')
          end
          dap.listeners.before.attach.dapui_config = function()
            dapui.open()
          end
          dap.listeners.before.launch.dapui_config = function()
            dapui.open()
          end
          dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
          end
          dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
          end
        '';
      };

      dap-ui = {
        enable = true;
        settings = {
          layouts = [
            {
              position = "left";
              size = 50;
              elements = [
                {
                  id = "scopes";
                  size = 0.50;
                }
                {
                  id = "breakpoints";
                  size = 0.25;
                }
                {
                  id = "stacks";
                  size = 0.25;
                }
              ];
            }
            {
              position = "bottom";
              size = 13;
              elements = [
                {
                  id = "repl";
                  size = 1.0;
                }
              ];
            }
          ];
        };
      };

    };
  };
}
