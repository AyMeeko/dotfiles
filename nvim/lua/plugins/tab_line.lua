return {
  {
    "rafcamlet/tabline-framework.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      local colors = require("catppuccin.palettes").get_palette("macchiato")
      vim.api.nvim_set_hl(0, 'TabLineFill', { bg = colors.base })

      local render = function(f)
        f.set_bg(colors.base)
        f.make_tabs(function(info)
          if info.filename then
            local fn = info.filename
            if info.current then
              f.add({ "", fg = colors.blue, bg = colors.base })
              -- f.add({" ", fg = colors.mantle, bg = colors.blue})
              f.add({ fn, fg = colors.mantle, bg = colors.blue })
              -- f.add({" ", fg = colors.mantle, bg = colors.blue})
              f.add({ info.modified and "[+]", fg = colors.mantle, bg = colors.blue })
              f.add({ " ", fg = colors.blue, bg = colors.base })
            else
              f.add({ "", fg = colors.base, bg = colors.base })
              -- f.add({" ", fg = colors.text, bg = colors.base})
              f.add({ fn, fg = colors.text, bg = colors.base })
              f.add({ info.modified and "[+]", fg = colors.text, bg = colors.mantle })
              -- f.add({" ", fg = colors.text, bg = colors.base})
              f.add({ " ", fg = colors.base, bg = colors.base })
            end
          end
        end)

        f.add_spacer()
      end

      require("tabline_framework").setup { render = render }
    end,
  }
}
