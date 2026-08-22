--!nonstrict

local STATE_KEY = "mode"

local DEFAULT_GLYPH = {
  scrolling = "carousel-horizontal",
  dwindle = "binary-tree",
}

local cfg = {}
local mode = nil
local pending = false

local function trim(value)
  return (tostring(value or ""):gsub("^%s*(.-)%s*$", "%1"))
end

local function isMode(value)
  return value == "scrolling" or value == "dwindle"
end

local function otherMode(value)
  return value == "dwindle" and "scrolling" or "dwindle"
end

local function getString(key)
  return trim(noctalia.getConfig(key))
end

local function readConfig()
  cfg = {
    displayMode = getString("display_mode"),
    glyph = {
      scrolling = getString("scrolling_glyph"),
      dwindle = getString("dwindle_glyph"),
    },
    word = {
      scrolling = getString("scrolling_word"),
      dwindle = getString("dwindle_word"),
    },
    letter = {
      scrolling = getString("scrolling_letter"),
      dwindle = getString("dwindle_letter"),
    },
    color = noctalia.getConfig("color"),
    glyphSize = noctalia.getConfig("glyph_size"),
    fontSize = noctalia.getConfig("font_size"),
    gap = noctalia.getConfig("gap"),
    uppercaseLetter = noctalia.getConfig("uppercase_letter"),
    showTooltip = noctalia.getConfig("show_tooltip"),
    notifyOnToggle = noctalia.getConfig("notify_on_toggle"),
    initialMode = getString("initial_mode"),
    configPath = getString("umbriel_config_path"),
  }
end

local function glyphFor(value)
  local custom = cfg.glyph[value]
  if custom ~= "" then
    return custom
  end
  return DEFAULT_GLYPH[value]
end

local function wordFor(value)
  local custom = cfg.word[value]
  if custom ~= "" then
    return custom
  end
  return noctalia.tr("layout." .. value)
end

local function firstChar(text)
  local lead = text:byte(1)
  if lead == nil then
    return ""
  end
  local width = 1
  if lead >= 0xF0 then
    width = 4
  elseif lead >= 0xE0 then
    width = 3
  elseif lead >= 0xC0 then
    width = 2
  end
  return text:sub(1, width)
end

local function letterFor(value)
  local custom = cfg.letter[value]
  if custom ~= "" then
    return custom
  end
  local letter = firstChar(wordFor(value))
  return cfg.uppercaseLetter and letter:upper() or letter
end

local function wantsGlyph()
  local display = cfg.displayMode
  return display == "icon" or display == "icon_letter" or display == "icon_word"
end

local function textFor(value)
  local display = cfg.displayMode
  if display == "letter" or display == "icon_letter" then
    return letterFor(value)
  end
  if display == "word" or display == "icon_word" then
    return wordFor(value)
  end
  return ""
end

local function render()
  if not isMode(mode) then
    return
  end

  local children = {}

  if wantsGlyph() then
    children[#children + 1] = ui.glyph({
      key = "glyph",
      name = glyphFor(mode),
      size = cfg.glyphSize,
      color = cfg.color,
    })
  end

  local text = textFor(mode)
  if text ~= "" then
    children[#children + 1] = ui.label({
      key = "label",
      text = text,
      fontSize = cfg.fontSize,
      color = cfg.color,
    })
  end

  if #children == 0 then
    children[1] = ui.label({
      key = "label",
      text = letterFor(mode),
      fontSize = cfg.fontSize,
      color = cfg.color,
    })
  end

  local container = barWidget.isVertical() and ui.column or ui.row
  barWidget.render(container({ gap = cfg.gap, align = "center" }, children))

  if cfg.showTooltip then
    barWidget.setTooltip(noctalia.tr("tooltip", {
      current = wordFor(mode),
      next = wordFor(otherMode(mode)),
    }))
  else
    barWidget.clearTooltip()
  end
end

local function publish(value)
  mode = value
  noctalia.state.set(STATE_KEY, value)
  render()
end

local function modeFromUmbrielConfig()
  local path = cfg.configPath
  if path == "" then
    local configHome = noctalia.getenv("XDG_CONFIG_HOME")
    if configHome ~= nil and configHome ~= "" then
      path = configHome .. "/umbriel/config.toml"
    else
      path = noctalia.expandPath("~/.config/umbriel/config.toml")
    end
  else
    path = noctalia.expandPath(path)
  end

  local text = noctalia.readFile(path)
  if text == nil or text == "" then
    return nil
  end

  local section = ""
  for line in (text .. "\n"):gmatch("([^\n]*)\n") do
    local stripped = trim((line:gsub("#.*$", "")))
    local header = stripped:match("^%[%[%s*(.-)%s*%]%]$") or stripped:match("^%[%s*(.-)%s*%]$")
    if header ~= nil then
      section = header
    elseif section == "layout" then
      local value = stripped:match('^mode%s*=%s*"(.-)"') or stripped:match("^mode%s*=%s*'(.-)'")
      if isMode(value) then
        return value
      end
    end
  end
  return nil
end

local function seedMode()
  local shared = noctalia.state.get(STATE_KEY)
  if isMode(shared) then
    mode = shared
    return
  end

  local seed
  if isMode(cfg.initialMode) then
    seed = cfg.initialMode
  else
    seed = modeFromUmbrielConfig() or "scrolling"
  end
  publish(seed)
end

local function apply(next)
  if not isMode(next) or pending then
    return
  end
  pending = true

  local started = noctalia.runAsync({ "umbriel", "msg", "workspace-set-layout:" .. next }, function(result)
    pending = false
    if result.exitCode ~= 0 then
      local detail = trim(result.stderr)
      if detail == "" then
        detail = trim(result.stdout)
      end
      if detail == "" then
        detail = noctalia.tr("error.exit", { code = tostring(result.exitCode) })
      end
      noctalia.notifyError(noctalia.tr("error.title"), detail)
      return
    end

    publish(next)
    if cfg.notifyOnToggle then
      noctalia.notify(noctalia.tr("notify.title"), wordFor(next))
    end
  end)

  if not started then
    pending = false
    noctalia.notifyError(noctalia.tr("error.title"), noctalia.tr("error.spawn"))
  end
end

function onClick()
  apply(otherMode(mode))
end

function onIpc(event, payload)
  local value = trim(payload)
  if event == "toggle" then
    apply(otherMode(mode))
  elseif event == "set" then
    apply(value)
  elseif event == "sync" then
    if isMode(value) then
      publish(value)
    end
  end
end

function onConfigChanged()
  readConfig()
  render()
end

readConfig()

noctalia.state.watch(STATE_KEY, function(value)
  if isMode(value) and value ~= mode then
    mode = value
    render()
  end
end)

seedMode()
render()
