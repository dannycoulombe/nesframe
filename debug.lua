local romPath = "/home/dcoulombe/dev/nesframe/dist/game.nes"
local lastContent = nil
local lastCycles = 0
local reloadCount = 0
local currentCycles = 0
local frameCount = 0
local logAddr = 252
local mustWait = false
local BIT_SIZE = 8     -- Size of each bit square in pixels
local BIT_SPACING = 2  -- Space between bits


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

function highlightTlBrTile(tlAddress, brAddress, color, showLabel)
    local tlIndex = emu.read(tlAddress, emu.memType.nesDebug)
    local tlX, tlY = tileIndexToCoords(tlIndex, 16)
    local brIndex = emu.read(brAddress, emu.memType.nesDebug)
    local brX, brY = tileIndexToCoords(brIndex, 16)

    tlX = tlX * 16
    tlY = tlY * 16
    brX = brX * 16
    brY = brY * 16

    emu.log(brX)

    if tlX > 0 and brX > 0 then
      emu.drawRectangle(tlX, tlY, (brX - tlX) + 16, (brY - tlY) + 16, color, false, false, 0.5)

      -- Draw title
      if showLabel then
        emu.drawString(brX , brY - 10, string.format("%s", index), 0xFFFFFF, 0xFF000000)
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
    printLog(15, 230)
    displayBits(0x0026, 170, 230, false) -- Player state
--     drawPointFromHex(0x0028, 0x0000FF, false) -- Player X/Y
--     drawPointFromHex(0x0067, 0xFF0000, false) -- Collision X1/Y1
--     drawPointFromHex(0x0069, 0xFF0000) -- Collision X2/Y2
--     printMemoryValue(12, 0, "Collision: $%02X:$%02X / $%02X:$%02X", { 0x0067, 0x0068, 0x0069, 0x006A, })
--     highlightTile(0x0069, 0xFF00FF, false)
--     highlightTile(0x006A, 0xFF00FF, false)
--     highlightTile(0x006B, 0xFF00FF, false)
--     highlightTile(0x006C, 0xFF00FF, false)
--     highlightTlBrTile(0x0069, 0x006A, 0xFF00FF, false)
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

emu.addEventCallback(onFrame, emu.eventType.paint)
-- emu.addEventCallback(onFrame, emu.eventType.endFrame)
