Player = {}
Player.__index = Player

function Player.n(name, bodies, selected)
  local p = {}
  setmetatable(p,Player)
  p.name = name
  p.bodies = bodies
  p.selected = selected
  p.tot_value = 0
  for _,b in pairs(bodies) do
    p.tot_value = p.tot_value+ b.value
    b.player = p
  end
  p.score = 0
  selected.selected = true
  p.launching = {
    status = false,
    x = 0,
    y = 0
  }
  return p
end

function Player:points()
  local point=0
  for _,b in pairs(self.bodies) do
    point =point+ b.points*b.value
  end
  return point/self.tot_value
end
