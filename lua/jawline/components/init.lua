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

local function attach_component(spec)
	local component = M[spec.name]

	assert(component, "Unknown Jawline component '" .. spec.name .. "'")

	if type(component) == "function" then
		spec.component = component
		return spec
	end

	assert(
		type(component) == "table" and type(component.write) == "function",
		"Invalid Jawline component '" .. spec.name .. "', must be a function or component class"
	)

	spec.component = component(spec)

	return spec
end

local function attach_section(section)
	for _, spec in ipairs(section) do
		attach_component(spec)
	end

	return section
end

function M.attach(statusline)
	attach_section(statusline.left)
	attach_section(statusline.center)
	attach_section(statusline.right)

	return statusline
end

return M
