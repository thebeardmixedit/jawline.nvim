local Component = require("jawline.component")

local Function = Component:extend()

function Function:init(spec, fn)
	Function.super.init(self, spec)
	self.fn = fn
end

function Function:write(context)
	return self.fn(context, self.opts, self.spec)
end

return Function
