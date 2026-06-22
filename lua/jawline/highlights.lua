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

local function prefixed(group)
	if group:match("^Jawline") then
		return group
	end

	return "Jawline" .. group
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

function M.apply(theme)
	theme = theme or {}

	set_groups(defaults, { default = true })
	set_groups(theme.groups or {})
end

return M
