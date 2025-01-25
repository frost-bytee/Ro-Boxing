-- made by frostbyte
local start = tick()
local unloaded = false
local client = game:GetService('Players').LocalPlayer
local set_identity = (type(syn) == 'table' and syn.set_thread_identity) or setidentity or setthreadcontext

local function fail(r) return client:Kick(r) end

local usedCache = shared.__urlcache and next(shared.__urlcache) ~= nil

shared.__urlcache = shared.__urlcache or {}
local function urlLoad(url)
    local success, result

    if shared.__urlcache[url] then
        success, result = true, shared.__urlcache[url]
    else
        success, result = pcall(game.HttpGet, game, url)
    end

    if (not success) then
        return fail(string.format('Failed to GET url %q for reason: %q', url, tostring(result)))
    end

    local fn, err = loadstring(result)
    if (type(fn) ~= 'function') then
        return fail(string.format('Failed to loadstring url %q for reason: %q', url, tostring(err)))
    end

    local results = { pcall(fn) }
    if (not results[1]) then
        return fail(string.format('Failed to initialize url %q for reason: %q', url, tostring(results[2])))
    end

    shared.__urlcache[url] = result
    return unpack(results, 2)
end

local function playerCheck()
    if client.Character and client.Character:FindFirstChild("Humanoid") and client.Character:FindFirstChild("HumanoidRootPart") and client.Character.Humanoid.Health > 0 and client.Character:FindFirstChild("Head") then
        return true
    end
    return false
end

-- library
local library = urlLoad('https://raw.githubusercontent.com/fired-away/UI-Librarys/main/UWUWare%20UI.lua')
local notification = urlLoad('https://raw.githubusercontent.com/fired-away/Utilities/main/Notification.lua')

local windows = {
    autofarm = library:CreateWindow('Auto-Farm');
    extras = library:CreateWindow('Extras');
    misc = library:CreateWindow('Miscellaneous');
}

local folder = windows.autofarm:AddFolder('Cheats') do
    folder:AddToggle({
        text = 'Enabled';
        flag = 'trainingEnabled'
    })

    folder:AddList({
        text = 'Select Cheat';
        flag = 'trainingOption';
        values = {
            'Strength';
            'Fitness';
            'Speed';
            'Accuracy';
        };
        callback = function()
            print(library.flags.trainingOption)
        end
    })
end

local folder = windows.autofarm:AddFolder('Settings') do
    folder:AddList({
        text = 'Select Strength Workout';
        flag = 'strengthOption';
        values = {
            'Ropes';
            'Exercises';
            'Weights';
        }
    })

    folder:AddList({
        text = 'Select Fitness Workout';
        flag = 'fitnessOption';
        values = {
            'Treadmill';
            'Pool';
        }
    })

    folder:AddList({
        text = 'Select Speed Workout';
        flag = 'speedOption';
        values = {
            'Trampolines';
            'Bags';
        }
    })
end

local folder = windows.extras:AddFolder('Stat-Checker') do
    folder:AddBox({
        text = 'Player Name';
        flag = 'playerName';
    })

    folder:AddButton({
        text = 'Check Stats';
        callback = function()
            for  i,v in pairs(workspace['Player_Information']:GetChildren()) do
                if string.find(v.Name:lower(), library.flags.playerName:lower()) then
                    print("".."\n\nUsername: ".. v.Name .."\nStrength: ".. v.Stats.Strength.Level.Value .."\nFitness: ".. v.Stats.Fitness.Level.Value .."\nEndurance: ".. v.Stats.Endurance.Level.Value .."\nSpeed: ".. v.Stats.Speed.Level.Value .."\nAccuracy: ".. v.Stats.Accuracy.Level.Value .."\nBox Bux: ".. v["Box_Bux"].Value .."\nSparring Wins: ".. v["Sparring_Wins"].Value .."")
                    notification.Notify('Success!', 'Press F9 to view stats!', 'rbxassetid://8791722473', {
                        Duration = 7,
                        TitleSettings = {
                            TextXAlignment = Enum.TextXAlignment.Center,
                            Font = Enum.Font.SourceSansSemibold
                        },
                        GradientSettings = {
                            GradientEnabled = false,
                            SolidColorEnabled = true,
                            SolidColor = Color3.fromRGB(25, 25, 25),
                            Retract = true
                        }
                    })
                end
            end
        end
    })
end

local folder = windows.extras:AddFolder('Buy Shakes') do
    folder:AddButton({
        text = 'Buy Shakes';
        callback = function()
            replicatedStorage['Buy_Drink']:InvokeServer(library.flags.bulkShakeOption, library.flags.shakeAmount)
        end
    })    
    
    folder:AddSlider({
        text = 'Amount of Shakes';
        flag = 'shakeAmount';
        min = 1;
        max = 100;
        value = 1;
    })

    folder:AddList({
        text = 'Select Shake';
        flag = 'bulkShakeOption';
        values = {
            'Vanilla';
            'Chocolate';
            'Toxic';
        }
    })
end

local folder = windows.extras:AddFolder('Auto-Drink Shakes') do
    folder:AddToggle({
        text = 'Enabled';
        flag = 'autoDrink';
    })

    folder:AddList({
        text = 'Select Shake';
        flag = 'drinkShakeOption';
        values = {
            'Vanilla';
            'Chocolate';
            'Toxic';
        }
    })
end

local folder = windows.misc:AddFolder('Settings') do
    folder:AddButton({
        text = 'Rejoin Game';
        callback = function()
            teleportService:Teleport(game.PlaceId, client)
        end
    })
    
    folder:AddButton({
        text = 'Destroy GUI';
        callback = function()
            wait(0.5)
            unloaded = true
            library.base:ClearAllChildren()
            library.base:Destroy()
        end
    })

    folder:AddBind({
        text = 'Toggle GUI';
        key = Enum.KeyCode.RightControl;
        flag = 'toggleBind';
        callback = function()
            library:Close()
        end
    })
end
-- services
local httpService = game:GetService('HttpService')
local players = game:GetService('Players')
local replicatedStorage = game:GetService('ReplicatedStorage')
local teleportService = game:GetService('TeleportService')

-- variables
local train = {}
local pool = workspace.Pool
local playerName = nil
local ropes = nil
local strengthExercises = replicatedStorage['Strength_Exercises']

-- get ropes
table.foreach(workspace:GetChildren(), function(r, r)
    if r.Name:find('{') then
        ropes = r
    end
end)

-- get instances
local function getDummiesAndTramps(name, looking)
    for i = 1, 4 do
        local instance = workspace[name..i]
        if not looking and instance.Player.Value == client.Name or looking and not instance.In_Use.Value then
            return instance
        end
    end
end

local function getBags(name, looking)
    for i = 1, 2 do
        local instance = workspace[name..i]
        if not looking and instance.Player.Value == client.Name or looking and not instance.In_Use.Value then
            return instance
        end
    end
end

local function getWeights(name, looking)
    for i = 1, 1 do
        local instance = workspace[name..i]
        if not looking and instance.Player.Value == client.Name or looking and not instance.In_Use.Value then
            return instance
        end
    end
end

local function getExercises(name, looking)
    local instance = workspace[name..i]
    if not looking and instance.Player.Value == client.Name or looking and not instance.In_Use.Value then
        return instance
    end
end

-- train accuracy
train.Accuracy = function()
    local dummy = getDummiesAndTramps('Dummy_Punch', false)
    if typeof(dummy) == 'Instance' then
        repeat
            for i,v in pairs(dummy.Buttons:GetChildren()) do
                if v.Color == Color3.fromRGB(0, 255, 0) then
                    fireclickdetector(v.ClickDetector, 1)
                end
            end
            wait(0.1)
        until dummy.Player.Value ~= client.Name or unloaded
    elseif library.flags.trainingEnabled and not unloaded then
        local dummy = getDummiesAndTramps('Dummy_Punch', true)
        if typeof(dummy) == 'Instance' and client.Character and client.Character.HumanoidRootPart then
            client.Character.HumanoidRootPart.CFrame = CFrame.new(dummy.Touch.Position)
            wait(1)
            strengthExercises[dummy.Name]:FireServer()
        end
    end
end

-- train fitness
train.Fitness = function()
    if library.flags.fitnessOption == 'Treadmill' then
        client.Character.HumanoidRootPart.CFrame = CFrame.new(workspace.Treadmills.Treadmill['Give_Points'].Position)
        repeat
            client.Character.Humanoid:MoveTo(workspace.Treadmills.Treadmill['Give_Points'].Position)
            client.Character.Humanoid.WalkSpeed = 17
            wait(0.1)
        until not library.flags.trainingEnabled
    elseif library.flags.fitnessOption == 'Pool' then
        if pool.Touched_End1:FindFirstChild(client.Name) then
            client.Character.HumanoidRootPart.CFrame = pool.Back.CFrame + Vector3.new(0, 8, 0)
            wait(0.5)
        else
            client.Character.HumanoidRootPart.CFrame = pool.Front.CFrame + Vector3.new(0, 8, 0)
            wait(0.5)
        end
    end
end

-- train speed
train.Speed = function()
    if library.flags.speedOption == 'Trampolines' then
        local trampoline = getDummiesAndTramps('Tramp', false)
        if typeof(trampoline) == 'instance' and library.flags.trainingEnabled and not unloaded then
            wait(0.25)
        elseif library.flags.trainingEnabled and not unloaded then
            local trampoline = getDummiesandTramps('Tramp', true)
            if typeof(trampoline) == 'Instance' and client.Character and client.Character.HumanoidRootPart then
                client.Character.HumanoidRootPart.CFrame = CFrame.new(trampoline.Touch.Position)
                wait(1)
                strengthExercises[trampoline.Name]:FireServer()
                wait(0.5)
                return
            end
        end
    elseif library.flags.speedOption == 'Bags' then
        local bag = getBags('Punch_Bag', false) and getBags('Speed_Bag', false)
        if typeof(bag) == 'Instance' and library.flags.trainingEnabled and not unloaded then
            wait(0.25)
        elseif library.flags.trainingEnabled and not unloaded then
            local bag = getBags('Punch_Bag', true) or getBags('Speed_Bag', false)
            if typeof(bag) == 'Instance' and client.Character and client.Character.HumanoidRootPart then
                client.Character.HumanoidRootPart.CFrame = CFrame.new(bag.Touch.Position)
                wait(1)
                strengthExercises[bag.Name]:FireServer()
                wait(0.5)
                return
            end
        end
    end
end

-- train strength
train.Strength = function()
    if library.flags.strengthOption == 'Ropes' then
        client.Character.HumanoidRootPart.CFrame = ropes.RopeTraining.Bottom.CFrame * CFrame.new(2, 0, 0)
        wait()
        client.Character.Humanoid:MoveTo(ropes.RopeTraining.Top.Position)
        client.Character.Humanoid.Jump = true
        if client:DistanceFromCharacter(ropes.RopeTraining.Bottom.Position) < 5 then
            repeat
                local rando = math.random(1, 20)
                client.Character.Humanoid:MoveTo(ropes.RopeTraining.Top.Position)
                wait(0.1)
                if rando == 1 then
                    client.Character.Humanoid.Jump = true
                end
            until client:DistanceFromCharacter(ropes.RopeTraining.Top.Position) <= 1.7 or unloaded or not library.flags.trainingEnabled
            client.Character.Humanoid:MoveTo(client.Character.PrimaryPart.Position + Vector3.new(2, 0, 0))
        end
        wait(0.8)
    elseif library.flags.strengthOption == 'Weights' then
        local weights = getWeights('Overhead', false) and getWeights('Bicep', false) and getWeights('Squat', false) and getWeights('Bench', false)
        if typeof(weights) == 'Instance' and library.flags.trainingEnabled and not unloaded then
            wait(0.25)
        elseif library.flags.trainingEnabled and not unloaded then
            local weights = getWeights('Overhead', true) and getWeights('Bicep', true) and getWeights('Squat', true) and getWeights('Bench', true)
            if typeof(weights) == 'Instance' and client.Character and client.Character.HumanoidRootPart then
                client.Character.HumanoidRootPart.CFrame = CFrame.new(weights.Touch.Position)
                wait(1)
                strengthExercises[weights.Name]:FireServer()
                wait(0.5)
                return
            end
        end
    elseif library.flags.strengthOption == 'Exercises' then
        local exercises = getExercises('Crunches', false) and getExercises('Leg_Lift', false) and getExercises('Squat_Jumps', false) and getExercises('Push_Ups', false)
        if typeof(exercises) == 'Instance' and library.flags.trainingEnabled and not unloaded then
            wait(0.25)
        elseif library.flags.trainingEnabled and not unloaded then
            local exercises = getExercises('Crunches', true) and getExercises('Leg_Lift', true) and getExercises('Squat_Jumps', true) and getExercises('Push_Ups', true)
            if typeof(exercises) == 'Instance' and client.Character and client.Character.HumanoidRootPart then
                client.Character.HumanoidRootPart.CFrame = CFrame.new(exercises.Touch.Position)
                wait(1)
                strengthExercises[exercises.Name]:FireServer()
                wait(0.5)
                return
            end
        end
    end
end

library:Init()

-- loop
while true do
    if library.flags.trainingEnabled and playerCheck() and not unloaded then
        train[library.flags.trainingOption]()
    end
    wait(0.1)
    
    if library.flags.autoDrink then
        replicatedStorage['Drink_Shake']:InvokeServer(library.flags.drinkShakeOption)
        wait(10)
    end
    
    if unloaded then
        return
    end
    print("made by frostbyte")
loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end
