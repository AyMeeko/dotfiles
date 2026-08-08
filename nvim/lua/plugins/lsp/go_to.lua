local M = {}

function M.definition()
  local ok, factory_finder = pcall(require, 'factory_finder')
  if ok and factory_finder.go_to_definition() then
    return
  else
    vim.cmd('tab split')
    vim.lsp.buf.definition()
    vim.cmd('norm zz')
  end
end

return M
