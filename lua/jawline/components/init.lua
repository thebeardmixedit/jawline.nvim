local M = {}

local registry = {
	mode = require("jawline.components.mode"),
	filename = require("jawline.components.filename"),
	modified = require("jawline.components.modified"),
	filetype = require("jawline.components.filetype"),
	location = require("jawline.components.location"),
	macro = require("jawline.components.macro"),
	search = require("jawline.components.search"),
}

local function attach_component(spec)
	local component = registry[spec.name]

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
