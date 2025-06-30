local romPath = emu.getRomInfo()["path"]
local romDir = emu.getRomInfo().path:match("^(.*)[/\\]")
local dbgPath = romDir .. "/game.dbg"
local lastContent = nil
local lastCycles = 0
local reloadCount = 0
local currentCycles = 0
local frameCount = 0
local logAddr = 252
local mustWait = false
local BIT_SIZE = 8     -- Size of each bit square in pixels
local BIT_SPACING = 2  -- Space between bits

local address = 252  -- Change this to the address you want to watch
local history = {}
local max_entries = 10
local screen_width = 256
local font_height = 8
local first_write_skipped = false

function getDbgSymbolValue(variableName)
    local file = io.open(dbgPath, "r")
    if not file then
        error("Could not open file: " .. dbgPath)
    end

    for line in file:lines() do
        if line:match('name="' .. variableName .. '"') then
            local val = line:match("val=([%w]+)")
            file:close()
            if val then
                return tonumber(val)
            end
        end
    end

    file:close()
    return nil -- not found
end

local objMemoryAddr = getDbgSymbolValue("object_memory") + 13
local collisionBrTileAddr = getDbgSymbolValue("collision_br_tile_idx")
local collisionBlTileAddr = getDbgSymbolValue("collision_bl_tile_idx")
local collisionTrTileAddr = getDbgSymbolValue("collision_tr_tile_idx")
local collisionTrTileAddr = getDbgSymbolValue("collision_tl_tile_idx")
local playerOriDir = getDbgSymbolValue("player_ori_dir")

-- Get initial content
local function getFileContent(path)
    local file = io.open(path, "rb")  -- 'b' for binary mode
    if not file then
        return nil
    end

    local content = file:read("*all")
    file:close()
    return content
end

-- Initialize last content
lastContent = getFileContent(romPath)
if not lastContent then
    print("Error: Cannot find ROM at: " .. romPath)
    return
end

function drawPointFromHex(hex, color, showValue)
  local x = emu.read(hex, emu.memType.nesDebug)
  local y = emu.read(hex + 1, emu.memType.nesDebug)

  if x > 0 and y > 0 then
  --   emu.drawRectangle(x -1, y -1, 3, 3, 0xFFFFFF, true)  -- Filled rectangle
    emu.drawRectangle(x, y, 1, 1, color, true)  -- Filled rectangle

    if showValue then
      emu.drawString(x + 5, y - 3, string.format("$%02X:$%02X", x, y), color, 0xFF000000)
    end
  end

end

function drawHeaderTextLeft(value)
  local x = emu.read(hex, emu.memType.nesDebug)
  local y = emu.read(hex + 1, emu.memType.nesDebug)
--   emu.drawRectangle(x -1, y -1, 3, 3, 0xFFFFFF, true)  -- Filled rectangle
  emu.drawRectangle(x, y, 1, 1, color, true)  -- Filled rectangle

  if showValue then
    emu.drawString(x + 5, y - 3, string.format("$%02X:$%02X", x, y), color, 0xFF000000)
  end
end

function drawBit(x, y, isSet)
    local color = isSet and 0xFFFFFF or 0x444444  -- White for set bits, dark gray for unset
    emu.drawRectangle(x, y, BIT_SIZE, BIT_SIZE, color, true)  -- Filled rectangle
    emu.drawRectangle(x, y, BIT_SIZE, BIT_SIZE, 0x000000, false)  -- Black border
end

function tileIndexToCoords(index, mapWidth)
  local x = index % mapWidth
  local y = math.floor(index / mapWidth)
  return x, y
end

function highlightTile(address, color, showLabel)
    local index = emu.read(address, emu.memType.nesDebug)
    local x, y = tileIndexToCoords(index, 16)

    if x > 0 and y > 0 then
      emu.drawRectangle(x * 16, y * 16, 16, 16, color, false, false, 0.5)

      -- Draw title
      if showLabel then
        emu.drawString(x * 16, (y * 16) - 10, string.format("%s", index), 0xFFFFFF, 0xFF000000)
      end
    end
end

function displayBits(address, xPos, yPos, includeNumbers, includeTitle)
    local value = emu.read(address, emu.memType.nesDebug)

    -- Draw title
    if includeTitle then
      emu.drawString(xPos, yPos - 10, string.format("$%04X: $%02X", address, value), 0xFFFFFF, 0xFF000000)
    end

    -- Draw bit numbers
    if includeNumbers then
      for i = 0, 7 do
          emu.drawString(xPos + i * (BIT_SIZE + BIT_SPACING), yPos + BIT_SIZE + 2, tostring(7-i), 0xFFFFFF, 0xFF000000)
      end
    end

    -- Draw bits
    for bit = 0, 7 do
        local isSet = (value & (1 << (7-bit))) ~= 0
        local x = xPos + bit * (BIT_SIZE + BIT_SPACING)
        drawBit(x, yPos, isSet)
    end
end

function printMemoryValue(xPos, yPos, format, addresses)
  local values = {}
  for i, addr in ipairs(addresses) do
      values[i] = emu.read(addr, emu.memType.nesDebug)
  end
  emu.drawString(xPos, yPos, string.format(format, table.unpack(values)), 0xFFFFFF, 0xFF000000)
end

function printLog(xPos, yPos)
  state = emu.getState()
  value1 = string.format("%04X", emu.read16(logAddr, emu.memType.nesDebug))
  value2 = string.format("%04X", emu.read16(logAddr + 2, emu.memType.nesDebug))

  local cyclesDiff = state["cpu.cycleCount"] - lastCycles
  emu.drawString(xPos, yPos, "Log: #" .. value1 .. " : #" .. value2, 0xFFFFFF, 0xFF000000)
  lastCycles = state["cpu.cycleCount"]
end

function checkFile()
  local currentContent = getFileContent(romPath)
  if currentContent then
    if currentContent ~= lastContent then
      reloadCount = reloadCount + 1
      lastContent = currentContent
      mustWait = true
      emu.reload()
    end
  else
    print("Error: Cannot find ROM at: " .. romPath)
  end
end

function onFrame()
  frameCount = frameCount + 1
  if mustWait ~= true then
    displayBits(objMemoryAddr, 170, 230, false) -- Obj memory
--     displayBits(playerOriDirAddr, 170, 220, false) -- Player state
--     drawPointFromHex(0x0028, 0x0000FF, false) -- Player X/Y
--     drawPointFromHex(0x0067, 0xFF0000, false) -- Collision X1/Y1
--     drawPointFromHex(0x0069, 0xFF0000) -- Collision X2/Y2
--     highlightTile(collisionBrTileAddr, 0xFF00FF, false)
--     highlightTile(collisionBlTileAddr, 0xFF00FF, false)
--     highlightTile(collisionTrTileAddr, 0xFF00FF, false)
--     highlightTile(collisionTrTileAddr, 0xFF00FF, false)
    onDrawCallback()
  end
  if frameCount >= 60 then
    if mustWait ~= true then
      frameCount = 0
      checkFile()
    elseif frameCount >= 180 then
      mustWait = false
    end
  end
end

function onWriteCallback(addr, value)
    if not first_write_skipped then
        first_write_skipped = true
        return
    end
    table.insert(history, string.format("(#%01d) $%02X:$%02X", #history + 1, addr, value))
end
-- Draw the values on screen
function onDrawCallback()
    local start_index = math.max(1, #history - max_entries + 1)
    for i = start_index, #history do
        local text = history[i]
        local y = 235 - ((#history - i + 1) * font_height)
        emu.drawString(10, y, text, 0xFFFFFF, 0xCC000000)
    end
end

emu.addMemoryCallback(onWriteCallback, emu.callbackType.write, address, address, emu.cpuType.nes, emu.memType.nesMemory)
emu.addEventCallback(onFrame, emu.eventType.paint)
