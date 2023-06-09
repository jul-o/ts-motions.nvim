local tsu = require('nvim-treesitter.ts_utils');

local function has_child_on_other_line(node)
  local children = tsu.get_named_children(node);

  for _, child in ipairs(children) do
    if child:start() ~= node:start() or has_child_on_other_line(child) then
      return true;
    end
  end

  return false;
end

local function child()
  local current_node = tsu.get_node_at_cursor();
  local children = tsu.get_named_children(current_node);

  if #children == 0 then
    if tsu.get_next_node(current_node, true, true) ~=nil and tsu.get_next_node(current_node, true, true):start() == current_node:start() then
      tsu.goto_node(tsu.get_next_node(current_node, true, true));
      child();
      return true
    end
    return false;
  end

  print('o')

  for _, son in ipairs(children) do
    if son:start() ~= current_node:start() or has_child_on_other_line(son) then
      tsu.goto_node(son);
      if son:start() == current_node:start() then
        child();
      end
      return true;
    end
  end


end

local function parent()
  local current_node = tsu.get_node_at_cursor();
  local parent = current_node:parent();

  local initial_position = vim.api.nvim_win_get_cursor(0);
  local current_position = initial_position;

  while current_position[1] == initial_position[1]
    and parent ~= nil do
    tsu.goto_node(parent);
    current_position = vim.api.nvim_win_get_cursor(0);
    parent = parent:parent();
  end

  while parent ~= nil and parent:parent() ~= nil and parent:start() == tsu.get_node_at_cursor():start() do
    tsu.goto_node(parent)
    parent = parent:parent();
  end
end

local function next_sibling(initial_node)
  initial_node = initial_node or tsu.get_node_at_cursor();
  if (initial_node:parent() == nil) then
    return false;
  end
  local siblings = tsu.get_named_children(initial_node:parent());
  local initial_row = vim.api.nvim_win_get_cursor(0)[1]
  local current_index = 1

  while current_index <= #siblings do
    if siblings[current_index]:start() >= initial_row then
      tsu.goto_node(siblings[current_index]);
      return true;
    end
    current_index = current_index + 1
  end

  next_sibling(initial_node:parent())
  return false;
end

local function previous_sibling(initial_node)
  initial_node = initial_node or tsu.get_node_at_cursor();
  if (initial_node:parent() == nil) then
    return false;
  end

  local siblings = tsu.get_named_children(initial_node:parent());
  local initial_row = vim.api.nvim_win_get_cursor(0)[1]
  local current_index = #siblings

  while current_index >= 1 do
    if siblings[current_index]:start() < initial_row - 1 then
      tsu.goto_node(siblings[current_index]);
      return true;
    end
    current_index = current_index - 1
  end

  previous_sibling(initial_node:parent())
  return false;
end

local function setup()
  vim.api.nvim_create_user_command("JumpToChild", child, {});
  vim.api.nvim_create_user_command("JumpToParent", parent, {});
  vim.api.nvim_create_user_command("JumpToNextSibling", function() next_sibling(tsu.get_node_at_cursor()) end, {});
  vim.api.nvim_create_user_command("JumpToPreviousSibling", function() previous_sibling(tsu.get_node_at_cursor()) end, {});
end

return {
  setup = setup,
  child = child,
  parent = parent,
  next_sibling = next_sibling,
  previous_sibling = previous_sibling,
}
