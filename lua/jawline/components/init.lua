local Function = require("jawline.components.function")

local M = {}

local builtin = {
	mode = require("jawline.components.mode"),
	filename = require("jawline.components.filename"),
	modified = require("jawline.components.modified"),
	filetype = require("jawline.components.filetype"),
	location = require("jawline.components.location"),
	macro = require("jawline.components.macro"),
	search = require("jawline.components.search"),
}

local function create_registry(user_components)
	local registry = {}

	for name, component in pairs(builtin) do
		registry[name] = component
	end

	for name, component in pairs(user_components or {}) do
		assert(registry[name] == nil, "Custom Jawline component '" .. name .. "' conflicts with a built-in component")

		registry[name] = component
	end

	return registry
end

local function attach_component(spec, registry)
	local component = registry[spec.name]

	assert(component, "Unknown Jawline component '" .. spec.name .. "'")

	assert(
		(type(component) == "table" and type(component.write) == "function") or type(component) == "function",
		"Invalid Jawline component '" .. spec.name .. "', must be a function or component class"
	)

	if type(component) == "function" then
		spec.component = Function(spec, component)
		return spec
	end

	spec.component = component(spec)
	return spec
end

local function attach_section(section, registry)
	for _, spec in ipairs(section) do
		attach_component(spec, registry)
	end

	return section
end

function M.attach(config)
	local registry = create_registry(config.components)
	local statusline = config.statusline

	attach_section(statusline.left, registry)
	attach_section(statusline.center, registry)
	attach_section(statusline.right, registry)

	return config
end

return M
