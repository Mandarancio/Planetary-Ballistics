keyhelper ={
  ctrl = false,
  key = ''
}

function generate_system(N,M )
  local system = {
    player ={},
    ai = {}
  }
  local player_color = {red=100,green = 255, blue = 100 , alpha = 255}
  local ai_color = {red=255, green = 100, blue=100, alpha =255}
  local central_body_mass = math.random(3000,5000)
  local min_radius = 4
  local max_radius = 20
  local min_dist = 90
  local max_dist = 500
  local min_mass = 10
  local max_mass = 20
  system.player[1] = Body.create("P1N1",Vec2D.null(), Vec2D.null(), math.random(max_radius-min_radius, max_radius), player_color, central_body_mass)
  max_radius = 10
  for i=2,N do
    local d = math.random(min_dist,max_dist)
    local r = math.random(min_radius,max_radius)
    local mass = math.random(min_mass,max_mass)
    local speed = universe:orbit_speed(central_body_mass,d)
    local a = math.random()*2*math.pi
    local pos = Vec2D.n(d*math.cos(a),d*math.sin(a))
    local spe = Vec2D.n(-speed*math.sin(a), speed*math.cos(a))
    system.player[i]= Body.create("P1"..i.."N",pos,spe,r,player_color,mass)
  end
  for i=1,M do
    local d = math.random(min_dist,max_dist)
    local r = math.random(min_radius,max_radius)
    local mass = math.random(min_mass,max_mass)
    local speed = universe:orbit_speed(central_body_mass,d)
    local a = math.random()*2*math.pi
    local pos = Vec2D.n(d*math.cos(a),d*math.sin(a))
    local spe = Vec2D.n(-speed*math.sin(a), speed*math.cos(a))
    system.ai[i]= Body.create("P2"..i.."N",pos,spe,r,ai_color,mass)
  end
  return system
end
