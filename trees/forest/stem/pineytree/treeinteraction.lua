function init(virtual)
  math.randomseed()
  self.sticks = math.random(0,5)
  if self.sticks > 0 then
    entity.setInteractive(true)
  end

  world.logInfo("Tree set. %s", self.sticks)
end

function onInteraction(args)
  if self.sticks > 0 then
    world.logInfo("Tree changed. %s", self.sticks)
    self.sticks -= 1
    entity.burstParticleEmitter("breakTree")
  else
    entity.setInteractive(false)
  end
end
