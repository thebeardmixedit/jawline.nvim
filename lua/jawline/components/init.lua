local M = {}

M.mode = require("jawline.components.mode")

function M.filename(context, spec)
	local filename = context.filename

	if filename == "" then
		return "[No Name]"
	end

	local path = spec.opts.path or "tail"

	if path == "full" then
		return filename
	end

	if path == "relative" then
		return vim.fn.fnamemodify(filename, ":.")
	end

	return vim.fn.fnamemodify(filename, ":t")
end

function M.modified(context, spec)
	if not context.modified then
		return ""
	end

	return spec.opts.text or "[+]"
end

function M.filetype(context)
	return context.filetype ~= "" and context.filetype or ""
end

function M.location(context)
	return string.format("%d:%d", context.line, context.column)
end

function M.macro()
	local register = vim.fn.reg_recording()

	if register == "" then
		return ""
	end

	return "recording @" .. register
end

function M.search()
	return ""
end

return M
