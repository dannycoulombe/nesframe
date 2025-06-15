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

function drawPointFromHex(hex, color)
  local x = emu.read(hex, emu.memType.nesDebug) - 1
  local y = emu.read(hex + 1, emu.memType.nesDebug) - 1
  emu.drawRectangle(x -1, y -1, 3, 3, 0xFFFFFF, true)  -- Filled rectangle
  emu.drawRectangle(x, y, 1, 1, color, true)  -- Filled rectangle
end

function drawBit(x, y, isSet)
    local color = isSet and 0xFFFFFF or 0x444444  -- White for set bits, dark gray for unset
    emu.drawRectangle(x, y, BIT_SIZE, BIT_SIZE, color, true)  -- Filled rectangle
    emu.drawRectangle(x, y, BIT_SIZE, BIT_SIZE, 0x000000, false)  -- Black border
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


function printLog()
  state = emu.getState()
  value1 = string.format("%04X", emu.read16(logAddr, emu.memType.nesDebug))
  value2 = string.format("%04X", emu.read16(logAddr + 2, emu.memType.nesDebug))

  local cyclesDiff = state["cpu.cycleCount"] - lastCycles
  emu.drawString(15, 220, "Log: #" .. value1 .. " : #" .. value2, 0xFFFFFF, 0xFF000000)
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
    printLog()
    displayBits(0x002A, 170, 220, false) -- Player state
    drawPointFromHex(0x002C, 0x0000FF) -- Player X/Y
    drawPointFromHex(0x0068, 0xFF0000) -- Collision X/Y
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

emu.addEventCallback(onFrame, emu.eventType.endFrame)
