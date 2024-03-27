local M = {}

M.setup = function(opts)
	opts = opts or {}
	vim.api.nvim_create_user_command("ToggleCB", function(args)
		local lstart = args.line1
		local lend = args.line2
		for line = lstart, lend do
			vim.api.nvim_win_set_cursor(0, { line, 1 })
			M.toggle_checkbox()
		end
	end, { range = true, desc = "Toggle checkbox in markdown files" })
end

M.toggle_checkbox = function()
	-- get node at position
	local node = vim.treesitter.get_node()

	-- Find task_list_marker_un/checked node
	if node and not node:type():match("task_list_marker_(u?n?checked)") then
		while node ~= nil and node:type() ~= "list_item" do
			node = node:parent()
		end

		if node == nil or node:type() ~= "list_item" then
			return false
		end

		node = vim.iter(node:iter_children()):find(function(child)
			return child:type():match("task_list_marker_u?n?checked") ~= nil
		end)
	end

	-- toggle list marker content value
	local content
	if node == nil then
		return
	elseif node:type() == "task_list_marker_checked" then
		content = { "[ ]" }
	elseif node:type() == "task_list_marker_unchecked" then
		content = { "[x]" }
	end

	-- get position of the content
	local start_row, start_column, end_row, end_column = node:range()
	-- put updated content on the checkbox
	vim.api.nvim_buf_set_text(0, start_row, start_column, end_row, end_column, content)
end

return M
