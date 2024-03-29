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
    land = {
        roll = { dictionary = 'move_fall', name = 'land_roll' }
    }
}

local HeightLevels = {
    Min    = -0.6,
    Low    = -0.2,
    Medium = 0.4,
    High   = 2.0,
    Max    = 2.7,
}

local ForwardDistance = 2.0

local TraceFlag = 1 | 2 | 4 | 16 -- World | Vehicles | PedSimpleCollision | Objects

local Color = { r = 0, g = 255, b = 0, a = 200 }

--- ============================
---           Helpers
--- ============================

function GetEntInFrontOfPlayer(Ped)
    local heightIndex = HeightLevels.Min
    local firstHit = nil
    local lastHit = nil
    local coords, ignoredMaterial
    while heightIndex <= HeightLevels.Max + 0.01 do
        local CoA = GetEntityCoords(Ped, true)
        local CoB = GetOffsetFromEntityInWorldCoords(Ped, 0.0, ForwardDistance, heightIndex)
        local RayHandle = StartShapeTestRay(CoA.x, CoA.y, CoB.z, CoB.x, CoB.y, CoB.z, TraceFlag, Ped, 0)

        local _, hit, hitCoords, _, _ = GetShapeTestResult(RayHandle)

        -- while true do
        --     DrawLine(CoA.x, CoA.y, CoB.z, CoB.x, CoB.y, CoB.z, Color.r, Color.g, Color.b, Color.a)
        --     if IsControlJustReleased(0, 38) then
        --         break
        --     end
        --     Wait(0)
        -- end

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

        if heightIndex >= HeightLevels.High - 0.01 then
            heightIndex = heightIndex + 0.1
        else
            heightIndex = heightIndex + 0.2
        end

        Wait(0)
    end

    return firstHit, lastHit, coords, ignoredMaterial
end

local MaxForwardDistance = 3.0
function GetDistanceAfterCoord(baseCoords)
    local lineHeight = 1.2
    local currentDistance = 0.0
    local forwardMultiplier = 0.75
    while currentDistance <= MaxForwardDistance + 0.1 do
        currentDistance = currentDistance + forwardMultiplier
        baseCoords = baseCoords + GetEntityForwardVector(PlayerPedId()) * forwardMultiplier
        local RayHandle = StartShapeTestRay(baseCoords.x, baseCoords.y, baseCoords.z + lineHeight / 2,
            baseCoords.x, baseCoords.y, baseCoords.z - lineHeight, TraceFlag, 0, 0)

        local _, hit, hitCoords, _, _ = GetShapeTestResult(RayHandle)

        -- while true do
        --     DrawLine(baseCoords.x, baseCoords.y, baseCoords.z + lineHeight / 2,
        --         baseCoords.x, baseCoords.y, baseCoords.z - lineHeight,
        --         Color.r, Color.g, Color.b, Color.a)
        --     if IsControlJustReleased(0, 38) then
        --         break
        --     end
        --     Wait(0)
        -- end

        if hit == 1 then
            print('forward zDiff: ' .. tostring(baseCoords.z - hitCoords.z))
            if baseCoords.z - hitCoords.z > 0.45 then
                return currentDistance
            end
        else
            return nil
        end

        Wait(0)
    end

    return currentDistance
end

function CheckIfFloor(baseCoords)
    baseCoords = baseCoords + GetEntityForwardVector(PlayerPedId()) * 2.25
    local lineHeight = 1.5
    local RayHandle = StartShapeTestRay(baseCoords.x, baseCoords.y, baseCoords.z + lineHeight,
        baseCoords.x, baseCoords.y, baseCoords.z - lineHeight / 2, TraceFlag, Ped, 0)

    local _, hit, _, _, _, _ = GetShapeTestResult(RayHandle)

    -- while true do
    --     DrawLine(baseCoords.x, baseCoords.y, baseCoords.z + lineHeight,
    --         baseCoords.x, baseCoords.y, baseCoords.z - lineHeight / 2,
    --         Color.r, Color.g, Color.b, Color.a)
    --     if IsControlJustReleased(0, 38) then
    --         break
    --     end
    --     Wait(0)
    -- end

    if hit == 1 then
        return true
    else
        return false
    end
end

function CheckIfFence(baseCoords)
    local fenceDistance = 0.6
    baseCoords = baseCoords + GetEntityForwardVector(PlayerPedId()) * fenceDistance
    local lineHeight = 0.6
    local RayHandle = StartShapeTestRay(baseCoords.x, baseCoords.y, baseCoords.z + lineHeight,
        baseCoords.x, baseCoords.y, baseCoords.z - lineHeight, TraceFlag, 0, 0)
    local _, hit, _, _, _ = GetShapeTestResult(RayHandle)

    -- while true do
    --     DrawLine(baseCoords.x, baseCoords.y, baseCoords.z + lineHeight,
    --         baseCoords.x, baseCoords.y, baseCoords.z - lineHeight,
    --         Color.r, Color.g, Color.b, Color.a)
    --     if IsControlJustReleased(0, 38) then
    --         break
    --     end
    --     Wait(0)
    -- end

    if hit == 1 then
        return false
    else
        return true
    end
end

--- ============================
---          Animations
--- ============================

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

function disableMovementControls()
    DisableControlAction(0, 29, true)
    DisableControlAction(0, 30, true)
    DisableControlAction(0, 31, true)
    DisableControlAction(0, 32, true)
end

function doAnimation(playerPed, animation, enableTime)
    enableTime = enableTime or 0
    flag = AnimationFlags.ANIM_FLAG_NORMAL

    local animTime = GetAnimDuration(animation.dictionary, animation.name)

    if enableTime > 0 then
        flag = AnimationFlags.ANIM_FLAG_ENABLE_PLAYER_CONTROL

        local disabled = true
        CreateThread(function()
            Wait(animTime * enableTime * 0.9)
            disabled = false
        end)
        CreateThread(function()
            while disabled do
                Wait(0)
                disableMovementControls()
            end
        end)
    end

    TaskPlayAnim(playerPed, animation.dictionary, animation.name,
        8.0, 8.0, -1, flag, 0.0, false, false, false)

    return animTime
end

--- ============================
---          Functions
--- ============================

function frontTwistFlip(playerPed)
    local disableCollisionTime = 250
    local enableCollisionTime = 200
    local animTime = doAnimation(playerPed, ParkourAnimations.jump.frontTwistFlip,
        disableCollisionTime + enableCollisionTime)

    Wait(animTime * disableCollisionTime)
    disableCollision(playerPed)
    Wait(animTime * enableCollisionTime)
    enableCollision(playerPed)
    Wait(animTime * 250)
    ClearPedTasks(playerPed)
end

function monkeyVault(playerPed)
    local disableCollisionTime = 100
    local enableCollisionTime = 500
    local animTime = doAnimation(playerPed, ParkourAnimations.vault.monkeyVault,
        disableCollisionTime + enableCollisionTime)

    Wait(animTime * disableCollisionTime)
    disableCollision(playerPed)
    Wait(animTime * enableCollisionTime)
    enableCollision(playerPed)
    Wait(animTime * 400)
end

function jumpOverThree(playerPed)
    local disableCollisionTime = 100
    local enableCollisionTime = 400
    local animTime = doAnimation(playerPed, ParkourAnimations.vault.jumpOverThree,
        disableCollisionTime + enableCollisionTime)

    Wait(animTime * disableCollisionTime)
    disableCollision(playerPed)
    Wait(animTime * enableCollisionTime)
    enableCollision(playerPed)
    Wait(animTime * 500)
end

function safetyVault(playerPed)
    local disableCollisionTime = 100
    local enableCollisionTime = 600
    local animTime = doAnimation(playerPed, ParkourAnimations.vault.safetyVault,
        disableCollisionTime + enableCollisionTime)

    Wait(animTime * disableCollisionTime)
    disableCollision(playerPed)
    Wait(animTime * enableCollisionTime)
    enableCollision(playerPed)
    Wait(animTime * 300)
end

function slideVault(playerPed)
    local disableCollisionTime = 100
    local enableCollisionTime = 600
    local animTime = doAnimation(playerPed, ParkourAnimations.vault.slideVault,
        disableCollisionTime + enableCollisionTime)

    Wait(animTime * disableCollisionTime)
    disableCollision(playerPed)
    Wait(animTime * enableCollisionTime)
    enableCollision(playerPed)
    Wait(animTime * 300)
end

function kashVault(playerPed)
    local disableCollisionTime = 100
    local enableCollisionTime1 = 200
    local enableCollisionTime2 = 500
    local animTime = doAnimation(playerPed, ParkourAnimations.vault.kashVault,
        disableCollisionTime + enableCollisionTime1 + enableCollisionTime2)

    Wait(animTime * disableCollisionTime)
    disableCollision(playerPed)
    ApplyForceToEntityCenterOfMass(playerPed, 1, 0.0, -3.0, 0.5, true, true, true, true)
    Wait(animTime * enableCollisionTime1)
    ApplyForceToEntityCenterOfMass(playerPed, 1, 0.0, -9.0, -0.5, true, true, true, true)
    Wait(animTime * enableCollisionTime2)
    enableCollision(playerPed)
    Wait(animTime * 200)
end

function jumpOverTwo(playerPed)
    local disableCollisionTime = 150
    local enableCollisionTime = 200
    local animTime = doAnimation(playerPed, ParkourAnimations.vault.jumpOverTwo,
        disableCollisionTime + enableCollisionTime + 300)

    Wait(animTime * disableCollisionTime)
    ApplyForceToEntityCenterOfMass(playerPed, 1, 0.0, 0.0, 2.5, true, true, true, true)
    disableCollision(playerPed)
    Wait(animTime * enableCollisionTime)
    enableCollision(playerPed)
    Wait(animTime * 325)
end

function rollVault(playerPed)
    local disableCollisionTime = 100
    local enableCollisionTime = 400
    local animTime = doAnimation(playerPed, ParkourAnimations.vault.rollVault,
        disableCollisionTime + enableCollisionTime)

    ApplyForceToEntityCenterOfMass(playerPed, 1, 0.0, 0.0, 9.0, true, true, true, true)
    Wait(animTime * disableCollisionTime)
    disableCollision(playerPed)
    Wait(animTime * enableCollisionTime)
    enableCollision(playerPed)
    Wait(animTime * 500)
end

function rollIfFallingFromHeight(playerPed)
    if GetEntityHeightAboveGround(playerPed) > 1.1 then
        while GetEntityHeightAboveGround(playerPed) > 1.5 do
            Wait(0)
        end

        local animTime = doAnimation(playerPed, ParkourAnimations.land.roll, 1.0)
        Wait(animTime * 350)

        -- ClearPedTasks(playerPed)
        -- ForcePedMotionState(playerPed, -530524, false, 0, false)
        -- ForcePedMotionState(playerPed, -668482597, false, 0, false)

        StopAnimTask(playerPed, ParkourAnimations.land.roll.dictionary, ParkourAnimations.land.roll.name, 3.5)
    end
end

function reverseVault(playerPed, heightLevel, isFloorHigher)
    TaskClimb(playerPed, false)
    local originalCoords = GetEntityCoords(playerPed)
    local playerCoords = originalCoords
    local counter = 0

    repeat
        playerCoords = GetEntityCoords(playerPed)
        if playerCoords.z - originalCoords.z > heightLevel + 0.3 then
            break
        end
        counter = counter + 1
        Wait(0)
    until counter > 200
    ClearPedTasksImmediately(playerPed)

    if IsPedVaulting(playerPed) then
        local disableCollisionTime = 25
        local enableCollisionTime = 500
        if isFloorHigher then
            disableCollisionTime = 0
            enableCollisionTime = 250
        end

        local animTime = doAnimation(playerPed, ParkourAnimations.vault.reverseVault,
            disableCollisionTime + enableCollisionTime)

        SetEntityVelocity(playerPed, 0.0, 0.0, 0.0)
        Wait(animTime * disableCollisionTime)
        disableCollision(playerPed)
        Wait(animTime * enableCollisionTime)
        enableCollision(playerPed)
        Wait(animTime * (1000 - (disableCollisionTime + enableCollisionTime)))
    end
end

function slide(playerPed)
    local disableCollisionTime = 50
    local enableCollisionTime = 350
    local animTime = doAnimation(playerPed, ParkourAnimations.slide.slideNormal,
        disableCollisionTime + enableCollisionTime)

    Wait(animTime * disableCollisionTime)
    disableCollision(playerPed)
    Wait(animTime * enableCollisionTime)
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
    local playerPed = PlayerPedId()

    -- if not IsPedSprinting(playerPed) then
    --     return
    -- end

    if isDoingParkour then
        return
    else
        isDoingParkour = true
    end

    -- Get if there's object in front of the ped
    local firstHit, lastHit, hitCoords, _ = GetEntInFrontOfPlayer(playerPed)

    print('firstHit: ' .. tostring(firstHit))
    print('lastHit: ' .. tostring(lastHit))

    -- Load all parkour animations
    loadParkourAnimations()

    if firstHit ~= nil then
        if firstHit > HeightLevels.Low and firstHit <= HeightLevels.Medium + 0.2 then
            slide(playerPed)
        elseif lastHit ~= null then
            if lastHit <= HeightLevels.Medium then
                local playerCoords = GetEntityCoords(playerPed)
                local obstacleHeightDiff = hitCoords.z - playerCoords.z
                print('obstacleHeightDiff: ' .. tostring(obstacleHeightDiff))
                if obstacleHeightDiff < 0.1 then
                    local distance = GetDistanceAfterCoord(hitCoords)
                    if distance == nil then
                        monkeyVault(playerPed)
                    else
                        print('vault distance: ' .. tostring(distance))
                        if distance <= 0.75 then
                            jumpOverThree(playerPed)
                        elseif distance <= 1.50 then
                            safetyVault(playerPed)
                        elseif distance <= 3.00 then
                            kashVault(playerPed)
                        else
                            slideVault(playerPed)
                        end
                    end
                else
                    local isFence = CheckIfFence(hitCoords)
                    print('isFence: ' .. tostring(isFence))
                    if isFence then
                        jumpOverTwo(playerPed)
                    else
                        rollVault(playerPed)
                    end
                end

                rollIfFallingFromHeight(playerPed)
            elseif lastHit <= HeightLevels.High then
                local isFloor = CheckIfFloor(hitCoords, lastHit)
                print('isFloor: ' .. tostring(isFloor))
                reverseVault(playerPed, lastHit, isFloor)
            elseif lastHit < HeightLevels.Max then
                ledgeJumpUp(playerPed, lastHit)
            elseif firstHit < HeightLevels.Low and lastHit >= HeightLevels.Max then
                wallFlip(playerPed)
            end
        end
    else
        frontTwistFlip(playerPed)
        rollIfFallingFromHeight(playerPed)

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

RegisterCommand('tpParkour8', function(_, _, _)
    SetEntityCoords(PlayerPedId(), 1060.0, -270.0, 50.0, true, false, false, false)
end, false)

RegisterCommand('tpParkour9', function(_, _, _)
    SetEntityCoords(PlayerPedId(), 1144.0, -276.0, 69.0, true, false, false, false)
end, false)

RegisterCommand('tpParkour10', function(_, _, _)
    SetEntityCoords(PlayerPedId(), 1144.0, -276.0, 69.0, true, false, false, false)
end, false)

RegisterCommand('tpParkour11', function(_, _, _)
    SetEntityCoords(PlayerPedId(), 668.0, -2065.0, 9.0, true, false, false, false)
end, false)
