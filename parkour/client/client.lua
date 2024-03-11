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
        diveRollLeft = { dictionary = ParkourDictionaries.two, name = 'diveroll_l', },
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
    color = { r = 0, g = 255, b = 0, a = 200 }

    local heightIndex = HeightLevels.Min
    local firstHit = nil
    local lastHit = nil
    while heightIndex <= HeightLevels.Max + 0.01 do
        local CoA = GetEntityCoords(Ped, true)
        local CoB = GetOffsetFromEntityInWorldCoords(Ped, 0.0, ForwardDistance, heightIndex)
        local RayHandle = StartExpensiveSynchronousShapeTestLosProbe(CoA.x, CoA.y, CoB.z,
            CoB.x, CoB.y, CoB.z, -1, Ped, 0) -- -1 = Everything

        _, hit, _, _, _, _ =
            GetShapeTestResultIncludingMaterial(RayHandle)

        if hit == 1 then
            if not firstHit then
                firstHit = heightIndex
                lastHit = heightIndex
            else
                lastHit = heightIndex
            end
        else
            if firstHit and lastHit then
                break
            end
        end

        heightIndex = heightIndex + 0.1

        Wait(1)
    end

    return firstHit, lastHit

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

    --     Wait(1)
    -- end
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

function doAnimation(playerPed, animation, startTime)
    startTime = startTime or 0.0

    TaskPlayAnim(playerPed, animation.dictionary, animation.name,
        8.0, 8.0, -1, AnimationFlags.ANIM_FLAG_NORMAL, startTime, false, false, false)

    return GetAnimDuration(animation.dictionary, animation.name)
end

function bigJump(playerPed, playerCoords, endCoords)
    FreezeEntityPosition(playerPed, true)
    doAnimation(playerPed, ParkourAnimations.jump.bigJump, 0.13)

    local frames = 360

    local startFrameSegment = 0.1
    local jumpFrameSegment = 0.5
    local endFrameSegment = 0.4

    local startFrames = frames * startFrameSegment
    local jumpFrames = frames * jumpFrameSegment
    local endFrames = frames * endFrameSegment

    local originX, originY, originZ = table.unpack(playerCoords)
    local currentX, currentY, currentZ = table.unpack(playerCoords)
    local targetX, targetY, targetZ = table.unpack(endCoords)
    local diffX = targetX - originX
    local diffY = targetY - originY
    local diffZ = targetZ - originZ

    local speedX = diffX / frames
    local speedY = diffY / frames
    -- local speedZ = diffZ / frames
    local speedZ = (diffZ / frames) + (1.0 / frames)
    currentZ = currentZ - 1.0

    local totalX = 0.0
    local totalY = 0.0
    local totalZ = 0.0
    print(string.format('target distance: %.2f, %.2f, %.2f', diffX, diffY, diffZ))

    -- Start
    local incrementX = speedX
    local incrementY = speedY
    local incrementZ = speedZ
    for _ = 1, startFrames do
        currentX = currentX + incrementX
        currentY = currentY + incrementY
        currentZ = currentZ + incrementZ

        totalX = totalX + incrementX
        totalY = totalY + incrementY
        totalZ = totalZ + incrementZ

        SetEntityCoords(playerPed, currentX, currentY, currentZ, true, true, false, false)
        Wait(0)
    end

    -- Jumping
    local jumpSpeed = 1.7
    incrementX = speedX * jumpSpeed
    incrementY = speedY * jumpSpeed
    incrementZ = speedZ * jumpSpeed
    for _ = 1, jumpFrames do
        currentX = currentX + incrementX
        currentY = currentY + incrementY
        currentZ = currentZ + incrementZ

        totalX = totalX + incrementX
        totalY = totalY + incrementY
        totalZ = totalZ + incrementZ

        SetEntityCoords(playerPed, currentX, currentY, currentZ, true, true, false, false)
        Wait(0)
    end

    -- End
    local endSpeedMultiplier = endFrameSegment /
        ((jumpFrameSegment + endFrameSegment) - (jumpFrameSegment * jumpSpeed))
    print(endSpeedMultiplier)

    local endSpeedX = speedX / endSpeedMultiplier
    local endSpeedY = speedY / endSpeedMultiplier
    local endSpeedZ = speedZ / endSpeedMultiplier

    local endFramePercent = 0.1

    incrementX = endFrames * endSpeedX / (endFrames * endFramePercent)
    incrementY = endFrames * endSpeedY / (endFrames * endFramePercent)
    incrementZ = endFrames * endSpeedZ / (endFrames * endFramePercent)

    for _ = 1, endFrames * endFramePercent do
        currentX = currentX + incrementX
        currentY = currentY + incrementY
        currentZ = currentZ + incrementZ

        totalX = totalX + incrementX
        totalY = totalY + incrementY
        totalZ = totalZ + incrementZ

        SetEntityCoords(playerPed, currentX, currentY, currentZ, true, true, false, false)
        Wait(0)
    end

    print(string.format('actual distance: %.2f, %.2f, %.2f', totalX, totalY, totalZ))

    FreezeEntityPosition(playerPed, false)
    ClearPedTasks(playerPed)
end

-- function bigJump(playerPed)
--     local animTime = doAnimation(playerPed, ParkourAnimations.jump.bigJump, 0.2)
--     Wait(animTime * 50)
--     disableCollision(playerPed)
--     Wait(animTime * 200)
--     enableCollision(playerPed)
--     Wait(animTime * 450)
--     ClearPedTasks(playerPed)
-- end

function frontTwistFlip(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.jump.frontTwistFlip)
    Wait(animTime * 250)
    disableCollision(playerPed)
    Wait(animTime * 200)
    enableCollision(playerPed)
    Wait(animTime * 225)
    ClearPedTasks(playerPed)

    if GetEntityHeightAboveGround(playerPed) > 1.5 then
        while GetEntityHeightAboveGround(playerPed) > 1.5 do
            Wait(0)
        end

        TaskPlayAnim(playerPed, 'move_fall', 'land_roll',
            8.0, 8.0, -1, AnimationFlags.ANIM_FLAG_ENABLE_PLAYER_CONTROL, 0.0, false, false, false)
        animTime = GetAnimDuration('move_fall', 'land_roll')
        Wait(animTime * 350)
        ClearPedTasks(playerPed)
    end
end

function balanceJump(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.jump.balanceJump)
    Wait(animTime * 250)
    disableCollision(playerPed)
    Wait(animTime * 200)
    enableCollision(playerPed)
    Wait(animTime * 400)
    ClearPedTasks(playerPed)
end

function jumpOverOne(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.vault.jumpOverOne)
    Wait(animTime * 100)
    disableCollision(playerPed)
    Wait(animTime * 250)
    enableCollision(playerPed)
    Wait(animTime * 650)
end

function jumpOverTwo(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.vault.jumpOverTwo)
    Wait(animTime * 100)
    disableCollision(playerPed)
    Wait(animTime * 250)
    enableCollision(playerPed)
    Wait(animTime * 650)
end

function jumpOverThree(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.vault.jumpOverThree)
    Wait(animTime * 150)
    disableCollision(playerPed)
    Wait(animTime * 300)
    enableCollision(playerPed)
    Wait(animTime * 550)
end

function kashVault(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.vault.kashVault)
    Wait(animTime * 100)
    disableCollision(playerPed)
    Wait(animTime * 350)
    enableCollision(playerPed)
    Wait(animTime * 550)
end

function monkeyVault(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.vault.monkeyVault)
    Wait(animTime * 100)
    disableCollision(playerPed)
    Wait(animTime * 350)
    enableCollision(playerPed)
    Wait(animTime * 550)
end

function rollVault(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.vault.rollVault)
    Wait(animTime * 100)
    disableCollision(playerPed)
    Wait(animTime * 350)
    enableCollision(playerPed)
    Wait(animTime * 550)
end

function safetyVault(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.vault.safetyVault)
    Wait(animTime * 100)
    disableCollision(playerPed)
    Wait(animTime * 350)
    enableCollision(playerPed)
    Wait(animTime * 550)
end

function diveRollLeft(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.vault.diveRollLeft)
    Wait(animTime * 1000)
end

function reverseVault(playerPed, heightLevel)
    TaskClimb(playerPed, false)
    local difference = HeightLevels.High - heightLevel
    print('difference: ' .. tostring(difference))
    if difference <= 0.5 then
        print('here 1')
        Wait(800)
    elseif difference <= 0.6 then
        print('here 2')
        Wait(850)
    elseif difference <= 0.7 then
        print('here 3')
        Wait(900)
    elseif difference <= 0.8 then
        print('here 4')
        Wait(1200)
    elseif difference <= 0.9 then
        print('here 5')
        Wait(1100)
    elseif difference <= 1.0 then
        print('here 6')
        Wait(500)
    elseif difference <= 1.1 then
        print('here 7')
        Wait(550)
    elseif difference <= 1.2 then
        print('here 8')
        Wait(550)
    elseif difference <= 1.3 then
        print('here 9')
        Wait(550)
    elseif difference <= 1.4 then
        print('here 10')
        Wait(550)
    elseif difference <= 1.5 then
        print('here 11')
        Wait(550)
    else
        print('here 12')
        Wait(550)
    end

    ClearPedTasksImmediately(playerPed)

    local animTime = doAnimation(playerPed, ParkourAnimations.vault.reverseVault)
    Wait(animTime * 100)
    disableCollision(playerPed)
    Wait(animTime * 400)
    enableCollision(playerPed)
    Wait(animTime * 500)
end

function slide(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.slide.slideNormal)
    Wait(animTime * 50)
    disableCollision(playerPed)
    Wait(animTime * 350)
    enableCollision(playerPed)
    Wait(animTime * 600)
end

function slideBack(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.slide.slideBack)
    Wait(animTime * 50)
    disableCollision(playerPed)
    Wait(animTime * 300)
    enableCollision(playerPed)
    Wait(animTime * 650)
end

function slideUp(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.slide.slideUp)
    Wait(animTime * 50)
    disableCollision(playerPed)
    Wait(animTime * 300)
    enableCollision(playerPed)
    Wait(animTime * 650)
end

function wallFlip(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.wall.wallFlip)
    Wait(animTime * 1000)
end

function wallRunLeft(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.wall.wallRunLeft)
    Wait(animTime * 50)
    disableCollision(playerPed)
    Wait(animTime * 500)
    enableCollision(playerPed)
    Wait(animTime * 450)
end

function wallRunRight(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.wall.wallRunRight)
    Wait(animTime * 50)
    disableCollision(playerPed)
    Wait(animTime * 500)
    enableCollision(playerPed)
    Wait(animTime * 450)
end

function tictakLeft(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.wall.tictakLeft)
    Wait(animTime * 50)
    disableCollision(playerPed)
    Wait(animTime * 500)
    enableCollision(playerPed)
    Wait(animTime * 450)
end

function tictakRight(playerPed)
    local animTime = doAnimation(playerPed, ParkourAnimations.wall.tictakRight)
    Wait(animTime * 50)
    disableCollision(playerPed)
    Wait(animTime * 500)
    enableCollision(playerPed)
    Wait(animTime * 450)
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
    local firstHit, lastHit = GetEntInFrontOfPlayer(playerPed)

    print('firstHit: ' .. tostring(firstHit))
    print('lastHit: ' .. tostring(lastHit))

    if firstHit ~= nil then
        if firstHit > HeightLevels.Low and firstHit <= HeightLevels.Medium + 0.1 then
            slide(playerPed)
        elseif lastHit ~= null then
            if lastHit <= HeightLevels.Medium then
                kashVault(playerPed)
            elseif lastHit <= HeightLevels.High then
                reverseVault(playerPed, lastHit)
            elseif lastHit < HeightLevels.Max then
                ledgeJumpUp(playerPed, lastHit)
            elseif firstHit < HeightLevels.Low and lastHit >= HeightLevels.Max then
                wallFlip(playerPed)
            end
        end
    else
        local playerCoords = GetEntityCoords(playerPed)
        local coords = exports.qbUtil:raycast()
        turnHeading(playerPed, playerCoords, coords)

        -- frontTwistFlip(playerPed)
        bigJump(playerPed, playerCoords, coords)
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
