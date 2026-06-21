local Class = require("jawline.utils.class")

local Component = Class:extend()

function Component:init(spec)
	assert(type(spec) == "table", "Component spec must be a table")

	self.name = spec.name
	self.opts = spec.opts or {}
	self.spec = spec
end

function Component:write()
	return ""
end

function Component:__tostring()
	return "JawlineComponent[" .. self.name .. "]"
end

return Component
