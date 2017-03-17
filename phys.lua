
Phys = {}
Phys.__index = Phys

function find(table, value)
  for k,v in pairs(table) do
    if v==value then
      return k
    end
  end
  return nil
end

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

  local to_remove={}
  local to_add ={}
  for i = 1,#self.bodies do
    local b1 = self.bodies[i]
    if b1.to_remove then
      to_remove[#to_remove+1] = b1
      ::continue::
    end
    for j = 1,#self.bodies do
      if i~=j then
        local b2 = self.bodies[j]

        -- compute distance
        local v = b1.position-b2.position
        local d = v:mod()
        if ((d<b1.radius) or ( d<b2.radius)) and (b1:contains(b2.position) or b2:contains(b1.position)) then
          if (getmetatable(b2) == Rocket ) and getmetatable(b1) == Body then
            local l_to_add = b1:impact(b2)
            b2:target(b1)
            to_remove[#to_remove+1] = b2
            if b1.points <=0 then
              to_remove[#to_remove+1] = b1
            end
            for _,o in pairs(l_to_add) do
              to_add[#to_add+1] = o
            end
          elseif (getmetatable(b1)== Rocket) and getmetatable(b2) == Body then
            local l_to_add = b2:impact(b1)
            b1:target(b2)
            to_remove[#to_remove+1] = b1
            if b2.points <=0 then
              to_remove[#to_remove+1] = b2
            end
            for _,o in pairs(l_to_add) do
              to_add[#to_add+1] = o
            end
          elseif (getmetatable(b1)== Debris and getmetatable(b2)==Body) then
            to_remove[#to_remove+1]=b1
            b2:impact(b1)
          elseif (getmetatable(b2)== Debris and getmetatable(b1)==Body) then
            to_remove[#to_remove+1]=b2
            b1:impact(b2)
          else
            to_remove[#to_remove+1] = b1
            to_remove[#to_remove+1] = b2
          end
        end
        if getmetatable(b2) == Body then
          local f = self:gforce(b1,b2)
          -- udpate speed
          -- a = f/m
          local m_a1 = f/b1.mass
          -- local m_a2 = f/b2.mass
          local a1 = -m_a1*v/d
          -- local a2 = m_a2*v/d

          -- s = s+a*dt
          b1.speed = b1.speed + a1*dt
          -- b2.speed = b2.speed + a2*dt
          -- end
        end
      end
    end
    -- update position
    -- p = p+s*dt
    -- b1.lasts:add(b1.position)
    b1:itinerary(b1.position)
    b1.position = b1.position + b1.speed*dt

  end
  for i=1,#to_remove do
    -- to_remove[i]:remove()
    table.remove(self.bodies, find(self.bodies,to_remove[i]))
  end
  for _,o in pairs(to_add) do
    self.bodies[#self.bodies+1] = o
  end
end
