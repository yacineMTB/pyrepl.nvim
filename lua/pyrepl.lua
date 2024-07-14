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
  if result.error and result.error ~= vim.NIL then
    print("Error:", result.error)
  elseif result.output then
    print("Output:", result.output)
  end
end

function M.run_selected_lines()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.api.nvim_buf_get_text(0, start_pos[2]-1, start_pos[3]-1, end_pos[2]-1, end_pos[3], {})
  local code = table.concat(lines, "\n")
  M.send_to_repl(code)
end

return M

