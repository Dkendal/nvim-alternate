local group = vim.api.nvim_create_augroup("nvim-alternate", { clear = true })

---Set the list of alternate files
---@param paths { [string] : number }
---@return nil
local function set_alternates(paths)
  vim.b.alternates = paths
end

---@return {[string] : number}
local function get_alternates()
  return vim.b.alternates or {}
end

---@return string[]
local function list_alternates()
  local alts = get_alternates()
  local list = {}

  for path, rank in pairs(alts) do
    table.insert(list, { rank = rank, path = path })
  end

  table.sort(list, function(a, b)
    return a.rank < b.rank
  end)

  list = vim.tbl_map(function(v)
    return v.path
  end, list)

  return list
end

local function glob2pattern(glob)
  local s = glob
  s = string.gsub(s, "*", "(.+)")
  s = string.gsub(s, "{(.-)}", function(str)
    return "(" .. string.gsub(str, ",", "|") .. ")$"
  end)
  return s
end

local function glob2capture(glob)
  local idx = 0
  local s = glob

  local function ref()
    idx = idx + 1
    return "%" .. idx
  end

  s = string.gsub(glob, "*", ref)
  s = string.gsub(s, "{(.-)}", ref)
  s = string.gsub(s, "%[(.-)%]", ref)

  return s
end

---@param opts {pattern: string[], callback: function, events: string[]}
local function autocmd(opts)
  local events = opts.events
  vim.api.nvim_create_autocmd(events, {
    group = group,
    pattern = opts.pattern,
    callback = opts.callback,
  })
end

local plug = {}

function plug.edit()
  local alts = list_alternates()

  if #alts == 1 then
    vim.cmd("edit " .. alts[1])
  elseif #alts > 1 then
    vim.ui.select(alts, {
      format_item = function(path)
        return vim.fn.fnamemodify(path, ":~:.")
      end,
    }, function(choice)
      if type(choice) == "string" then
        vim.cmd("edit " .. choice)
      end
    end)
  elseif #alts == 0 then
    print("No alternates found")
    return
  end
end

---@param file string
---@param pattern string
---@param substitute string
---@param rank integer
---@return boolean
local function try_match(file, pattern, substitute, rank)
  if not string.match(file, pattern) then
    return false
  end

  local alt_path, _ = string.gsub(file, pattern, substitute)
  local alts = get_alternates()
  alts[alt_path] = rank
  set_alternates(alts)

  return true
end

---@class alternate.GlobRule
---@field glob { [1]: string, [2]: string }
---
---@class alternate.PatternRule
---@field pattern { [1]: string, [2]: string }
---
---@alias alternate.Rule alternate.GlobRule | alternate.PatternRule
---@param opts { rules: alternate.Rule[] } | nil
local function setup(opts)
  opts = opts or {}

  assert(type(opts.rules) == "table", "Expected opts.rules to be a table, actually: " .. type(opts.rules))

  for idx, pattern in ipairs(opts.rules) do
    assert(
      type(pattern) == "table",
      "Expected opts.rules[" .. idx .. "] to be a table, actually: " .. type(pattern)
    )

    assert(
      (type(pattern.glob) == "table" and #pattern.glob == 2)
      or (type(pattern.pattern) == "table" and #pattern.pattern == 2),
      "Expected opts.rules[" .. idx .. "] to define `glob` or `pattern` as a two element tuple"
    )

    autocmd({
      events = { "BufEnter" },
      pattern = { "*" },
      group = group,
      callback = function(args)
        if pattern.glob then
          local pattern_a, pattern_b = unpack(vim.tbl_map(glob2pattern, pattern.glob))
          local sub_b, sub_a = unpack(vim.tbl_map(glob2capture, pattern.glob))

          if not try_match(args.file, pattern_a, sub_a, idx) then
            try_match(args.file, pattern_b, sub_b, idx)
          end
        elseif pattern.pattern then
          local lua_pattern, substitute = unpack(pattern.pattern)
          try_match(args.file, lua_pattern, substitute, idx)
        end
      end,
    })
  end

  vim.keymap.set("n", "<plug>(alternate-edit)", plug.edit, {})

  vim.api.nvim_create_user_command("AlternatePrint", function()
    local alt = get_alternates()

    if type(alt) == "string" then
      vim.notify("No alternates for file")
    end
  end, { force = true })
end

return {
  setup = setup,
  plug = plug,
}
