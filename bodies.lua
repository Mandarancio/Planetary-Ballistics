require("geotest")

max_rocekt_speed = 300

Body = {}
Body.__index = Body


function Body.create(name,position, speed, radius, color, mass)
  local cb = {}
  setmetatable(cb, Body)
  cb.name = name
  cb.speed = speed
  cb.color = color
  cb.accelleration = Vec2D.null()
  cb.position = position
  cb.radius = radius
  cb.s_radius = radius*radius
  cb.mass = mass
  cb.tot_mass =mass
  cb.points = 100
  cb.rockets = 10
  cb.selected = false
  cb.value = 100
  cb.player = nil
  cb.to_remove = false
  cb.poly = {}
  cb.create = 0
  local delta = 2*math.pi/20
  for i=1,20 do
    cb.poly[#cb.poly+1]=math.cos(i*delta)*radius
    cb.poly[#cb.poly+1]=math.sin(i*delta)*radius
  end

  return cb
end


function Body:draw_launch(x,y, scale)
  love.graphics.push()
  love.graphics.scale(1/scale, 1/scale)
  d = x*x+y*y
  if d > self.s_radius then
    a = math.atan2(y, x)
    x0 = (self.radius+5)*math.cos(a)*scale
    y0 = (self.radius+5)*math.sin(a)*scale

    if d>max_rocekt_speed^2 then
      x1 = max_rocekt_speed * math.cos(a)
      y1 = max_rocekt_speed * math.sin(a)

      love.graphics.setColor(255, 255, 255, 50)
      love.graphics.line(x1,y1,x,y)
      love.graphics.rectangle('line', x-5, y-5, 10,10)
      love.graphics.setColor(100, 255, 100, 150)

      love.graphics.line(x0, y0, x1, y1)
      love.graphics.circle('line', x1, y1, 5, 10)
    else
      love.graphics.setColor(100, 255, 100, 150)

      love.graphics.rectangle('line', x-5, y-5, 10,10)
      love.graphics.line(x0, y0, x, y)
    end
  end
  love.graphics.pop()
end

function Body:launch(x,y)
  local d = x*x+y*y
  if d > self.s_radius then
    self.rockets= self.rockets-1
    local a = math.atan2(y, x)
    local x0 = (self.radius+5)*math.cos(a)
    local y0 = (self.radius+5)*math.sin(a)
    local s = Vec2D.n(x,y)
    local m = s:mod()
    if m>max_rocekt_speed then
      s = s*max_rocekt_speed*1.5/m
    end
    return Rocket.n(Vec2D.n(x0,y0)+self.position, s+self.speed, self, self.color)
  end
  return nil
end

function Body:draw(scale)
  love.graphics.push()
  love.graphics.translate(self.position.x, self.position.y)

  love.graphics.setColor(self.color.red, self.color.green, self.color.blue,100)
  love.graphics.circle('line', 0, 0, self.radius+1, 2*self.radius)
  -- love.graphics.line(0,0,self.speed.x,self.speed.y)
  -- love.graphics.circle("line", 0, 0, self.radius, 2*self.radius)




  if self.selected then

    love.graphics.polygon('fill', self.poly)


    if self.player.launching.status then
      self:draw_launch(self.player.launching.x, self.player.launching.y,scale)
    end
  end
  love.graphics.setColor(self.color.red, self.color.green, self.color.blue,255)
  love.graphics.polygon('line',self.poly)

  love.graphics.pop()
end

function Body:clicked(x,y,scale)
  if self.points>0 then
    return (Vec2D.n(x,y)-self.position):mod2()<self.s_radius+9/(scale^2)
  end
  return false
end

function Body:contains(pos)
  local rp = pos-self.position
  if rp:mod2() < self.s_radius then
    return PointWithinShape(self.poly, rp.x,rp.y)
  end
  return false
end

function Body:impact(obj)
  local pos = obj.position
  local speed = obj.speed
  local force = 1
  local scale = 1
  local type = getmetatable(obj)
  if type == Debris then
    force = obj.radius/10
    scale = obj.radius
  end

  local max = 20
  for i=1,20 do
    local x = self.poly[i*2-1]
    local y = self.poly[i*2]

    local v = Vec2D.n(x+self.position.x,y+self.position.y)
    local d = (v-pos):mod2()
    if d<max then
      local int = 0.01*(1-math.abs(d/max))*scale
      local lr = (1 - int +(math.random()-0.5)*0.08)*math.sqrt(x*x+y*y)
      self.poly[i*2-1]= lr*math.cos(i*math.pi/10)
      self.poly[i*2]= lr*math.sin(i*math.pi/10)
    end
  end
  local to_generate = {}

  if scale == 1 then
    local mass =1
    local d = math.random(2,9)
    local base = -(math.random()*0.2+0.1)*speed:mod()
    local ip = self.position-pos
    local vbase = base/5*ip
    for i=1,d do
      to_generate[i] = Debris.n(pos+vbase*0.07+Vec2D.rand(10),self.speed*0.8+vbase*0.2+Vec2D.rand(5), self.color, mass)
    end
  end
  if type == Rocket then
    self.points = self.points - 20
  elseif type == Body or type==DeadPlanet then
    self.points = 0
  else
    self.points = self.points - 0.1
  end
  if self.points <= 0 then
    self.to_remove = true
    self.points = 0
  end
  return to_generate
end

function Body:itinerary(old)
  if self.rockets<10 then
    self.create = self.create+1
    if self.create == 1000 then
      self.create = 0
      self.rockets = self.rockets+1
    end
  end
end

function Body:remove()
  print("Destroy : "..self.name.." : "..self.points)
  if self.selected then
    self.selected = false
    self.player.selected = nil
  end
  self.points = 0

  return {DeadPlanet.n(self.position,self.speed,self.mass,self.radius,self.poly)}
end


Rocket = {}
Rocket.__index = Rocket


function Rocket.n(position, speed, origin, color)
  local r = {}
  setmetatable(r,Rocket)
  r.color = color

  r.accelleration = Vec2D.null()
  r.position = position
  r.max_histo = 80
  r.radius=0
  r.speed = speed
  r.mass = 1e-2
  r.owner = origin.player
  r.origin = origin
  r.__itinerary={position}
  r.to_remove = false
  r.poly = {-4,2, 2,2,4,0,2,-2,-4,-2}
  r.life = 0
  r.max_life = 1000
  return r
end

function Rocket:draw()
  love.graphics.push()
  love.graphics.translate(self.position.x, self.position.y)
  love.graphics.rotate(math.atan2(self.speed.y-self.origin.speed.y, self.speed.x-self.origin.speed.x))
  love.graphics.setColor(self.color.red,self.color.green,self.color.blue)
  love.graphics.polygon('line',self.poly)
  love.graphics.pop()
  local alpha = (self.max_histo-#self.__itinerary)*(100/self.max_histo)
  for i=1,#self.__itinerary do

    love.graphics.setColor(255,255,255,alpha)
    alpha = alpha+1
    -- love.graphics.line(self.__itinerary[i-1].x,self.__itinerary[i-1].y, self.__itinerary[i].x,self.__itinerary[i].y)
    -- local k = ((1-i/#self.__itinerary)^4)*self.origin.position
    love.graphics.circle('line',self.__itinerary[i].x,self.__itinerary[i].y,1.5,8)
  end
end

function Rocket:contains(pos)
  return false
end

function Rocket:impact(pos)
  self.to_remove =true
  return {}
end

function Rocket:itinerary(old)
  self.life = self.life + 1
  if self.life >= self.max_life then
    self.to_remove = true
  end
  if (old-self.__itinerary[#self.__itinerary]):mod2() >=100 then
    if #self.__itinerary>self.max_histo then
      table.remove(self.__itinerary,1)
    end
    self.__itinerary[#self.__itinerary+1] = old
  end
end

function Rocket:target(b)
  if b.player ~= self.owner then
    self.owner.score  = self.owner.score+20
    self.origin.rockets=  self.origin.rockets+1
  else
    self.owner.score  = self.owner.score-30
  end
end

function Rocket:remove()
  print('destroy rocket')
  -- print(self.life)
 -- if self.life >= self.max_life then
    local d={}
    local N = math.random(4,10)
    for i =1,N do
       d[#d+1] = Debris.n(self.position+Vec2D.rand(5),self.speed+Vec2D.rand(30), self.color, 1)
    end
    return d
  --end
  --return nil
end

DeadPlanet = {}
DeadPlanet.__index = DeadPlanet

function DeadPlanet.n(position, speed, mass, radius , poly)
  local r = {}
  setmetatable(r,DeadPlanet)

  r.position = position
  r.accelleration = Vec2D.null()
  r.speed = speed
  r.mass = mass

  r.to_remove = false

  r.radius = radius
  r.s_radius = r.radius^2
  r.poly = poly

  return r
end

function DeadPlanet:itinerary(old)
end

function DeadPlanet:draw()
  love.graphics.push()
  love.graphics.translate(self.position.x, self.position.y)
  love.graphics.setColor(155,155,155)
  -- love.graphics.circle("line", 0, 0, self.radius, 2*self.radius)
  love.graphics.polygon('line',self.poly)
  love.graphics.pop()
end

function DeadPlanet:target(b)
end

function DeadPlanet:remove()
  -- print('destroy DeadPlanet ? Why?')
  self.position = self.position + Vec2D.rand(2)
  return {self}
end

function DeadPlanet:contains(pos)
  local rp = pos-self.position
  if rp:mod2() < self.s_radius then
    return PointWithinShape(self.poly, rp.x,rp.y)
  end
  return false
end

function DeadPlanet:impact(obj)
  local pos = obj.position
  local speed = obj.speed
  local force = 1
  local scale = 1
  if getmetatable(obj) == Debris then
    force = obj.radius/10
    scale = obj.radius
  end

  local max = #self.poly/2
  for i=1,max do
    local x = self.poly[i*2-1]
    local y = self.poly[i*2]

    local v = Vec2D.n(x+self.position.x,y+self.position.y)
    local d = (v-pos):mod2()
    if d<max then
      local int = 0.02*(1-math.abs(d/max))*scale
      local lr = (1 - int +(math.random()-0.5)*0.08)*math.sqrt(x*x+y*y)
      self.poly[i*2-1]= lr*math.cos(i*math.pi/10)
      self.poly[i*2]= lr*math.sin(i*math.pi/10)
    end
  end
  local to_generate = {}

  local mass =1
  local d = math.random(2,9)
  local base = -(math.random()*0.2+0.1)*speed:mod()
  local ip = self.position-pos
  local vbase = base/5*ip
  for i=1,d do
    to_generate[i] = Debris.n(pos+vbase*0.07+Vec2D.rand(10),self.speed*0.8+vbase*0.2+Vec2D.rand(5), self.color, mass)
  end
  return to_generate
end

Debris = {}
Debris.__index = Debris


function Debris.n(position, speed , color, mass)
  local r = {}
  setmetatable(r,Debris)

  r.position = position
  r.max_life = 1500
  r.life =0
  r.speed = speed
  r.mass = mass
  r.color = color
  r.to_remove = false
  r.radius = 0.5
  r.accelleration= Vec2D.null()
  r.s_radius = 0.25
  local delta = 2*math.pi/5

  return r
end

function Debris:itinerary(old)
  self.life = self.life+1
  if self.life>=self.max_life then
    self.to_remove = true
  end
end

function Debris:draw()
  love.graphics.push()
  love.graphics.translate(self.position.x, self.position.y)
  love.graphics.setColor(self.color.red, self.color.green, self.color.blue, self.color.alpha)
  -- love.graphics.circle("line", 0, 0, self.radius, 2*self.radius)
  love.graphics.points(0,0)
  love.graphics.pop()
end

function Debris:target(b)
end

function Debris:impact(pos)
  self.to_remove= true
  return {}
end

function Debris:remove()
  --- print('destroy debris')
  return nil
end

function Debris:contains(pos)
  local rp = pos-self.position
  return rp:mod2() < self.s_radius
end


Star = {}
Star.__index = Star


function Star.n(position , mass, radius)
  local r = {}
  setmetatable(r,Star)

  r.position = position
  r.accelleration = Vec2D.null()
  r.speed = Vec2D.null()
  r.mass = mass
  r.color = {red=255,green=255,blue=100}
  r.to_remove = false
  r.radius = radius
  r.s_radius = r.radius^2
  return r
end

function Star:itinerary(old)
end

function Star:draw()
  love.graphics.push()
  love.graphics.translate(self.position.x, self.position.y)
  love.graphics.setColor(self.color.red, self.color.green, self.color.blue, 150)
  love.graphics.circle('fill', 0, 0, self.radius, self.radius*2)
  love.graphics.setColor(self.color.red, self.color.green, self.color.blue, 255)
  love.graphics.circle('line', 0, 0, self.radius, self.radius*2)

  love.graphics.pop()
end

function Star:target(b)
end

function Star:remove()
  --- print('destroy debris')
  return {self}
end

function Star:contains(pos)
  local rp = pos-self.position
  return rp:mod2() < self.s_radius
end

function Star:impact()
end
