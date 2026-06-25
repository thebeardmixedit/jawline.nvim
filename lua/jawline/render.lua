local function escape(value)
	return value:gsub("%%", "%%%%")
end

local function display_width(value)
	return vim.fn.strdisplaywidth(value)
end

local function spaces(count)
	return string.rep(" ", count)
end

local function apply_line_padding(statusline, padding)
	return spaces(padding.left) .. statusline .. spaces(padding.right)
end

local function apply_component_padding(value, padding)
	return spaces(padding.left) .. value .. spaces(padding.right)
end

local function apply_min_width(value, min_width, justify)
	local width = display_width(value)

	if width >= min_width then
		return value
	end

	local diff = min_width - width

	if justify == "left" then
		return value .. spaces(diff)
	end

	if justify == "right" then
		return spaces(diff) .. value
	end

	local left = math.floor(diff / 2)
	local right = diff - left

	return spaces(left) .. value .. spaces(right)
end

local function apply_highlight(value, hl)
	if not hl then
		return value
	end

	return "%#" .. hl .. "#" .. value .. "%*"
end

local function empty_component(spec)
	local layout = spec.layout

	if not layout.preserve_min_width_when_empty then
		return ""
	end

	local width = math.max(layout.min_width, layout.padding.left + layout.padding.right)

	if width == 0 then
		return ""
	end

	local value = spaces(width)

	return apply_highlight(value, spec.hl.resolved)
end

local function write_component(context, spec)
	local component = spec.component

	assert(component, "No component attached for Jawline component '" .. spec.name .. "'")

	return component:write(context)
end

local function draw_component(context, spec)
	if not spec.enabled then
		return empty_component(spec)
	end

	local value = write_component(context, spec)

	if value == nil then
		value = ""
	end

	value = tostring(value)

	if value == "" then
		return empty_component(spec)
	end

	value = apply_component_padding(value, spec.layout.padding)
	value = apply_min_width(value, spec.layout.min_width, spec.layout.justify)
	value = escape(value)
	value = apply_highlight(value, spec.hl.resolved)

	return value
end

local function section(context, spacing, specs)
	local parts = {}

	for _, spec in ipairs(specs) do
		local component = draw_component(context, spec)

		if component and component ~= "" then
			table.insert(parts, component)
		end
	end

	return table.concat(parts, spaces(spacing))
end

---@param context table
---@param config table
return function(context, config)
	local left = section(context, config.spacing, config.left)
	local center = section(context, config.spacing, config.center)
	local right = section(context, config.spacing, config.right)

	local line

	if center ~= "" then
		line = left .. "%=" .. center .. "%=" .. right
	else
		line = left .. "%=" .. right
	end

	line = apply_line_padding(line, config.padding)

	return line
end
