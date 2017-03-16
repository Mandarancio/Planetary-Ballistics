
Phys = {}
Phys.__index = Phys

function Phys.n(G)
  local p = {}
  setmetatable(p,Phys)
  p.G = G
  p.bodies = {}
  return p
end

function Phys:gforce(a,b)
  r = (a.position-b.position):mod2()
  m = a.mass*b.mass
  return self.G*m/r
end

function Phys:orbit_speed(mass,r)
  local mu = self.G*mass
  local eps = -mu/(2*r)
  local sp = math.sqrt(2*(mu/r+eps))
  return sp
end

function Phys:update(dt)

  for i = 1,#self.bodies do
    local b1 = self.bodies[i]
    for j = i+1,#self.bodies,1 do
      local b2 = self.bodies[j]
      -- compute distance
      local v = b1.position-b2.position
      local d = v:mod()
      local f = self:gforce(b1,b2)
      -- udpate speed
      -- a = f/m
      local m_a1 = f/b1.mass
      local m_a2 = f/b2.mass
      local a1 = -m_a1*v/d
      local a2 = m_a2*v/d

      -- s = s+a*dt
      b1.speed = b1.speed + a1*dt
      b2.speed = b2.speed + a2*dt
      -- end
    end
    -- update position
    -- p = p+s*dt
    -- b1.lasts:add(b1.position)
    b1.position = b1.position + b1.speed*dt

  end
end
