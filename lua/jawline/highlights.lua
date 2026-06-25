local M = {}

local defaults = {
	Normal = { link = "StatusLine" },
	Inactive = { link = "StatusLineNC" },
	Accent = { link = "Directory" },
	Muted = { link = "Comment" },
	Info = { link = "DiagnosticInfo" },
	Warn = { link = "DiagnosticWarn" },
	Error = { link = "DiagnosticError" },
	Success = { link = "DiagnosticOk" },

	Mode = { link = "JawlineAccent" },
	Filename = { link = "JawlineNormal" },
	Modified = { link = "JawlineWarn" },
	Filetype = { link = "JawlineMuted" },
	Location = { link = "JawlineMuted" },
	Macro = { link = "JawlineWarn" },
	Search = { link = "JawlineInfo" },
}

local local_id_registry = {}

local function prefixed(group)
	if group:match("^Jawline") then
		return group
	end

	return "Jawline" .. group
end

local function pascal_case(value)
	return value
		:gsub("[^%w]+", " ")
		:gsub("(%w)(%w*)", function(first, rest)
			return first:upper() .. rest:lower()
		end)
		:gsub("%s+", "")
end

local function local_group_name(spec)
	local resolved = pascal_case(spec.name)
	local name = "JawlineLocal" .. resolved

	if local_id_registry[name] == nil then
		local_id_registry[name] = 0
	end

	local_id_registry[name] = local_id_registry[name] + 1

	local local_id = local_id_registry[name]

	return name .. local_id
end

---@param groups table<string, vim.api.keyset.highlight>
---@param opts? { default?: boolean }
local function set_groups(groups, opts)
	assert(type(groups) == "table", "Highlight groups must be a table")

	opts = opts or {}

	for group, hl in pairs(groups) do
		group = prefixed(group)

		if opts.default then
			hl = vim.tbl_extend("force", { default = true }, hl)
		end

		vim.api.nvim_set_hl(0, group, hl)
	end
end

local function attach_component(spec)
	local hl = spec.hl

	if hl.value == nil then
		hl.resolved = nil
		return spec
	end

	if type(hl.value) == "string" then
		hl.resolved = prefixed(hl.value)
		return spec
	end

	local group = hl.resolved or local_group_name(spec)

	vim.api.nvim_set_hl(0, group, hl.value)

	hl.resolved = group

	return spec
end

local function attach_section(section)
	for _, spec in ipairs(section) do
		attach_component(spec)
	end

	return section
end

function M.apply(theme)
	theme = theme or {}

	set_groups(defaults, { default = true })
	set_groups(theme.groups or {})
end

function M.attach(statusline)
	local_id_registry = {}

	attach_section(statusline.left)
	attach_section(statusline.center)
	attach_section(statusline.right)

	return statusline
end

return M
