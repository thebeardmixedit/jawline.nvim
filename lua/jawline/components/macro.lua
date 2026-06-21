local Component = require("jawline.component")

local Macro = Component:extend()

function Macro:write(_)
	local register = vim.fn.reg_recording()

	if register == "" then
		return ""
	end

	return "recording @" .. register
end

return Macro
