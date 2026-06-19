local deepcopy = require("jawline.utils.deepcopy")

local M = {}

---@param value? boolean
---@param default boolean
---@param name string
---@return boolean
function M.bool(value, default, name)
	if value == nil then
		return default
	end

	assert(
		type(value) == "boolean",
		"Invalid " .. name .. " configuration type '" .. type(value) .. "', must be a boolean"
	)

	return value
end

---@param value? string
---@param default string
---@param name string
---@return string
function M.str(value, default, name)
	if value == nil then
		return default
	end

	assert(
		type(value) == "string",
		"Invalid " .. name .. " configuration type '" .. type(value) .. "', must be a string"
	)

	return value
end

---@param value? integer
---@param default integer
---@param name string
---@return number
function M.int(value, default, name)
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

---@param value? string|table
---@param name string
function M.hl(value, name)
	if value == nil then
		return nil
	end

	assert(
		type(value) == "string" or type(value) == "table",
		"Invalid " .. name .. " configuration type '" .. type(value) .. "', must be a string or table"
	)

	return deepcopy(value)
end

---@param value? number|table
---@param default { left: integer, right: integer }
---@param name string
---@return { left: integer, right: integer }
function M.pad(value, default, name)
	if value == nil then
		return deepcopy(default)
	end

	assert(
		type(value) == "number" or type(value) == "table",
		"Invalid " .. name .. " configuration type '" .. type(value) .. "', must be a number or table"
	)

	if type(value) == "number" then
		local amount = M.int(value, 0, name)

		return {
			left = amount,
			right = amount,
		}
	end

	return {
		left = M.int(value.left, default.left, name .. ".left"),
		right = M.int(value.right, default.right, name .. ".right"),
	}
end

---@param value? "left"|"center"|"right"
---@param default "left"|"center"|"right"
---@param name string
---@return "left"|"center"|"right"
function M.justify(value, default, name)
	if value == nil then
		return default
	end

	assert(
		type(value) == "string",
		"Invalid " .. name .. " configuration type '" .. type(value) .. "', must be a string"
	)

	assert(
		value == "left" or value == "center" or value == "right",
		"Invalid " .. name .. " value '" .. value .. "', must be 'left', 'center', or 'right'"
	)

	return value
end

return M
