local M = {}

local normalized, user

local defaults = {
	statusline = {
		global = true,
		inherit_defaults = false,
		spacing = 1,
		padding = {
			left = 1,
			right = 1,
		},
		left = {
			{ "mode", style = "block", hl = "JawlineMode" },
			{ "filename", path = "tail", hl = "JawlineFilename" },
		},
		center = {
			{ "macro", hl = "JawlineMacro" },
			{ "search", hl = "JawlineSearch" },
		},
		right = {
			{ "filetype", icon = true, hl = "JawlineFiletype" },
			{ "location", hl = "JawlineLocation" },
		},
	},
}

local default_component_layout = {
	padding = {
		left = 0,
		right = 0,
	},
	min_width = 0,
	preserve_min_width_when_empty = false,
}

local section_names = { "left", "center", "right" }

local component_reserved_keys = {
	enabled = true,
	hl = true,
	min_width = true,
	preserve_min_width_when_empty = true,
	padding = true,
}

---@param value any
local function deepcopy(value)
	return vim.deepcopy(value)
end

---@param statusline table
local function has_user_layout(statusline)
	return statusline.left ~= nil or statusline.center ~= nil or statusline.right ~= nil
end

---@param value boolean|nil
---@param default boolean
---@param name string
---@return boolean
local function bool(value, default, name)
	if value == nil then
		return default
	end

	assert(
		type(value) == "boolean",
		"Invalid " .. name .. " configuration type '" .. type(value) .. "', must be a boolean"
	)

	return value
end

---@param value integer|nil
---@param default integer
---@param name string
---@return number
local function int(value, default, name)
	if value == nil then
		return default
	end

	assert(
		type(value) == "number",
		"Invalid " .. name .. " configuration type '" .. type(value) .. "', must be a number"
	)

	assert(value == math.floor(value), "Invalid " .. name .. " value '" .. value .. "', must be an integer")
	assert(value >= 0, "Invalid " .. name .. " value, must be >= 0")

	return value
end

---@param value string|table|nil
---@param name string
local function hl(value, name)
	if value == nil then
		return nil
	end

	assert(
		type(value) == "string" or type(value) == "table",
		"Invalid " .. name .. " configuration type '" .. type(value) .. "', must be a string or table"
	)

	return deepcopy(value)
end

---@param value number|table|nil
---@param default { left: integer, right: integer }
---@param name string
---@return { left: integer, right: integer }
local function pad(value, default, name)
	if value == nil then
		return deepcopy(default)
	end

	assert(
		type(value) == "number" or type(value) == "table",
		"Invalid " .. name .. " configuration type '" .. type(value) .. "', must be a number or table"
	)

	if type(value) == "number" then
		local amount = int(value, 0, name)

		return {
			left = amount,
			right = amount,
		}
	end

	return {
		left = int(value.left, default.left, name .. ".left"),
		right = int(value.right, default.right, name .. ".right"),
	}
end

local function normalize_component_layout(component, name)
	return {
		padding = pad(component.padding, default_component_layout.padding, "statusline." .. name .. ".padding"),
		min_width = int(component.min_width, default_component_layout.min_width, "statusline." .. name .. ".min_width"),
		preserve_min_width_when_empty = bool(
			component.preserve_min_width_when_empty,
			default_component_layout.preserve_min_width_when_empty,
			"statusline." .. name .. ".preserve_min_width_when_empty"
		),
	}
end

local function normalize_component(component)
	if type(component) == "string" then
		assert(component ~= "", "Component name must not be empty")

		return {
			name = component,
			enabled = true,
			hl = nil,
			layout = deepcopy(default_component_layout),
			opts = {},
		}
	end

	assert(
		type(component) == "table",
		"Invalid component configuration type '" .. type(component) .. "', must be a string or component table"
	)

	local name = component[1]

	assert(type(name) == "string", "Invalid component name type '" .. type(name) .. "', must be a string")
	assert(name ~= "", "Component name must not be empty")

	local opts = {}

	for key, value in pairs(component) do
		if type(key) == "number" and key ~= 1 then
			error("Invalid component option index '" .. key .. "' for component '" .. name .. "'")
		end

		if key ~= 1 and not component_reserved_keys[key] then
			opts[key] = deepcopy(value)
		end
	end

	return {
		name = name,
		enabled = bool(component.enabled, true, "statusline." .. name .. ".enabled"),
		hl = hl(component.hl, "statusline." .. name .. ".hl"),
		layout = normalize_component_layout(component, name),
		opts = opts,
	}
end

local function normalize_section(section)
	if section == nil then
		return {}
	end

	assert(
		type(section) == "table",
		"Invalid section configuration type '" .. type(section) .. "', must be a section configuration table"
	)

	local normalized_section = {}

	for _, component in ipairs(section) do
		table.insert(normalized_section, normalize_component(component))
	end

	return normalized_section
end

local function normalize_statusline(user_statusline)
	if user_statusline == nil then
		user_statusline = defaults.statusline
	end

	assert(
		type(user_statusline) == "table",
		"Invalid statusline configuration type '"
			.. type(user_statusline)
			.. "', must be a statusline configuration table"
	)

	local inherit_defaults =
		bool(user_statusline.inherit_defaults, defaults.statusline.inherit_defaults, "statusline.inherit_defaults")

	local global = bool(user_statusline.global, defaults.statusline.global, "statusline.global")
	local spacing = int(user_statusline.spacing, defaults.statusline.spacing, "statusline.spacing")
	local padding = pad(user_statusline.padding, defaults.statusline.padding, "statusline.padding")

	local should_use_defaults = inherit_defaults or not has_user_layout(user_statusline)

	local statusline = {
		global = global,
		inherit_defaults = inherit_defaults,
		spacing = spacing,
		padding = padding,
		left = {},
		center = {},
		right = {},
	}

	for _, section_name in ipairs(section_names) do
		if should_use_defaults then
			local source = user_statusline[section_name]

			if source == nil then
				source = defaults.statusline[section_name]
			end

			statusline[section_name] = normalize_section(source)
		else
			statusline[section_name] = normalize_section(user_statusline[section_name])
		end
	end

	return statusline
end

---@param user_config? table
function M.normalize(user_config)
	if user_config == nil then
		user_config = {}
	end

	assert(
		type(user_config) == "table",
		"Invalid configuration type '" .. type(user_config) .. "', must be a configuration table"
	)

	local user_config_copy = deepcopy(user_config)
	local normalized_config = deepcopy(user_config)

	normalized_config.statusline = normalize_statusline(user_config.statusline)

	user = user_config_copy
	normalized = normalized_config

	return normalized
end

---@param config_name? "default"|"normalized"|"user"
function M.get(config_name)
	if config_name == "default" then
		return deepcopy(defaults)
	end

	if config_name == "normalized" then
		return deepcopy(normalized)
	end

	if config_name == "user" then
		return deepcopy(user)
	end

	return {
		default = deepcopy(defaults),
		normalized = deepcopy(normalized),
		user = deepcopy(user),
	}
end

return M
