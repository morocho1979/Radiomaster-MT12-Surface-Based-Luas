------- GLOBALS -------
-- The model name when it can't detect a model name from the handset
local modelName = "Unknown"
local lowVoltage = 6.6
local currentVoltage = 8.4
local highVoltage = 8.4
-- For our timer tracking
local timerLeft = 0
local maxTimerValue = 0
-- Our global to get our current rssi
local rssi = 0
-- Define the screen size
local screen_width = 128
local screen_height = 64

local function convertVoltageToPercentage(voltage)
  local curVolPercent = math.ceil(((((highVoltage - voltage) / (highVoltage - lowVoltage)) - 1) * -1) * 100)
  if curVolPercent < 0 then
    curVolPercent = 0
  end
  if curVolPercent > 100 then
    curVolPercent = 100
  end
  return curVolPercent
end

local function drawTransmitterVoltage(start_x,start_y,voltage)
  
  local batteryWidth = 17
  
  -- Battery Outline
  lcd.drawRectangle(start_x, start_y, batteryWidth + 2, 6, SOLID)
  lcd.drawLine(start_x + batteryWidth + 2, start_y + 1, start_x + batteryWidth + 2, start_y + 4, SOLID, FORCE) -- Positive Nub

  -- Battery Percentage (after battery)
  local curVolPercent = convertVoltageToPercentage(voltage)
  if curVolPercent < 20 then
    lcd.drawText(start_x + batteryWidth + 5, start_y, curVolPercent.."%", SMLSIZE + BLINK)
  else
    if curVolPercent == 100 then
      lcd.drawText(start_x + batteryWidth + 5, start_y, "99%", SMLSIZE)
    else
      lcd.drawText(start_x + batteryWidth + 5, start_y, curVolPercent.."%", SMLSIZE)
    end
      
  end
  
  -- Filled in battery
  local pixels = math.ceil((curVolPercent / 100) * batteryWidth)
  if pixels == 1 then
    lcd.drawLine(start_x + pixels, start_y + 1, start_x + pixels, start_y + 4, SOLID, FORCE)
  end
  if pixels > 1 then
    lcd.drawRectangle(start_x + 1, start_y + 1, pixels, 4)
  end
  if pixels > 2 then
    lcd.drawRectangle(start_x + 2, start_y + 2, pixels - 1, 2)
    lcd.drawLine(start_x + pixels, start_y + 2, start_x + pixels, start_y + 3, SOLID, FORCE)
  end
end

local function drawTime()
  -- Draw date time
  local datenow = getDateTime()
  local min = datenow.min .. ""
  if datenow.min < 10 then
    min = "0" .. min
  end
  local hour = datenow.hour .. ""
  if datenow.hour < 10 then
    hour = "0" .. hour
  end
  if math.ceil(math.fmod(getTime() / 100, 2)) == 1 then
    hour = hour .. ":"
  end
  lcd.drawText(107,0,hour, SMLSIZE)
  lcd.drawText(119,0,min, SMLSIZE)
end

  
local function drawVoltageImage(start_x, start_y)
  
  -- Define the battery width (so we can adjust it later)
  local batteryWidth = 12 

  -- Draw our battery outline
  lcd.drawLine(start_x + 2, start_y + 1, start_x + batteryWidth - 2, start_y + 1, SOLID, 0)
  lcd.drawLine(start_x, start_y + 2, start_x + batteryWidth - 1, start_y + 2, SOLID, 0)
  lcd.drawLine(start_x, start_y + 2, start_x, start_y + 50, SOLID, 0)
  lcd.drawLine(start_x, start_y + 50, start_x + batteryWidth - 1, start_y + 50, SOLID, 0)
  lcd.drawLine(start_x + batteryWidth, start_y + 3, start_x + batteryWidth, start_y + 49, SOLID, 0)

  -- top one eighth line
  lcd.drawLine(start_x + batteryWidth - math.ceil(batteryWidth / 4), start_y + 8, start_x + batteryWidth - 1, start_y + 8, SOLID, 0)
  -- top quarter line
  lcd.drawLine(start_x + batteryWidth - math.ceil(batteryWidth / 2), start_y + 14, start_x + batteryWidth - 1, start_y + 14, SOLID, 0)
  -- third eighth line
  lcd.drawLine(start_x + batteryWidth - math.ceil(batteryWidth / 4), start_y + 20, start_x + batteryWidth - 1, start_y + 20, SOLID, 0)
  -- Middle line
  lcd.drawLine(start_x + 1, start_y + 26, start_x + batteryWidth - 1, start_y + 26, SOLID, 0)
  -- five eighth line
  lcd.drawLine(start_x + batteryWidth - math.ceil(batteryWidth / 4), start_y + 32, start_x + batteryWidth - 1, start_y + 32, SOLID, 0)
  -- bottom quarter line
  lcd.drawLine(start_x + batteryWidth - math.ceil(batteryWidth / 2), start_y + 38, start_x + batteryWidth - 1, start_y + 38, SOLID, 0)
  -- seven eighth line
  lcd.drawLine(start_x + batteryWidth - math.ceil(batteryWidth / 4), start_y + 44, start_x + batteryWidth - 1, start_y + 44, SOLID, 0)
  

  -- Now draw how full our voltage is...
  local totalvoltage = getValue('RxBt')
  local voltage = totalvoltage/3
  voltageLow = 3.3
  voltageHigh = 4.2
  voltageIncrement = ((voltageHigh - voltageLow) / 47)
  
  local offset = 0  -- Start from the bottom up
  while offset < 47 do
    if ((offset * voltageIncrement) + voltageLow) < tonumber(voltage) then
      lcd.drawLine( start_x + 1, start_y + 49 - offset, start_x + batteryWidth - 1, start_y + 49 - offset, SOLID, 0)
    end
    offset = offset + 1
  end
end

local function drawtables()



lcd.drawFilledRectangle(89, 10, 30, 13, GREY_DEFAULT)
lcd.drawRectangle(89, 23, 30, 13, GREY_DEFAULT)
lcd.drawFilledRectangle(89, 36, 30, 13, GREY_DEFAULT)
lcd.drawRectangle(89, 49, 30, 13, GREY_DEFAULT)
lcd.drawText (90,13, "WINCH", INVERS,SMLSIZE)
lcd.drawText (93,39, "ACC", INVERS)

end



-- Define the size and position of the "Vehicle" shape
local vehicle_width = 16
local vehicle_height = 30
local vehicle_driveshaft_width = 2 -- Adjusted thickness of the driveshaft
local vehicle_x = (screen_width - vehicle_width) / 2 - 5 -- Move left by 5 pixels
local vehicle_y = (screen_height +15 - vehicle_height) / 2
-- Define the width of the axles
local axle_width = 4 -- Adjusted width of the axles
-- Define the size of the wheels
local wheel_width = 6
local wheel_height = 10


-- Function to draw the graphical representation of the transmission 
local function draw_vehicle()
    lcd.drawFilledRectangle(vehicle_x + (vehicle_width - vehicle_driveshaft_width) / 2, vehicle_y + 2, vehicle_driveshaft_width, vehicle_height - 6)
    local transmission_size = 6
    local transmission_x = vehicle_x + (vehicle_width - transmission_size) / 2
    local transmission_y = vehicle_y + (vehicle_height - transmission_size) / 2
    lcd.drawRectangle(transmission_x, transmission_y, transmission_size, transmission_size)

    -- Draw the axles
    lcd.drawFilledRectangle(vehicle_x - 2, vehicle_y - 2, vehicle_width + 4, axle_width)
    lcd.drawFilledRectangle(vehicle_x - 2, vehicle_y + vehicle_height - axle_width, vehicle_width + 4, axle_width)

    -- Draw the front wheels 
    lcd.drawRectangle(vehicle_x - 2 - wheel_width, vehicle_y - 5, wheel_width, wheel_height)
    lcd.drawRectangle(vehicle_x - 2 + vehicle_width + 4, vehicle_y - 5, wheel_width, wheel_height)

    -- Draw the rear wheels 
    lcd.drawRectangle(vehicle_x - 2 - wheel_width, vehicle_y + vehicle_height - wheel_height + 3, wheel_width, wheel_height)
    lcd.drawRectangle(vehicle_x - 2 + vehicle_width + 4, vehicle_y + vehicle_height - wheel_height + 3, wheel_width, wheel_height)
end

-- Draw L when in low speed
local function indicate_low_speed()
    local letter_l_size = 14 -- Adjusted font size
    local letter_l_x = vehicle_x + (vehicle_width - vehicle_driveshaft_width + 7) / 2 - letter_l_size -- Move to the left of the upright part
    local letter_l_y = vehicle_y + (vehicle_height - letter_l_size + 6) / 2
    lcd.drawText(letter_l_x, letter_l_y, "L", SMLSIZE) -- Adjusted font size
end

-- Draw H when in high speed 
local function indicate_high_speed()
    local letter_h_size = 14 -- Adjusted font size
    local letter_h_x = vehicle_x + (vehicle_width + vehicle_driveshaft_width + 14) / 2 -- Move to the right of the upright part
    local letter_h_y = vehicle_y + (vehicle_height - letter_h_size + 6) / 2
    lcd.drawText(letter_h_x, letter_h_y, "H", SMLSIZE) -- Adjusted font size
end

-- Fill wheels when diffs locked CHANGE CHANNEL NUMBERS IN LINES 373 AND 387 AND CHANNEL VALUES IN 374 AND 379 TO SUIT YOUR MODEL 
local function draw_locked_diffs()

    local channel_5_value = getValue("ch5") 
    if channel_5_value > 0 then
        lcd.drawFilledRectangle(vehicle_x - 2 - wheel_width, vehicle_y - 5, wheel_width, wheel_height)
        lcd.drawFilledRectangle(vehicle_x - 2 + vehicle_width + 4, vehicle_y - 5, wheel_width, wheel_height)
  end
  local channel_6_value = getValue("ch6")
    if channel_6_value > 0 then
    lcd.drawFilledRectangle(vehicle_x - 2 - wheel_width, vehicle_y + vehicle_height - wheel_height + 3, wheel_width, wheel_height)
    lcd.drawFilledRectangle(vehicle_x - 2 + vehicle_width + 4, vehicle_y + vehicle_height - wheel_height + 3, wheel_width, wheel_height)
    end
end





--winch 
local function winch()
local wiin = getValue ("gvar3")
local wiout = getValue ("gvar4")
if wiout <  0 then 
lcd.drawText (93,26, "OUT")
end
if wiin > 0 then 
lcd.drawText (93,26, "IN")
end
if wiin == wiout then 
lcd.drawText (93,26, "Dis")
end
end
--Cruise Control 
local function acc()
local accpos = getValue ("gvar2")
if accpos == 100 then 
lcd.drawText (93,52, "ACT")
end
if accpos == -100 then 
lcd.drawText (93,52, "OFF")
end
end
--Disable TH 
local function brk()
local brkpos = getValue ("gvar5")
if brkpos == 100 then 
lcd.drawText (29,52, "ACT")
end
if brkpos == -100 then 
lcd.drawText (29,52, "Dis")
end

--"speed Gearbox "
 -- Display L for low speed.  Change channel number line 403 and value line 404 to suit your model
    local channel_3_value = getValue("ch4")
    if channel_3_value  < 0 then
    indicate_low_speed()
    end

  --Display H for high speed.  Change channel number line 403 and value line 409 to suit your model
    if channel_3_value > 100 then
        -- Draw the same size letter "H" to the right of the upright part
        indicate_high_speed()
    end
end
local function gatherInput(event)
  rssi = getRSSI()
  timerLeft = getValue('timer1')
    if timerLeft > maxTimerValue then
    maxTimerValue = timerLeft
  end
  currentVoltage = getValue('tx-voltage')

end


local function run(event)
  
  lcd.clear()
  gatherInput(event)
  
  lcd.drawLine(0, 7, 128, 7, SOLID, FORCE)
  lcd.drawText( 64 - math.ceil((#modelName * 5) / 2),0, modelName, SMLSIZE)
  drawTransmitterVoltage(0,0, currentVoltage)
  draw_vehicle()
  drawTime()
  drawVoltageImage(3, 10)
  drawtables()
  winch()
  acc()
  brk()
  indicate_low_speed()
  draw_locked_diffs()
     
end


local function init_func()
  local modeldata = model.getInfo()
  if modeldata then
    modelName = modeldata['name']
  end
end


return { run=run, init=init_func  }
