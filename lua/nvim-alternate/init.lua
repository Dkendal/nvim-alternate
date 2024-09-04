local group = vim.api.nvim_create_augroup("nvim-alternate", { clear = true })

---Set the list of alternate files
---@param paths string
---@return nil
local function set_alternates(paths)
  vim.print("Setting alternates to " .. paths)
  vim.b.alternate = paths
end

---@return string
local function get_alternates()
  return vim.b.alternate
end

local function glob2re(glob)
  local s = glob
  s = string.gsub(s, "*", "(.+)")
  s = string.gsub(s, "{(.-)}", function(str)
    return "(" .. string.gsub(str, ",", "|") .. ")"
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
  local events = opts.events or { "BufEnter", "BufWinEnter" }

  vim.api.nvim_create_autocmd(events, {
    group = group,
    pattern = opts.pattern,
    callback = opts.callback,
  })
end

---Map a file to an alternate file
---@param file string
---@param pattern string
---@param substitute string
---@param opts {glob: boolean} | nil
---@return string
local function map_alternate(file, pattern, substitute, opts)
  if opts and opts.glob then
    pattern = glob2re(pattern)
    substitute = glob2capture(substitute)
  end

  file = vim.fn.fnamemodify(file, ":~:.")

  local out, _ = string.gsub(file, pattern, substitute)

  return out
end


---comment
---@param patternA string
---@param patternB string
---@return nil
local function alternate_pair(patternA, patternB)
  autocmd({
    pattern = { patternA },
    callback = function(args)
      set_alternates(map_alternate(args.file, patternA, patternB, { glob = true }))
    end,
  })

  autocmd({
    pattern = { patternB },
    callback = function(args)
      set_alternates(map_alternate(args.file, patternB, patternA, { glob = true }))
    end,
  })
end

local plug = {}

function plug.edit()
  local path = get_alternates()

  if path == nil then
    print("No alternates found")
    return
  else
    assert(type(path) == "string", "expected path to be a string")
    vim.cmd("edit " .. path)
  end
end

---@param opts { pairs: ([string, string] | [string[], string, string])[] } | nil
local function setup(opts)
  opts = opts or {}
  local opts_pairs = opts.pairs or {}

  for _, patterns in ipairs(opts_pairs) do
    if #patterns == 2 then
      local a = patterns[1]
      local b = patterns[2]
      assert(type(a) == "string", "config.pairs[][1] must be a string")
      assert(type(b) == "string", "config.pairs[][2] must be a string")
      alternate_pair(a, b)
    elseif #patterns == 3 then
      local autocmd_pattern = patterns[1]
      local file_pattern = patterns[2]
      local file_substitute = patterns[3]

      assert(type(autocmd_pattern) == "table", "config.pairs[][1] must be a string[]")

      for idx, pat in ipairs(autocmd_pattern) do
        assert(type(pat) == "string", string.format("config.pairs[][1][%d] must be a string[]", idx))
      end

      assert(type(file_pattern) == "string", "config.pairs[][2] must be a string")
      assert(type(file_substitute) == "string", "config.pairs[][3] must be a string")

      autocmd({
        pattern = autocmd_pattern,
        callback = function(args)
          set_alternates(map_alternate(args.file, file_pattern, file_substitute, { glob = false }))
        end,
      })
    end
  end

  vim.keymap.set("n", "<plug>(alternate-edit)", plug.edit, {})

  vim.api.nvim_create_user_command("AlternatePrint", function()
    local alt = get_alternates()

    if type(alt) == "string" then
      print("No alternates")
      return
    else
      vim.print(vim.inspect(alt))
    end
  end, { force = true })
end

return {
  setup = setup,
  plug = plug,
  map_alternate = map_alternate,
}
