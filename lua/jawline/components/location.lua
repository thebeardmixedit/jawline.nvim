local Component = require("jawline.component")

local Location = Component:extend()

function Location:write(context)
	return string.format("%d:%d", context.line, context.column)
end

return Location
