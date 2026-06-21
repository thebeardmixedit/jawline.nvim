local Component = require("jawline.component")

local Modified = Component:extend()

function Modified:write(context)
	if not context.modified then
		return ""
	end

	return self.opts.text or "[+]"
end

return Modified
