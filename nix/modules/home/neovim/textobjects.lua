require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
    selection_modes = {
      ["@parameter.outer"] = "v",
      ["@function.outer"] = "V",
      ["@class.outer"] = "V",
    },
  },
})

local select = require("nvim-treesitter-textobjects.select")

local function map_textobject(key, query, description)
  vim.keymap.set({"x", "o"}, key, function()
    select.select_textobject(query, "textobjects")
  end, {desc = description})
end

map_textobject("if", "@function.inner", "Inside function")
map_textobject("af", "@function.outer", "Around function")
map_textobject("il", "@loop.inner", "Inside loop")
map_textobject("al", "@loop.outer", "Around loop")
map_textobject("im", "@call.inner", "Inside function call")
map_textobject("am", "@call.outer", "Around function call")
map_textobject("ik", "@class.inner", "Inside class")
map_textobject("ak", "@class.outer", "Around class")
map_textobject("ic", "@comment.inner", "Inside comment")
map_textobject("ac", "@comment.outer", "Around comment")
map_textobject("ip", "@parameter.inner", "Inside parameter")
map_textobject("ap", "@parameter.outer", "Around parameter")
map_textobject("ii", "@conditional.inner", "Inside conditional")
map_textobject("ai", "@conditional.outer", "Around conditional")
map_textobject("ir", "@assignment.rhs", "Inside assignment right-hand side")
map_textobject("ar", "@assignment.rhs", "Around assignment right-hand side")
map_textobject("ih", "@assignment.lhs", "Inside assignment left-hand side")
map_textobject("ah", "@assignment.lhs", "Around assignment left-hand side")

local function node_type_set(types)
  local result = {}

  for _, node_type in ipairs(types) do
    result[node_type] = true
  end

  return result
end

local node_textobjects = {
  a = {
    description = "array",
    types = node_type_set({
      "array",
      "array_creation_expression",
      "array_expression",
      "array_initializer",
      "block_sequence",
      "field_list",
      "flow_sequence",
      "initializer_expression",
      "initializer_list",
      "list",
      "list_comprehension",
      "slice",
    }),
  },
  o = {
    description = "object",
    types = node_type_set({
      "anonymous_object_creation_expression",
      "block_mapping",
      "dictionary",
      "enum_item",
      "enum_specifier",
      "inline_table",
      "object",
      "struct_expression",
      "struct_item",
      "struct_specifier",
      "table",
      "tuple_expression",
      "union_specifier",
    }),
  },
  s = {
    description = "string",
    trim_delimiters = true,
    types = node_type_set({
      "block_scalar",
      "char_literal",
      "character",
      "character_literal",
      "double_quote_scalar",
      "encapsed_string",
      "interpreted_string_literal",
      "nowdoc_string",
      "raw_string_literal",
      "single_quote_scalar",
      "string",
      "string_literal",
      "template_string",
    }),
  },
  t = {
    description = "type",
    types = node_type_set({
      "array_type",
      "enum_item",
      "generic_type",
      "interface_declaration",
      "object_type",
      "pointer_type",
      "predefined_type",
      "primitive_type",
      "qualified_type",
      "slice_type",
      "struct_item",
      "type_alias_declaration",
      "type_annotation",
      "type_arguments",
      "type_definition",
      "type_identifier",
      "type_parameter",
      "type_spec",
      "union_specifier",
    }),
  },
  n = {
    description = "node",
  },
  v = {
    description = "variable",
    types = node_type_set({
      "assignment",
      "assignment_expression",
      "assignment_statement",
      "block_mapping_pair",
      "const_declaration",
      "const_item",
      "field_definition",
      "let_declaration",
      "lexical_declaration",
      "local_variable_declaration",
      "pair",
      "public_field_definition",
      "short_var_declaration",
      "static_item",
      "var_declaration",
      "variable_assignment",
      "variable_declaration",
      "variable_declarator",
    }),
  },
}

local function find_node(types)
  local ok, node = pcall(vim.treesitter.get_node)

  if not ok then
    return nil
  end

  while node do
    if not types or types[node:type()] then
      return node
    end

    node = node:parent()
  end
end

local function select_node(node, inner, trim_delimiters)
  local start_row, start_col, end_row, end_col = node:range()

  if inner then
    local child_count = node:named_child_count()

    if child_count > 0 then
      local first_child = node:named_child(0)
      local last_child = node:named_child(child_count - 1)

      start_row, start_col = first_child:range()
      _, _, end_row, end_col = last_child:range()
    elseif trim_delimiters and start_row == end_row and end_col - start_col > 1 then
      start_col = start_col + 1
      end_col = end_col - 1
    end
  end

  if end_col == 0 then
    end_row = end_row - 1
    end_col = #vim.api.nvim_buf_get_lines(0, end_row, end_row + 1, true)[1] + 1
  end

  if vim.api.nvim_get_mode().mode ~= "v" then
    vim.cmd.normal({"v", bang = true})
  end

  vim.api.nvim_win_set_cursor(0, {start_row + 1, start_col})
  vim.cmd("normal! o")
  vim.api.nvim_win_set_cursor(0, {end_row + 1, end_col - 1})
end

local function map_node_textobject(key, spec, inner)
  local scope = inner and "Inside" or "Around"

  vim.keymap.set({"x", "o"}, key, function()
    local node = find_node(spec.types)

    if node then
      select_node(node, inner, spec.trim_delimiters)
    end
  end, {desc = scope .. " " .. spec.description})
end

for suffix, spec in pairs(node_textobjects) do
  map_node_textobject("i" .. suffix, spec, true)
  map_node_textobject("a" .. suffix, spec, false)
end
