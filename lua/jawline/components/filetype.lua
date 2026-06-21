local Component = require("jawline.component")

local Filetype = Component:extend()

function Filetype:write(context)
	return context.filetype ~= "" and context.filetype or ""
end

return Filetype
