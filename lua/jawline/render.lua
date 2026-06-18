local components = require("jawline.components")

local function escape(value)
	return value:gsub("%%", "%%%%")
end

local function display_width(value)
	return vim.fn.strdisplaywidth(value)
end

local function pad_to_min_width(value, min_width)
	local width = display_width(value)

	if width >= min_width then
		return value
	end

	return value .. string.rep(" ", min_width - width)
end

local function apply_highlight(value, hl)
	if not hl then
		return value
	end

	if type(hl) == "string" then
		return "%#" .. hl .. "#" .. value .. "%*"
	end

	return value
end

local function empty_component(spec)
	if not spec.preserve_min_width_when_empty then
		return ""
	end

	local value = string.rep(" ", spec.min_width)

	return apply_highlight(value, spec.hl)
end

local function draw_component(context, spec)
	if not spec.enabled then
		return empty_component(spec)
	end

	local component = components[spec.name]

	assert(component, "Unknown Jawline component '" .. spec.name .. "'")

	local value = component(context, spec)

	if value == nil then
		value = ""
	end

	value = tostring(value)

	if value == "" then
		return empty_component(spec)
	end

	value = pad_to_min_width(value, spec.min_width)
	value = escape(value)
	value = apply_highlight(value, spec.hl)

	return value
end

local function section(context, specs)
	local parts = {}

	for _, spec in ipairs(specs) do
		local component = draw_component(context, spec)

		if component and component ~= "" then
			table.insert(parts, component)
		end
	end

	return table.concat(parts, " ")
end

---@param context table
---@param config table
return function(context, config)
	local left = section(context, config.left)
	local center = section(context, config.center)
	local right = section(context, config.right)

	if center ~= "" then
		return table.concat({ left, "%=", center, "%=", right }, " ")
	end

	return table.concat({ left, "%=", right }, " ")
end
