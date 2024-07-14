local M = {}
local curl = require('plenary.curl')

M.config = {
  url = 'http://localhost:5000/execute'
}

function M.setup(opts)
  M.config = vim.tbl_extend('force', M.config, opts or {})
end

function M.send_to_repl(code)
  local response = curl.post(M.config.url, {
    body = vim.fn.json_encode({code = code}),
    headers = {
      content_type = 'application/json',
    },
  })

  local result = vim.fn.json_decode(response.body)
end


function M.get_visual_selection()
  local _, srow, scol = unpack(vim.fn.getpos 'v')
  local _, erow, ecol = unpack(vim.fn.getpos '.')

  if vim.fn.mode() == 'V' then
    if srow > erow then
      return vim.api.nvim_buf_get_lines(0, erow - 1, srow, true)
    else
      return vim.api.nvim_buf_get_lines(0, srow - 1, erow, true)
    end
  end

  if vim.fn.mode() == 'v' then
    if srow < erow or (srow == erow and scol <= ecol) then
      return vim.api.nvim_buf_get_text(0, srow - 1, scol - 1, erow - 1, ecol, {})
    else
      return vim.api.nvim_buf_get_text(0, erow - 1, ecol - 1, srow - 1, scol, {})
    end
  end
  return 'uhh'
end

function M.run_selected_lines()
  local code = M.get_visual_selection()
  M.send_to_repl(code)
end

return M
