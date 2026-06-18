local M = {}

---@param opts? { bufnr?: integer, winid?: integer }
function M.create(opts)
	opts = opts or {}

	assert(type(opts) == "table", "Context options must be a table")

	local current_winid = vim.api.nvim_get_current_win()
	local winid = opts.winid or current_winid

	assert(vim.api.nvim_win_is_valid(winid), "Invalid window id")

	local bufnr = opts.bufnr or vim.api.nvim_win_get_buf(winid)

	assert(vim.api.nvim_buf_is_valid(bufnr), "Invalid buffer id")

	local cursor = vim.api.nvim_win_get_cursor(winid)
	local mode = vim.api.nvim_get_mode().mode

	return {
		winid = winid,
		bufnr = bufnr,

		current_winid = current_winid,
		active = winid == current_winid,

		mode = mode,

		filename = vim.api.nvim_buf_get_name(bufnr),
		filetype = vim.bo[bufnr].filetype,
		buftype = vim.bo[bufnr].buftype,

		modified = vim.bo[bufnr].modified,
		readonly = vim.bo[bufnr].readonly,
		modifiable = vim.bo[bufnr].modifiable,

		line = cursor[1],
		column = cursor[2] + 1,
		total_lines = vim.api.nvim_buf_line_count(bufnr),
	}
end

return M
