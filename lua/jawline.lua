local config = require("jawline.config")
local context = require("jawline.context")
local highlights = require("jawline.highlights")
local render = require("jawline.render")

local M = {}

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
			highlights.apply()
			M.refresh()
		end,
	})
end

function M.refresh(args)
	local normalized_config = config.get("normalized")
	if not normalized_config then
		normalized_config = config.normalize()
	end

	-- create statusline context
	local refresh_context = context.create(args)

	-- get statusline string from renderer
	local statusline = render(refresh_context, normalized_config.statusline)

	-- write string to vim.o.statusline / vim.wo.statusline
	if normalized_config.statusline.global then
		vim.o.statusline = statusline
	else
		vim.wo[refresh_context.winid].statusline = statusline
	end

	return statusline
end

function M.setup(user_config)
	local normalized_config = config.normalize(user_config)

	highlights.apply()

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
