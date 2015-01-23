function init()
  entity.setInteractive(true)
end

function onInteraction(args)
  world.spawnItem("stick", entity.position())
  entity.setInteractive(false)
end
