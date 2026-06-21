local Component = require("jawline.component")

local Mode = Component:extend()

local modes = {
	n = "NORMAL",
	no = "PENDING",
	nov = "PENDING",
	noV = "PENDING",
	["no\22"] = "PENDING",

	niI = "NORMAL",
	niR = "NORMAL",
	niV = "NORMAL",

	nt = "NORMAL",
	ntT = "NORMAL",

	v = "VISUAL",
	vs = "VISUAL",
	V = "V-LINE",
	Vs = "V-LINE",
	["\22"] = "V-BLOCK",
	["\22s"] = "V-BLOCK",

	s = "SELECT",
	S = "S-LINE",
	["\19"] = "S-BLOCK",

	i = "INSERT",
	ic = "INSERT",
	ix = "INSERT",

	R = "REPLACE",
	Rc = "REPLACE",
	Rx = "REPLACE",
	Rv = "V-REPLACE",
	Rvc = "V-REPLACE",
	Rvx = "V-REPLACE",

	r = "HIT-ENTER",
	rm = "MORE",
	["r?"] = "CONFIRM",

	c = "COMMAND",
	cv = "EX",
	ce = "EX",

	["!"] = "SHELL",
	t = "TERMINAL",
}

function Mode:write(context)
	return modes[context.mode] or context.mode:upper()
end

return Mode
