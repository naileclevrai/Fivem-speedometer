local isInVehicle = false
local currentVehicle = 0
local lastSpeed = -1
local lastRPM = -1
local lastGear = -1
local lastEngineState = nil
local lastSeatbeltState = nil
local threadActive = false

local function GetSpeed(vehicle)
    local speed = GetEntitySpeed(vehicle)
    if Config.Unit == "mph" then
        return speed * 2.23694
    else
        return speed * 3.6
    end
end

local function GetRPM(vehicle)
    if not Config.ShowRPM then return 0 end
    
    local speed = GetEntitySpeed(vehicle)
    local gear = GetVehicleCurrentGear(vehicle)
    
    if gear <= 0 then return 0 end
    
    local baseRPM = (speed * 100) / math.max(gear, 1)
    local rpm = math.min(baseRPM, 8000)
    
    return math.floor(rpm)
end

local function GetGear(vehicle)
    if not Config.ShowGear then return 0 end
    
    local gear = GetVehicleCurrentGear(vehicle)
    if gear < 0 then return 0 end
    return gear
end

local function IsEngineOn(vehicle)
    if not Config.ShowEngine then return true end
    return GetIsVehicleEngineRunning(vehicle)
end

local function HasSeatbelt()
    if not Config.ShowSeatbelt then return true end
    return true
end
local function UpdateNUI()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    
    if vehicle == 0 then
        if isInVehicle then
            isInVehicle = false
            currentVehicle = 0
            SendNUIMessage({
                action = "hide"
            })
        end
        return
    end
    
    if not isInVehicle then
        isInVehicle = true
        currentVehicle = vehicle
        SendNUIMessage({
            action = "show"
        })
    end
    
    local speed = GetSpeed(vehicle)
    local rpm = GetRPM(vehicle)
    local gear = GetGear(vehicle)
    local engine = IsEngineOn(vehicle)
    local seatbelt = HasSeatbelt()
    
    local isStopped = speed < Config.SpeedThreshold
    
    if Config.HideWhenStopped and isStopped then
        if isInVehicle then
            SendNUIMessage({
                action = "hide"
            })
        end
        return
    end
    
    local hasChanged = false
    local dataToSend = {}
    
    if math.abs(speed - lastSpeed) > 0.1 then
        dataToSend.speed = math.floor(speed)
        lastSpeed = speed
        hasChanged = true
    end
    
    if Config.ShowRPM and math.abs(rpm - lastRPM) > 10 then
        dataToSend.rpm = rpm
        lastRPM = rpm
        hasChanged = true
    end
    
    if Config.ShowGear and gear ~= lastGear then
        dataToSend.gear = gear
        lastGear = gear
        hasChanged = true
    end
    
    if Config.ShowEngine and engine ~= lastEngineState then
        dataToSend.engine = engine
        lastEngineState = engine
        hasChanged = true
    end
    
    if Config.ShowSeatbelt and seatbelt ~= lastSeatbeltState then
        dataToSend.seatbelt = seatbelt
        lastSeatbeltState = seatbelt
        hasChanged = true
    end
    
    if hasChanged then
        dataToSend.action = "update"
        dataToSend.unit = Config.Unit
        dataToSend.maxSpeed = Config.Unit == "mph" and Config.MaxSpeedMph or Config.MaxSpeed
        SendNUIMessage(dataToSend)
    end
end
local function StartSpeedometerThread()
    if threadActive then return end
    threadActive = true
    
    Citizen.CreateThread(function()
        while Config.Enabled do
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            
            if vehicle ~= 0 then
                UpdateNUI()
                
                local speed = GetEntitySpeed(vehicle)
                if speed < Config.SpeedThreshold then
                    Citizen.Wait(Config.IdleUpdateRate)
                else
                    Citizen.Wait(Config.UpdateRate)
                end
            else
                if isInVehicle then
                    isInVehicle = false
                    currentVehicle = 0
                    SendNUIMessage({
                        action = "hide"
                    })
                end
                Citizen.Wait(1000)
            end
        end
        threadActive = false
    end)
end

Citizen.CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Citizen.Wait(100)
    end
    
    SendNUIMessage({
        action = "init",
        config = {
            unit = Config.Unit,
            maxSpeed = Config.Unit == "mph" and Config.MaxSpeedMph or Config.MaxSpeed,
            position = Config.Position,
            theme = Config.Theme,
            showRPM = Config.ShowRPM,
            showGear = Config.ShowGear,
            showSeatbelt = Config.ShowSeatbelt,
            showEngine = Config.ShowEngine
        }
    })
    
    if Config.Enabled then
        StartSpeedometerThread()
    end
end)
RegisterCommand("speedometer", function()
    Config.Enabled = not Config.Enabled
    if Config.Enabled then
        StartSpeedometerThread()
    else
        SendNUIMessage({
            action = "hide"
        })
    end
end, false)
