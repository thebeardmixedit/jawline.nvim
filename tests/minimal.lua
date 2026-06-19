local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")

vim.opt.runtimepath:prepend(root)

vim.opt.termguicolors = true
vim.opt.laststatus = 3

vim.g.mapleader = " "

vim.keymap.set("n", "<leader>e", "<cmd>Explore<CR>")

vim.keymap.set("n", "<A-q>", "<cmd>confirm qall<CR>")

vim.keymap.set("n", "<leader>jc", function()
	print(vim.inspect(require("jawline.context").create()))
end, { desc = "Jawline: print context" })

vim.keymap.set("n", "<leader>jn", function()
	print(vim.inspect(require("jawline").get_config("normalized")))
end, { desc = "Jawline: print normalized config" })

vim.keymap.set("n", "<leader>jd", function()
	print(vim.inspect(require("jawline").get_config("default")))
end, { desc = "Jawline: print default config" })

vim.keymap.set("n", "<leader>ju", function()
	print(vim.inspect(require("jawline").get_config("user")))
end, { desc = "Jawline: print user config" })

vim.keymap.set("n", "<leader>jr", function()
	print(require("jawline").refresh())
end, { desc = "Jawline: refresh" })

vim.keymap.set("n", "<leader>js", function()
	print(vim.o.statusline)
end, { desc = "Jawline: print statusline" })

require("jawline").setup()
