--- ============================
---          Constants
--- ============================

local AnimationFlags =
{
    ANIM_FLAG_NORMAL = 0,
    ANIM_FLAG_ENABLE_PLAYER_CONTROL = 32,
};

local ParkourDictionaries = {
    one = 'parkour@anims',
    two = 'parkour_part_2@anim',
}

local ParkourAnimations = {
    jump = {
        bigJump = { dictionary = ParkourDictionaries.one, name = 'big_jump_01', },
        swingJump = { dictionary = ParkourDictionaries.one, name = 'swing_jump', },
        frontTwistFlip = { dictionary = ParkourDictionaries.one, name = 'front_twist_flip', },
        balanceJump = { dictionary = ParkourDictionaries.two, name = 'balance_jump_f', },
    },
    vault = {
        jumpOverOne = { dictionary = ParkourDictionaries.one, name = 'jump_over_01', },
        jumpOverTwo = { dictionary = ParkourDictionaries.one, name = 'jump_over_02', },
        jumpOverThree = { dictionary = ParkourDictionaries.one, name = 'jump_over_03', },
        kashVault = { dictionary = ParkourDictionaries.two, name = 'kash_vault', },
        monkeyVault = { dictionary = ParkourDictionaries.two, name = 'monkey_vault', },
        reverseVault = { dictionary = ParkourDictionaries.two, name = 'revers_l_vault', },
        rollVault = { dictionary = ParkourDictionaries.two, name = 'roll_a_vault', },
        safetyVault = { dictionary = ParkourDictionaries.two, name = 'safety_l_vault', },
        slideVault = { dictionary = ParkourDictionaries.two, name = 'slide_r_vault', },
    },
    slide = {
        slideNormal = { dictionary = ParkourDictionaries.one, name = 'slide', },
        slideBack = { dictionary = ParkourDictionaries.one, name = 'slide_backside', },
        slideUp = { dictionary = ParkourDictionaries.one, name = 'slide_kip_up', },
    },
    wall = {
        wallFlip = { dictionary = 'parkour@anims', name = 'wall_flip', },
        wallRunLeft = { dictionary = ParkourDictionaries.two, name = 'wallrun_left_side', },
        wallRunRight = { dictionary = ParkourDictionaries.two, name = 'wallrun_right_side', },
        tictakLeft = { dictionary = ParkourDictionaries.two, name = 'tictak_l_vault', },
        tictakRight = { dictionary = ParkourDictionaries.two, name = 'tictak_r_vault', },
    },
    ledge = {
        ledgeIdle = { dictionary = ParkourDictionaries.two, name = 'ledge_idle', },
        ledgeMoveLeft = { dictionary = ParkourDictionaries.two, name = 'ledge_move_l', },
        ledgeMoveRight = { dictionary = ParkourDictionaries.two, name = 'ledge_move_r', },
        ledgeJumpUp = { dictionary = ParkourDictionaries.two, name = 'ledge_jump_up_power', },
    },
}

local HeightLevels = {
    Min    = -0.6,
    Low    = -0.2,
    Medium = 0.4,
    High   = 2.0,
    Max    = 2.7,
}

local ForwardDistance = 1.5

--- ============================
---          Functions
--- ============================

function GetEntInFrontOfPlayer(Ped)
    local heightIndex = HeightLevels.Min
    local firstHit = nil
    local lastHit = nil
    local coords
    while heightIndex <= HeightLevels.Max + 0.01 do
        local CoA = GetEntityCoords(Ped, true)
        local CoB = GetOffsetFromEntityInWorldCoords(Ped, 0.0, ForwardDistance, heightIndex)
        local RayHandle = StartExpensiveSynchronousShapeTestLosProbe(CoA.x, CoA.y, CoB.z,
            CoB.x, CoB.y, CoB.z, -1, Ped, 0) -- -1 = Everything

        local _, hit, hitCoords, _, _, _ =
            GetShapeTestResultIncludingMaterial(RayHandle)

        if hit == 1 then
            if not firstHit then
                firstHit = heightIndex
                lastHit = heightIndex
            else
                lastHit = heightIndex
            end

            coords = hitCoords
        else
            if firstHit and lastHit then
                break
            end
        end

        heightIndex = heightIndex + 0.1

        Wait(0)
    end

    return firstHit, lastHit, coords

    -- color = { r = 0, g = 255, b = 0, a = 200 }
    -- while true do
    --     local heightIndex = HeightLevels.Low

    --     local CoA = GetEntityCoords(Ped, true)
    --     local CoB = GetOffsetFromEntityInWorldCoords(Ped, 0.0, ForwardDistance, heightIndex)
    --     local RayHandle = StartExpensiveSynchronousShapeTestLosProbe(CoA.x, CoA.y, CoB.z,
    --         CoB.x, CoB.y, CoB.z, -1, Ped, 0) -- -1 = Everything

    --     local _, hit, endCoords, surfaceNormal, materialHash, entityHit =
    --         GetShapeTestResultIncludingMaterial(RayHandle)

    --     DrawLine(CoA.x, CoA.y, CoB.z, CoB.x, CoB.y, CoB.z, color.r, color.g, color.b,
    --         color.a)
    --     DrawMarker(28, CoB.x, CoB.y, CoB.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r,
    --         color.g, color.b, color.a, false, true, 2, nil, nil, false, false)


    --     if IsControlJustReleased(0, 38) then
    --         print('hit: ' .. tostring(hit))
    --         return nil
    --     end

    --     Wait(0)
    -- end
end

local MaxForwardDistance = 3.5
function GetDistanceAfterEntity(Ped, hitCoords)
    local heightLine = 1.1
    local currentDistance = ForwardDistance
    local afterCoords

    while currentDistance <= MaxForwardDistance + 0.1 do
        local CoB = GetOffsetFromEntityInWorldCoords(Ped, 0.0, currentDistance, 0.0)
        local RayHandle = StartExpensiveSynchronousShapeTestLosProbe(CoB.x, CoB.y, CoB.z,
            CoB.x, CoB.y, CoB.z - heightLine, -1, Ped, 0) -- -1 = Everything

        _, hit, afterCoords, _, _, _ =
            GetShapeTestResultIncludingMaterial(RayHandle)

        if hit == 1 then
            print('z: ' .. tostring(hitCoords.z - afterCoords.z))
            if hitCoords.z - afterCoords.z > 0.5 then
                return currentDistance
            end
        else
            return nil
        end

        currentDistance = currentDistance + 0.50

        Wait(0)
    end

    return currentDistance
end

function GetCoordsAfterPlayer(Ped)
    local heightLine = 5
    local currentDistance = ForwardDistance + 1.5
    local CoB = GetOffsetFromEntityInWorldCoords(Ped, 0.0, currentDistance, HeightLevels.High)
    local RayHandle = StartExpensiveSynchronousShapeTestLosProbe(CoB.x, CoB.y, CoB.z,
        CoB.x, CoB.y, CoB.z - heightLine, -1, Ped, 0) -- -1 = Everything

    local _, _, forwardCoords, _, _, _ =
        GetShapeTestResultIncludingMaterial(RayHandle)

    return forwardCoords
end

function requestAnimation(dictionary)
    RequestAnimDict(dictionary)
    repeat
        Wait(1)
    until HasAnimDictLoaded(dictionary)

    return true
end

function loadParkourAnimations()
    for _, value in pairs(ParkourDictionaries) do
        if not HasAnimDictLoaded(value) then
            requestAnimation(value)
        end
    end
end

function unloadParkourAnimations()
    for _, value in pairs(ParkourDictionaries) do
        RemoveAnimDict(value)
    end
end

function disableCollision(playerPed)
    SetEntityHasGravity(playerPed, false)
    SetEntityCollision(playerPed, false, true)
end

function enableCollision(playerPed)
    SetEntityCollision(playerPed, true, true)
    SetEntityHasGravity(playerPed, true)
end

-- Retrieved from: https://stackoverflow.com/q/72402681
function turnHeading(playerPed, playerCoords, targetCoords)
    local dX = playerCoords.x - targetCoords.x;
    local dY = playerCoords.y - targetCoords.y;
    local yaw = math.atan2(dY, dX)
    yaw = (math.deg(yaw) + 180) % 360 - 90
    if yaw < 0 then
        yaw = yaw + 360
    end

    local frames = 50
    local currentHeading = GetEntityHeading(playerPed)
    local diff = yaw - currentHeading
    if currentHeading < yaw then
        if yaw - currentHeading < (360 + currentHeading) - yaw then
            diff = yaw - currentHeading
        else
            diff = (360 + currentHeading) - yaw
            diff = -diff
        end
    else
        if currentHeading - yaw < (360 + yaw) - currentHeading then
            diff = currentHeading - yaw
            diff = -diff
        else
            diff = (360 + yaw) - currentHeading
        end
    end
    diff = diff / frames

    for _ = 1, frames do
        currentHeading = currentHeading + diff
        SetEntityHeading(playerPed, currentHeading)
        Wait(0)
    end
end

function doAnimAtCoords(animation, playerPed, playerCoords, endCoords, startOffset, framePercent)
    SetEntityCollision(playerPed, false, true)
    FreezeEntityPosition(playerPed, true)

    local frames = 360
    TaskPlayAnim(playerPed, animation.dictionary, animation.name,
        8.0, 8.0, -1, AnimationFlags.ANIM_FLAG_NORMAL, startOffset, false, false, false)

    local originX, originY, originZ = table.unpack(playerCoords)
    local currentX, currentY, currentZ = table.unpack(playerCoords)
    local targetX, targetY, targetZ = table.unpack(endCoords)
    local diffX = targetX - originX
    local diffY = targetY - originY
    local diffZ = targetZ - originZ

    local speedX = diffX / frames
    local speedY = diffY / frames
    local speedZ = (diffZ / frames) + (1.0 / frames)
    currentZ = currentZ - 1.0

    local incrementX = speedX / framePercent
    local incrementY = speedY / framePercent
    local incrementZ = speedZ / framePercent

    for _ = 1, frames * framePercent do
        currentX = currentX + incrementX
        currentY = currentY + incrementY
        currentZ = currentZ + incrementZ

        SetEntityCoords(playerPed, currentX, currentY, currentZ, true, true, false, false)
        Wait(0)
    end

    FreezeEntityPosition(playerPed, false)
    SetEntityCollision(playerPed, true, true)
    ClearPedTasks(playerPed)
end

function doAnimation(playerPed, animation, startTime)
    startTime = startTime or 0.0

    TaskPlayAnim(playerPed, animation.dictionary, animation.name,
        8.0, 8.0, -1, AnimationFlags.ANIM_FLAG_NORMAL, startTime, false, false, false)

    return GetAnimDuration(animation.dictionary, animation.name)
end

function bigJump(playerPed, playerCoords, endCoords)
    doAnimAtCoords(ParkourAnimations.jump.bigJump, playerPed, playerCoords, endCoords, 0.20, 0.55)
end

function balanceJump(playerPed, playerCoords, endCoords)
    doAnimAtCoords(ParkourAnimations.jump.balanceJump, playerPed, playerCoords, endCoords, 0.25, 0.35)
end

function frontTwistFlip(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.jump.frontTwistFlip)
    Wait(animTime * 250)
    disableCollision(playerPed)
    Wait(animTime * 200)
    enableCollision(playerPed)
    Wait(animTime * 225)
    ClearPedTasks(playerPed)
end

function monkeyVault(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.vault.monkeyVault)
    Wait(animTime * 100)
    disableCollision(playerPed)
    Wait(animTime * 500)
    enableCollision(playerPed)
    Wait(animTime * 400)
end

function jumpOverThree(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.vault.jumpOverThree)
    Wait(animTime * 100)
    disableCollision(playerPed)
    Wait(animTime * 400)
    enableCollision(playerPed)
    Wait(animTime * 500)
end

function safetyVault(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.vault.safetyVault)
    Wait(animTime * 100)
    disableCollision(playerPed)
    Wait(animTime * 600)
    enableCollision(playerPed)
    Wait(animTime * 300)
end

function slideVault(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.vault.slideVault)
    Wait(animTime * 100)
    disableCollision(playerPed)
    Wait(animTime * 600)
    enableCollision(playerPed)
    Wait(animTime * 300)
end

function kashVault(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.vault.kashVault)
    Wait(animTime * 100)
    disableCollision(playerPed)
    Wait(animTime * 200)
    ApplyForceToEntityCenterOfMass(playerPed, 1, 0.0, -12.0, 0.0, true, true, true, true)
    Wait(animTime * 400)
    enableCollision(playerPed)
    Wait(animTime * 300)
end

function rollVault(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.vault.rollVault)
    ApplyForceToEntityCenterOfMass(playerPed, 1, 0.0, 0.0, 8.0, true, true, true, true)
    Wait(animTime * 100)
    disableCollision(playerPed)
    Wait(animTime * 350)
    enableCollision(playerPed)
    Wait(animTime * 550)
end

function reverseVault(playerPed, heightLevel)
    TaskClimb(playerPed, false)

    local heightBreak
    if heightLevel < 0.7 then
        heightBreak = heightLevel / 1.2
    elseif heightLevel < 1.1 then
        heightBreak = heightLevel / 2.4
    else
        heightBreak = heightLevel + 0.2
    end

    local originalCoords = GetEntityCoords(playerPed)
    local playerCoords = originalCoords
    local counter = 0
    repeat
        playerCoords = GetEntityCoords(playerPed)

        if playerCoords.z - originalCoords.z > heightBreak then
            break
        end

        counter = counter + 1
        Wait(0)
    until counter > 200
    ClearPedTasksImmediately(playerPed)

    if IsPedVaulting(playerPed) then
        local animTime = doAnimation(playerPed, ParkourAnimations.vault.reverseVault)
        Wait(animTime * 200)
        disableCollision(playerPed)
        Wait(animTime * 400)
        enableCollision(playerPed)
        Wait(animTime * 400)
    end
end

function slide(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.slide.slideNormal)
    Wait(animTime * 50)
    disableCollision(playerPed)
    Wait(animTime * 350)
    enableCollision(playerPed)
    Wait(animTime * 600)
end

function wallFlip(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.wall.wallFlip)
    Wait(animTime * 1000)
end

function ledgeJumpUp(playerPed, heightLevel)
    local x, y, z = table.unpack(GetEntityCoords(playerPed))

    local animTime = doAnimation(playerPed, ParkourAnimations.ledge.ledgeJumpUp)
    Wait(animTime * 1000)

    local offset = 1.5 - ((HeightLevels.Max - heightLevel) * 0.8)
    SetEntityCoords(playerPed, x, y, z + offset, true, false, false, false)

    SetEntityHasGravity(playerPed, false)

    while true do
        FreezeEntityPosition(playerPed, true)
        doAnimation(playerPed, ParkourAnimations.ledge.ledgeIdle)

        if IsControlPressed(0, 32) then
            FreezeEntityPosition(playerPed, false)
            TaskClimb(playerPed, false)
            break;
        end

        if IsControlPressed(0, 33) then
            FreezeEntityPosition(playerPed, false)
            ClearPedTasksImmediately(playerPed)
            break;
        end

        if IsControlPressed(0, 34) then
            FreezeEntityPosition(playerPed, false)
            Wait(doAnimation(playerPed, ParkourAnimations.ledge.ledgeMoveLeft) * 1000)
            doAnimation(playerPed, ParkourAnimations.ledge.ledgeIdle)
        end

        if IsControlPressed(0, 35) then
            FreezeEntityPosition(playerPed, false)
            Wait(doAnimation(playerPed, ParkourAnimations.ledge.ledgeMoveRight) * 1000)
            doAnimation(playerPed, ParkourAnimations.ledge.ledgeIdle)
        end

        Wait(0)
    end

    SetEntityHasGravity(playerPed, true)
end

--- ============================
---          Commands
--- ============================

local isDoingParkour = false

RegisterKeyMapping('+parkour', 'Parkour', 'keyboard', Config.Settings.parkourKeyBind)
RegisterCommand('+parkour', function()
    if isDoingParkour then
        return
    else
        isDoingParkour = true
    end

    local playerPed = PlayerPedId()

    -- Load all parkour animations
    loadParkourAnimations()

    -- Get if there's object in front of the ped
    local firstHit, lastHit, hitCoords = GetEntInFrontOfPlayer(playerPed)

    print('firstHit: ' .. tostring(firstHit))
    print('lastHit: ' .. tostring(lastHit))

    if firstHit ~= nil then
        if firstHit > HeightLevels.Low and firstHit <= HeightLevels.Medium + 0.1 then
            slide(playerPed)
        elseif lastHit ~= null then
            if lastHit <= HeightLevels.Medium then
                local playerCoords = GetEntityCoords(playerPed)
                print('hitZ diff: ' .. tostring(hitCoords.z - playerCoords.z))
                if hitCoords.z - playerCoords.z < 0.1 then
                    local distance = GetDistanceAfterEntity(playerPed, hitCoords)
                    if distance == nil then
                        monkeyVault(playerPed)
                    else
                        print('distance: ' .. tostring(distance))
                        if distance <= 1.5 then
                            jumpOverThree(playerPed)
                        elseif distance <= 2.0 then
                            safetyVault(playerPed)
                        elseif distance <= 3.5 then
                            kashVault(playerPed)
                        else
                            slideVault(playerPed)
                        end
                    end
                else
                    rollVault(playerPed)
                end
            elseif lastHit <= HeightLevels.High then
                reverseVault(playerPed, lastHit)
            elseif lastHit < HeightLevels.Max then
                ledgeJumpUp(playerPed, lastHit)
            elseif firstHit < HeightLevels.Low and lastHit >= HeightLevels.Max then
                wallFlip(playerPed)
            end
        end
    else
        frontTwistFlip(playerPed)

        -- local playerCoords = GetEntityCoords(playerPed)
        -- local coords = exports.qbUtil:raycast()
        -- if type(coords) ~= 'vector3' then
        --     coords = GetEntityCoords(coords)
        -- end
        -- turnHeading(playerPed, playerCoords, coords)

        -- balanceJump(playerPed, playerCoords, coords)
    end

    -- Unload all parkour animations
    unloadParkourAnimations()

    isDoingParkour = false
end, false)

RegisterCommand('tpParkour', function(_, _, _)
    SetEntityCoords(PlayerPedId(), -1130.0, -1020.0, 2.5, true, false, false, false)
end, false)

RegisterCommand('tpParkour2', function(_, _, _)
    SetEntityCoords(PlayerPedId(), 240.0, -917.0, 26.5, true, false, false, false)
end, false)

RegisterCommand('tpParkour3', function(_, _, _)
    SetEntityCoords(PlayerPedId(), 13.0, 3657.0, 40.5, true, false, false, false)
end, false)

RegisterCommand('tpParkour4', function(_, _, _)
    SetEntityCoords(PlayerPedId(), 193.0, -1620.0, 30.0, true, false, false, false)
end, false)

RegisterCommand('tpParkour5', function(_, _, _)
    SetEntityCoords(PlayerPedId(), -48.0, -39.0, 65.0, true, false, false, false)
end, false)

RegisterCommand('tpParkour6', function(_, _, _)
    SetEntityCoords(PlayerPedId(), 1008.0, -1052.0, 35.0, true, false, false, false)
end, false)

RegisterCommand('tpParkour7', function(_, _, _)
    SetEntityCoords(PlayerPedId(), -893.0, -138.0, 38.0, true, false, false, false)
end, false)
