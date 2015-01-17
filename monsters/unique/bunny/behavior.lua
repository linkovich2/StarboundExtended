function init(args)
  self.sensors = sensors.create()

  self.state = stateMachine.create({
    "moveState",
    "fleeState"
  })
  self.state.leavingState = function(stateName)
    entity.setAnimationState("movement", "idle")
  end

  entity.setAggressive(false)
  entity.setAnimationState("movement", "idle")
end

function update(dt)
  self.state.update(dt)
  self.sensors.clear()
end

function damage(args)
  if entity.health() > 0 then
    self.state.pickState({ targetId = args.sourceId })
  end
end

function move(direction, run)
  mcontroller.controlMove(direction, run)
end

--------------------------------------------------------------------------------
moveState = {}

function moveState.enter()
  local direction

  -- todo: we don't want it changing direction so much.
  -- let's remember the direction for the entity state and have a greater chance to continue
  -- in that direction
  if math.random(100) > 50 then
    direction = 1
  else
    direction = -1
  end

  return {
    timer = entity.randomizeParameterRange("moveTimeRange"),
    direction = direction
  }
end

function moveState.update(dt, stateData)
  if self.sensors.blockedSensors.collision.any(true) then
    stateData.direction = -stateData.direction
  end

  entity.setAnimationState("movement", "move")
  move(stateData.direction, false)

  stateData.timer = stateData.timer - dt

  -- need a pretty exact movement timer to get the "hopping" effect
  --if stateData.timer > 0.25 then stateData.timer = 0.25 end

  if stateData.timer <= 0 then
    return true, math.random(10)
  end

  return false
end

--------------------------------------------------------------------------------
fleeState = {}

function fleeState.enterWith(args)
  if args.targetId == nil then return nil end
  if self.state.stateDesc() == "fleeState" then return nil end

  return {
    targetId = args.targetId,
    timer = entity.configParameter("fleeMaxTime"),
    distance = entity.randomizeParameterRange("fleeDistanceRange")
  }
end

function fleeState.update(dt, stateData)
  entity.setAnimationState("movement", "run")

  local targetPosition = world.entityPosition(stateData.targetId)
  if targetPosition ~= nil then
    local toTarget = world.distance(targetPosition, mcontroller.position())
    if world.magnitude(toTarget) > stateData.distance then
      return true
    else
      stateData.direction = -toTarget[1]
    end
  end

  if stateData.direction ~= nil then
    move(stateData.direction, true)
  else
    return true
  end

  stateData.timer = stateData.timer - dt
  return stateData.timer <= 0
end