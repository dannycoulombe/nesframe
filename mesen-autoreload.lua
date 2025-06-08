local romPath = "/home/dcoulombe/dev/nesframe/dist/game.nes"
local lastContent = nil
local lastCycles = 0
local reloadCount = 0
local currentCycles = 0
local frameCount = 0
local logAddr = 252
local mustWait = false

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
