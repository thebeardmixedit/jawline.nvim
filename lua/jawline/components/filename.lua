local Component = require("jawline.component")

local Filename = Component:extend()

function Filename:write(context)
	local filename = context.filename

	if filename == "" then
		return "[No Name]"
	end

	local path = self.opts.path or "tail"

	if path == "full" then
		return filename
	end

	if path == "relative" then
		return vim.fn.fnamemodify(filename, ":.")
	end

	return vim.fn.fnamemodify(filename, ":t")
end

return Filename
