local M = {}

M.set_colorscheme = function()
  vim.cmd.colorscheme("oxocarbon")
  vim.api.nvim_set_hl(0, "Normal", { fg = "#c0caf5", bg = "#010220" })
  vim.api.nvim_set_hl(0, "Function", { fg = "#ff17ff" })
  vim.api.nvim_set_hl(0, "String", { fg = "#10ff14" })
end

return M