local tsu = require('nvim-treesitter.ts_utils');

local function child() 
  local current_node = tsu.get_node_at_cursor();

  local children = tsu.get_named_children(current_node);
  if children[1] then
    tsu.goto_node(children[1]);
  else
    tsu.goto_node(tsu.get_next_node(current_node, true, true))
  end
end

local function parent()
  local current_node = tsu.get_node_at_cursor();
  local parent = current_node:parent();

  local initial_position = vim.api.nvim_win_get_cursor(0);
  local current_position = initial_position;

  while current_position[1] == initial_position[1]
    and current_position[2] == initial_position[2] 
    and parent ~= nil do
    tsu.goto_node(parent);
    current_position = vim.api.nvim_win_get_cursor(0);
    parent = parent:parent();
  end
end

local function next_sibling(initial_node)
  initial_node = initial_node or tsu.get_node_at_cursor();
  local siblings = tsu.get_named_children(initial_node:parent());
  local found = false

  for i, sibling in ipairs(siblings) do
    if sibling == initial_node and siblings[i + 1] ~= nil then
      tsu.goto_node(siblings[i + 1])
      found = true
    end
  end

  if not found then
    print('nope')
    next_sibling(initial_node:parent())
  end
end

local function previous_sibling()
  local current_node = tsu.get_node_at_cursor();
  local sibling = tsu.get_previous_node(current_node, true, true);

  tsu.goto_node(sibling)
end

local function setup()
  vim.api.nvim_create_user_command("JumpToChild", child, {});
  vim.api.nvim_create_user_command("JumpToParent", parent, {});
  vim.api.nvim_create_user_command("JumpToNextSibling", function() next_sibling(tsu.get_node_at_cursor()) end, {});
  vim.api.nvim_create_user_command("JumpToPreviousSibling", previous_sibling, {});
end

return {
  setup = setup,
  child = child,
  parent = parent,
  next_sibling = next_sibling,
  previous_sibling = previous_sibling,
}
