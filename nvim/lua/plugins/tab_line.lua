return {
  "rafcamlet/tabline-framework.nvim",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    local colors = {
      black = "#000000",
      tabs_text = "#c677dd",
      normal_mode = "#98c379",
      tab_bg = "#31353f",
      unselected_tab_bg = "#3e4452",
      unselected_tab_text = "#abb2bf",
    }
    -- TABS > file name[+]
    local render = function(f)
      f.add({" TABS ", fg = colors.black, bg = colors.tabs_text})

      f.make_tabs(function(info)
        if info.index == 1 then
          f.add({" ", fg = colors.tabs_text, bg = info.current and colors.normal_mode or colors.unselected_tab_bg})
        elseif info.index > 1 then
          if info.current then
            f.add({" ", fg = colors.unselected_tab_bg, bg = colors.normal_mode})
          elseif info.after_current then
            f.add({" ", fg = colors.normal_mode, bg = colors.unselected_tab_bg})
          else
            f.add({" ", fg = colors.unselected_tab_text, bg = colors.unselected_tab_bg})
          end
        end

        if info.filename then
          local fn
          if info.filename == "NvimTree_2" then
            fn = "Tree"
          else
            fn = info.filename
          end
          if info.current then
            f.add({fn, fg = colors.black, bg = colors.normal_mode})
          else
            f.add({fn, fg = colors.unselected_tab_text, bg = colors.unselected_tab_bg})
          end
          if info.current then
            f.add({info.modified and "[+]", fg = colors.black, bg = colors.normal_mode})
          else
            f.add({info.modified and "[+]", fg = colors.unselected_tab_text, bg = colors.unselected_tab_bg})
          end
          f.add({' ', bg = info.current and colors.normal_mode or colors.unselected_tab_bg})
        else
          f.add(info.modified and "[+]" or "[-]")
        end

        if info.last then
          f.add({"", fg = info.current and colors.normal_mode or colors.unselected_tab_bg, bg = colors.tab_bg})
        end

      end)

      f.add_spacer()
    end

    require("tabline_framework").setup { render = render }
  end,
}
