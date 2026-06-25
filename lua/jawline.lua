local config = require("jawline.config")
local context = require("jawline.context")
local highlights = require("jawline.highlights")
local components = require("jawline.components")
local render = require("jawline.render")

local M = {}

local state = {
	config = nil,
}

local function create_usercmds()
	vim.api.nvim_create_user_command("JawlineRefresh", function()
		M.refresh()
	end, {
		desc = "Refresh Jawline statusline",
		force = true,
	})
end

local function create_autocmds()
	vim.api.nvim_create_autocmd({
		"BufEnter",
		"BufWinEnter",
		"WinEnter",
		"FileType",
		"ModeChanged",
		"CursorMoved",
		"CursorMovedI",
		"TextChanged",
		"TextChangedI",
		"BufWritePost",
	}, {
		group = vim.api.nvim_create_augroup("jawline-auto-refresh", { clear = true }),
		desc = "Refresh Jawline statusline",
		callback = function()
			M.refresh()
		end,
	})

	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("jawline-highlights-refresh", { clear = true }),
		desc = "Refresh Jawline highlights",
		callback = function()
			local normalized_config = state.config

			if normalized_config then
				highlights.apply(normalized_config.theme)
				highlights.attach(normalized_config.statusline)
			else
				highlights.apply()
			end

			M.refresh()
		end,
	})
end

function M.refresh(args)
	local normalized_config = state.config

	if not normalized_config then
		normalized_config = config.normalize()

		components.attach(normalized_config)

		highlights.apply(normalized_config.theme)
		highlights.attach(normalized_config.statusline)

		state.config = normalized_config
	end

	local refresh_context = context.create(args)
	local statusline = render(refresh_context, normalized_config.statusline)

	if normalized_config.statusline.global then
		vim.o.statusline = statusline
	else
		vim.wo[refresh_context.winid].statusline = statusline
	end

	return statusline
end

function M.setup(user_config)
	local normalized_config = config.normalize(user_config)

	components.attach(normalized_config)

	highlights.apply(normalized_config.theme)
	highlights.attach(normalized_config.statusline)

	state.config = normalized_config

	vim.o.laststatus = normalized_config.statusline.global and 3 or 2

	create_usercmds()
	create_autocmds()

	M.refresh()

	return M
end

---@param config_name? "default"|"normalized"|"user"
function M.get_config(config_name)
	return config.get(config_name)
end

return M
