return {
  {
    "loctvl842/monokai-pro.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      filter = "spectrum",
    },
    config = function(_, opts)
      require("monokai-pro").setup(opts)
      vim.cmd.colorscheme("monokai-pro")

      -- Custom overrides applied after colorscheme loads
      local function set_hl(group, val)
        vim.api.nvim_set_hl(0, group, val)
      end

      set_hl("@variable.parameter", { fg = "#ffffff" })
      set_hl("@punctuation.bracket", { fg = "#a0a0a0" })
      -- Specific color overrides
      set_hl("@keyword.type", { fg = "#fc618d" })    -- "type" and "struct" → red
      set_hl("@type", { fg = "#7bd9f7" })            -- "Song" → blue
      set_hl("@type.definition", { fg = "#7bd9f7" }) -- ← add here
      set_hl("@property.yaml", { fg = "#fc9867" })   -- keys → orange
      set_hl("@string.yaml", { fg = "#ffffff" })     -- values → white
      set_hl("SnacksIndentScope", { fg = "#c0c0c0" })
      -- Remove italics from common captures
      for _, group in ipairs({
        "@keyword",
        "@keyword.function",
        "@keyword.type",
        "@keyword.return",
        "@keyword.conditional",
        "@keyword.repeat",
        "@keyword.operator",
        "@keyword.import",
        "@keyword.modifier",
        "@type",
        "@type.builtin",
        "@type.qualifier",
        "@storageclass",
        "@structure",
        "@variable.parameter",
        "@comment",
      }) do
        local existing = vim.api.nvim_get_hl(0, { name = group, link = false })
        existing.italic = false
        set_hl(group, existing)
      end
    end,
  },
}
