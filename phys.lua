
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
    local old_speed= 1*b1.speed
    local accelleration = Vec2D.null()
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
        self:collision_manager(b1,b2,d,to_remove,to_add)
        if b2.mass > 1 then
          local f = self:gforce(b1,b2)
          -- udpate speed
          -- a = f/m
          local m_a1 = f/b1.mass
          -- local m_a2 = f/b2.mass
          local a1 = -m_a1*v/d
          -- local a2 = m_a2*v/d
          accelleration = accelleration + a1
          -- s = s+a*dt
          --b1.speed = b1.speed + a1*dt
          -- b2.speed = b2.speed + a2*dt
          -- end
        end
      end
    end
    -- update position
    -- p = p+s*dt
    -- b1.lasts:add(b1.position)
    b1:itinerary(b1.position)
    b1.speed= b1.speed + (accelleration)*dt
    b1.position = b1.position + (b1.speed+old_speed)*dt/2
  end
  for i=1,#to_remove do
    local toi = find(self.bodies,to_remove[i])
    if to_remove[i]~=nil and toi ~=nil then

      local rest = to_remove[i]:remove()
      table.remove(self.bodies, toi )
      if rest~= nil then
        for _,p in pairs(rest) do
          to_add[#to_add+1]=p
        end
      end
    end
  end
  for _,o in pairs(to_add) do
    self.bodies[#self.bodies+1] = o
  end
end

function Phys:preview(obj, orig)
  local itinerary = {}
  itinerary[1]=obj.position.x-orig.position.x
  itinerary[2]=obj.position.y- orig.position.y

  local simple_objects = {}
  simple_objects[1] = {mass= orig.mass, position = 1*orig.position, speed = 1*orig.speed}
  for _,o in pairs(self.bodies) do
    if o~= orig and o.mass > 10 then
      simple_objects[#simple_objects+1]={mass = o.mass, position = 1*o.position, speed = 1*o.speed}
    end
  end

  local dt = 0.05
  for t=1,60 do
    local t_speed = 1*obj.speed
    local t_acc = Vec2D.null()

    -- for i=1,#simple_objects do
    --   local a= simple_objects[i]
    --   local old_speed = 1*a.speed
    --   local acc = Vec2D.null()
    --   for j=1,#simple_objects do
    --     if j~=i then
    --       local b = simple_objects[j]
    --       local v = b.position-a.position
    --       local d = v:mod()
    --       local f = self:gforce(a,b)
    --       local m_a1 = f/a.mass
    --       local a1 = m_a1*v/d
    --       acc = acc + a1
    --     end
    --   end
    --   a.speed= a.speed + (acc)*dt
    --   a.position = a.position + (a.speed+old_speed)*dt/2
    -- end

    for i=1,#simple_objects do
      local b = simple_objects[i]
      local v = obj.position-b.position
      local d = v:mod()
      local f = self:gforce(obj,b)
      local m_a1 = f/obj.mass
      local a1 = -m_a1*v/d
      t_acc = t_acc + a1
    end
    if t_acc:mod() > 1e4 then
      return itinerary
    end
    obj.speed = obj.speed+(t_acc)*dt
    obj.position = obj.position + (obj.speed+t_speed)*dt/2

    itinerary[#itinerary+1]=  obj.position.x - orig.position.x
    itinerary[#itinerary+1]=  obj.position.y - orig.position.y --obj.position.y- simple_objects[1].position.y

  end
  return itinerary
end

function Phys:collision_manager(a,b,d, to_remove, to_add)
  local atype = getmetatable(a)
  local btype = getmetatable(b)
  if atype==btype and atype== Rocket then
    if (a.position-b.position):mod2()<25 then
      to_remove[#to_remove+1] = a
      to_remove[#to_remove+1] = b
    end
    return
  end
  if(atype == Body or atype== DeadPlanet) and (btype == Body or btype== DeadPlanet) and  d<a.radius+b.radius then
    to_remove[#to_remove+1] = a
    to_remove[#to_remove+1] = b
  end
  if ((d<a.radius) or ( d<b.radius)) and (a:contains(b.position) or b:contains(a.position)) then
    if btype == Rocket  and atype == Body then
      local l_to_add = a:impact(b)
      b:target(a)
      to_remove[#to_remove+1] = b
      if a.points <=0 then
        to_remove[#to_remove+1] = a
      end
      for _,o in pairs(l_to_add) do
        to_add[#to_add+1] = o
      end
    elseif atype== Rocket and btype == Body then
      local l_to_add = b:impact(a)
      a:target(b)
      to_remove[#to_remove+1] = a
      if b.points <=0 then
        to_remove[#to_remove+1] = b
      end
      for _,o in pairs(l_to_add) do
        to_add[#to_add+1] = o
      end
    elseif (atype== Debris) then
      to_remove[#to_remove+1]=a
      b:impact(a)
    elseif (btype== Debris) then
      to_remove[#to_remove+1]=b
      a:impact(b)
    else
      if (atype==btype and atype==DeadPlanet) then
        a:impact(b)
        b:impact(a)
        a.speed = (a.speed+b.speed)/2+Vec2D.rand(a.speed:mod()/2)
        b.speed = (a.speed+b.speed)/2+Vec2D.rand(b.speed:mod()/2)
        a.position = a.position+Vec2D.rand(10)
        b.position = b.position+Vec2D.rand(10)
      else
        to_remove[#to_remove+1] = a
        to_remove[#to_remove+1] = b
      end
    end
  end
end
