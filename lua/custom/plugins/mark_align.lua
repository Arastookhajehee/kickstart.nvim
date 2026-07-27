local mark_align = {}

local config = {
	width = 80,
}

local closing_chars = {
	[")"] = true,
	["]"] = true,
	["}"] = true,
	[","] = true,
	["."] = true,
	[";"] = true,
	[":"] = true,
	["!"] = true,
	["?"] = true,
}

local opening_chars = {
	["("] = true,
	["["] = true,
	["{"] = true,
}

local function is_blank(line)
	return line:match("^%s*$") ~= nil
end

local function trimmed(line)
	return (line:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function common_indent(lines)
	local indent = nil

	for _, line in ipairs(lines) do
		if not is_blank(line) then
			local current = line:match("^%s*") or ""
			if indent == nil then
				indent = current
			else
				local max_len = math.min(#indent, #current)
				local i = 1
				while i <= max_len and indent:sub(i, i) == current:sub(i, i) do
					i = i + 1
				end
				indent = indent:sub(1, i - 1)
			end
		end
	end

	return indent or ""
end

local function looks_like_plain_paragraph(lines)
	for _, line in ipairs(lines) do
		local text = trimmed(line)
		if text ~= "" then
			if text:match("^#{1,6}%s") then
				return false
			end
			if text:match("^```") or text:match("^~~~") then
				return false
			end
			if text:match("^>%s?") then
				return false
			end
			if text:match("^[-*+]%s") then
				return false
			end
			if text:match("^%d+[.)]%s") then
				return false
			end
			if text:match("^|.*|$") then
				return false
			end
			if text:match("^[-_*][-_*][-_*%s]*$") then
				return false
			end
		end
	end

	return true
end

local function normalize_text(text)
	text = text:gsub("%s+", " ")
	text = text:gsub("%s+([,.;:!?%)%]%}])", "%1")
	text = text:gsub("([%(%[%{])%s+", "%1")
	text = text:gsub("%s+$", "")
	return text
end

local function consume_quoted(text, start_idx, marker)
	local close_idx = text:find(marker, start_idx + #marker, true)
	if not close_idx then
		return nil
	end

	local content = text:sub(start_idx, close_idx + #marker - 1)
	if #trimmed(content:sub(#marker + 1, -#marker - 1)) == 0 then
		return nil
	end

	return content, close_idx + #marker
end

local function is_citation_like(content)
	if content:match("%d%d%d%d") then
		return true
	end
	if content:match("^[A-Z][^,]+, [A-Z][^,]+$") then
		return true
	end
	return false
end

local function is_pandoc_citation_content(content)
	content = trimmed(content)
	if not content:match("^@") then
		return false
	end
	return content:match("@[%w:_%-]+") ~= nil
end

local function consume_parenthetical(text, start_idx)
	local depth = 0
	local i = start_idx
	while i <= #text do
		local ch = text:sub(i, i)
		if ch == "(" then
			depth = depth + 1
		elseif ch == ")" then
			depth = depth - 1
			if depth == 0 then
				local content = text:sub(start_idx, i)
				local inner = content:sub(2, -2)
				if is_pandoc_citation_content(inner) then
					return content, i + 1, "pandoc_citation"
				end
				if is_citation_like(inner) then
					return content, i + 1, "citation"
				end
				return nil
			end
		end
		i = i + 1
	end

	return nil
end

local function append_text_segment(segments, text)
	text = normalize_text(text)
	if text ~= "" then
		table.insert(segments, { kind = "text", text = text })
	end
end

local function collect_attached_punctuation(text, start_idx)
	local i = start_idx
	while i <= #text and text:sub(i, i):match("%s") do
		i = i + 1
	end

	local punct_start = i
	while i <= #text and text:sub(i, i):match("[.,;:!?]") do
		i = i + 1
	end

	return text:sub(punct_start, i - 1), i
end

local function split_long_citation_segments(text, width)
	local segments = {}
	local prose_start = 1
	local i = 1
	local standalone_threshold = math.floor(width / 2)

	while i <= #text do
		if text:sub(i, i) == "(" then
			local token, next_idx, kind = consume_parenthetical(text, i)
			if kind == "pandoc_citation" and #token > standalone_threshold then
				append_text_segment(segments, text:sub(prose_start, i - 1))
				local punctuation, after_punctuation = collect_attached_punctuation(text, next_idx)
				table.insert(segments, {
					kind = "citation_line",
					text = token .. punctuation,
				})
				i = after_punctuation
				while i <= #text and text:sub(i, i):match("%s") do
					i = i + 1
				end
				prose_start = i
			else
				i = next_idx or (i + 1)
			end
		else
			i = i + 1
		end
	end

	append_text_segment(segments, text:sub(prose_start))

	if #segments == 0 then
		return { { kind = "text", text = text } }
	end

	return segments
end

local function tokenize_inline(text)
	local tokens = {}
	local i = 1

	while i <= #text do
		while i <= #text and text:sub(i, i):match("%s") do
			i = i + 1
		end

		if i > #text then
			break
		end

		local ch = text:sub(i, i)
		local token, next_idx

		if ch == "`" then
			token, next_idx = consume_quoted(text, i, "`")
		elseif text:sub(i, i + 1) == "**" then
			token, next_idx = consume_quoted(text, i, "**")
		elseif text:sub(i, i + 1) == "__" then
			token, next_idx = consume_quoted(text, i, "__")
		elseif ch == "*" then
			token, next_idx = consume_quoted(text, i, "*")
		elseif ch == "_" then
			token, next_idx = consume_quoted(text, i, "_")
		elseif ch == "(" then
			token, next_idx = consume_parenthetical(text, i)
		end

		if not token then
			local j = i
			while j <= #text and not text:sub(j, j):match("%s") do
				j = j + 1
			end
			token = text:sub(i, j - 1)
			next_idx = j
		end

		table.insert(tokens, token)
		i = next_idx
	end

	return tokens
end

local function join_tokens(tokens, start_idx, end_idx)
	return table.concat(tokens, " ", start_idx, end_idx)
end

local function ends_badly(text)
	local last = text:sub(-1)
	return opening_chars[last] == true
end

local function starts_badly(text)
	local first = text:match("^%S")
	return first ~= nil and closing_chars[first] == true
end

local function count_words(text)
	local count = 0
	for _ in text:gmatch("%S+") do
		count = count + 1
	end
	return count
end

local function line_penalty(text, max_width, is_last)
	local penalty = 0
	local len = #text
	local words = count_words(text)
	local target = math.floor(max_width * (is_last and 0.82 or 0.92))

	penalty = penalty + math.abs(target - len) * 1.8

	if len < math.floor(max_width * 0.65) then
		penalty = penalty + (math.floor(max_width * 0.65) - len) * 6
	end

	if len < math.floor(max_width * 0.5) then
		penalty = penalty + (math.floor(max_width * 0.5) - len) * 10
	end

	if words == 1 then
		penalty = penalty + 220
		if text:match("[.!?][\"')%]%}]*$") then
			penalty = penalty + 120
		end
	end

	if words == 2 and len < math.floor(max_width * 0.4) then
		penalty = penalty + 80
	end

	if ends_badly(text) then
		penalty = penalty + 140
	end

	if starts_badly(text) then
		penalty = penalty + 160
	end

	if text:match("[.!?][\"')%]%}]*$") then
		penalty = penalty - 16
		if not is_last then
			penalty = penalty - 10
		end
	elseif text:match("[,;:][\"')%]%}]*$") then
		penalty = penalty - 8
	end

	return penalty
end

local function layout_tokens(tokens, available_width)
	local n = #tokens
	if n == 0 then
		return {}
	end

	local lengths = {}
	for i, token in ipairs(tokens) do
		lengths[i] = #token
	end

	local prefix = {}
	prefix[0] = 0
	for i = 1, n do
		prefix[i] = (prefix[i - 1] or 0) + (lengths[i] or 0)
	end

	local function segment_length(i, j)
		return (prefix[j] - prefix[i - 1]) + (j - i)
	end

	local best_cost = {}
	local next_break = {}
	best_cost[n + 1] = 0

	for i = n, 1, -1 do
		best_cost[i] = math.huge
		for j = i, n do
			local len = segment_length(i, j)
			if len > available_width then
				break
			end

			local text = join_tokens(tokens, i, j)
			local is_last = j == n
			local cost = line_penalty(text, available_width, is_last) + (best_cost[j + 1] or math.huge)

			if cost < best_cost[i] then
				best_cost[i] = cost
				next_break[i] = j
			end
		end
	end

	local lines = {}
	local i = 1
	while i <= n do
		local j = next_break[i] or n
		table.insert(lines, join_tokens(tokens, i, j))
		i = j + 1
	end

	return lines
end

local function final_cleanup(lines, max_width)
	if #lines < 2 then
		return lines
	end

	local last = trimmed(lines[#lines])
	if count_words(last) ~= 1 and #last >= math.floor(max_width * 0.4) then
		return lines
	end

	local merged = trimmed(lines[#lines - 1]) .. " " .. last
	if #merged <= max_width then
		lines[#lines - 1] = merged
		table.remove(lines, #lines)
	end

	return lines
end

local function format_lines(lines)
	if #lines == 0 or not looks_like_plain_paragraph(lines) then
		return lines
	end

	local indent = common_indent(lines)
	local parts = {}
	for _, line in ipairs(lines) do
		local content = line:sub(#indent + 1)
		content = trimmed(content)
		if content ~= "" then
			table.insert(parts, content)
		end
	end

	local text = normalize_text(table.concat(parts, " "))
	if text == "" then
		return lines
	end

	local available_width = config.width - #indent
	if available_width <= 20 then
		return lines
	end

	local segments = split_long_citation_segments(text, available_width)
	local output = {}

	for _, segment in ipairs(segments) do
		if segment.kind == "citation_line" then
			table.insert(output, segment.text)
		else
			local tokens = tokenize_inline(segment.text)
			if #tokens > 0 then
				local segment_lines = layout_tokens(tokens, available_width)
				segment_lines = final_cleanup(segment_lines, available_width)
				for _, line in ipairs(segment_lines) do
					table.insert(output, line)
				end
			end
		end
	end

	if #output == 0 then
		return lines
	end

	for i, line in ipairs(output) do
		output[i] = indent .. line
	end

	return output
end

local function get_line_words(line)
	local words = {}
	for start_col, word, end_col in line:gmatch("()(%S+)()") do
		table.insert(words, {
			word = word,
			start_col = start_col,
			end_col = end_col - 1,
		})
	end
	return words
end

local function get_cursor_target(lines, start_line, end_line)
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row = cursor[1]
	local col = cursor[2] + 1

	if row < start_line or row > end_line then
		return nil
	end

	local relative_row = row - start_line + 1
	local current_words = get_line_words(lines[relative_row] or "")
	if #current_words == 0 then
		return nil
	end

	local selected_idx = nil
	for idx, item in ipairs(current_words) do
		if item.start_col <= col and col <= item.end_col + 1 then
			selected_idx = idx
			break
		end
		if item.end_col < col then
			selected_idx = idx
		end
	end

	if selected_idx == nil then
		selected_idx = 1
	end

	local target_word = current_words[selected_idx].word
	local occurrence = 0

	for line_idx, line in ipairs(lines) do
		local words = get_line_words(line)
		for word_idx, item in ipairs(words) do
			if item.word == target_word then
				occurrence = occurrence + 1
			end
			if line_idx == relative_row and word_idx == selected_idx then
				return {
					word = target_word,
					occurrence = occurrence,
				}
			end
		end
	end

	return nil
end

local function find_target_position(lines, target, start_line)
	if not target then
		return nil
	end

	local occurrence = 0
	for line_idx, line in ipairs(lines) do
		for start_col, word in line:gmatch("()(%S+)") do
			if word == target.word then
				occurrence = occurrence + 1
				if occurrence == target.occurrence then
					return { start_line + line_idx - 1, start_col - 1 }
				end
			end
		end
	end

	return nil
end

local function replace_range(start_line, end_line)
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
	local cursor_target = get_cursor_target(lines, start_line, end_line)
	local formatted = format_lines(lines)
	if formatted ~= lines then
		vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, formatted)
	end

	return find_target_position(formatted, cursor_target, start_line)
end

local function paragraph_range_at_cursor()
	local line_count = vim.api.nvim_buf_line_count(0)
	local current = vim.api.nvim_win_get_cursor(0)[1]
	local lines = vim.api.nvim_buf_get_lines(0, 0, line_count, false)

	if is_blank(lines[current]) then
		return nil
	end

	local start_line = current
	while start_line > 1 and not is_blank(lines[start_line - 1]) do
		start_line = start_line - 1
	end

	local end_line = current
	while end_line < line_count and not is_blank(lines[end_line + 1]) do
		end_line = end_line + 1
	end

	return start_line, end_line
end

function mark_align.format_current_paragraph()
	local start_line, end_line = paragraph_range_at_cursor()
	if not start_line then
		return
	end
	local cursor_pos = replace_range(start_line, end_line)
	if cursor_pos then
		vim.api.nvim_win_set_cursor(0, cursor_pos)
	end
end

function mark_align.format_visual_selection()
	local start_line = vim.fn.line("v")
	local end_line = vim.fn.line(".")
	if start_line > end_line then
		start_line, end_line = end_line, start_line
	end
	local cursor_pos = replace_range(start_line, end_line)
	vim.cmd("normal! <Esc>")
	if cursor_pos then
		vim.api.nvim_win_set_cursor(0, cursor_pos)
	end
end

function mark_align.setup(opts)
	config = vim.tbl_extend("force", config, opts or {})
end

mark_align.setup({
	width = 120,
})

vim.keymap.set("n", "qq", mark_align.format_current_paragraph, { noremap = true, silent = true })
vim.keymap.set("v", "qq", mark_align.format_visual_selection, { noremap = true, silent = true })

return mark_align
