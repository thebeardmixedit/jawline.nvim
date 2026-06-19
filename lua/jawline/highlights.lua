local M = {}

---@param args { groups: table<string, vim.api.keyset.highlight> }
local function set_hl(args)
	assert(type(args.groups) == "table", "Highlight groups must be a table")

	local groups = args.groups

	for group, opts in pairs(groups) do
		group = "Jawline" .. group

		vim.api.nvim_set_hl(
			0,
			group,
			vim.tbl_extend("force", {
				default = true,
			}, opts)
		)
	end
end

function M.apply()
	set_hl({
		groups = {
			Mode = { link = "StatusLine" },
			Filename = { link = "StatusLine" },
			Filetype = { link = "StatusLine" },
			Location = { link = "StatusLine" },
			Macro = { link = "WarningMsg" },
			Search = { link = "Search" },
			Muted = { link = "StatusLineNC" },
		},
	})
end

return M
