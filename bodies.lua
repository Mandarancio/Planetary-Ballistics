require("geotest")

Body = {}
Body.__index = Body


function Body.create(name,position, speed, radius, color, mass)
  local cb = {}
  setmetatable(cb, Body)
  cb.name = name
  cb.speed = speed
  cb.color = color
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
  local delta = 2*math.pi/20
  for i=1,20 do
    cb.poly[#cb.poly+1]=math.cos(i*delta)*radius
    cb.poly[#cb.poly+1]=math.sin(i*delta)*radius
  end

  return cb
end


function Body:draw_launch(x,y)
  love.graphics.push()
  love.graphics.scale(1/scale, 1/scale)
  d = x*x+y*y
  if d > self.s_radius then
    a = math.atan2(y, x)
    x0 = (self.radius+5)*math.cos(a)*scale
    y0 = (self.radius+5)*math.sin(a)*scale

    if d>22500 then
      x1 = 150 * math.cos(a)
      y1 = 150 * math.sin(a)

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
    if m>150 then
      s = s*150/m
    end
    return Rocket.n(Vec2D.n(x0,y0)+self.position, s+self.speed, self, self.color)
  end
  return nil
end

function Body:draw()
  love.graphics.push()
  love.graphics.translate(self.position.x, self.position.y)

  love.graphics.setColor(self.color.red, self.color.green, self.color.blue,100)
  love.graphics.circle('line', 0, 0, self.radius+1, 2*self.radius)
  love.graphics.setColor(self.color.red, self.color.green, self.color.blue,255)
  -- love.graphics.line(0,0,self.speed.x,self.speed.y)
  -- love.graphics.circle("line", 0, 0, self.radius, 2*self.radius)
 love.graphics.polygon('line',self.poly)



  if self.selected then
    if self.player.launching.status then
      self:draw_launch(self.player.launching.x, self.player.launching.y)
    end
  end
  love.graphics.pop()
end

function Body:clicked(x,y)
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
  if getmetatable(obj) == Debris then
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
      local int = 0.2*(1-math.abs(d/max))*scale
      local lr = (1 - int +(math.random()-0.5)*0.08)*math.sqrt(x*x+y*y)
      self.poly[i*2-1]= lr*math.cos(i*math.pi/10)
      self.poly[i*2]= lr*math.sin(i*math.pi/10)
    end
  end
  local to_generate = {}

  if scale == 1 then
    local mass =10
    local d = math.random(2,9)
    mass = mass /d
    local base = -(math.random()*0.2+0.1)*speed:mod()
    local ip = self.position-pos
    local vbase = base/5*ip
    for i=1,d do
      to_generate[i] = Debris.n(pos+vbase*0.07+Vec2D.rand(10),self.speed*0.8+vbase*0.2+Vec2D.rand(5), self.color, mass)
    end
  end
  self.points = self.points - 20*force*100/self.value
  self.mass = (0.8+0.2*self.points/100)*self.tot_mass
  return to_generate
end

function Body:itinerary(old)
end

function Body:remove()
  print("Destroy : "..self.name.." : "..self.points)
  return DeadPlanet.n(self.position+Vec2D.rand(5),self.speed+Vec2D.rand(5),  0.8*self.tot_mass,0.8*self.radius)
end


Rocket = {}
Rocket.__index = Rocket


function Rocket.n(position, speed, origin, color)
  local r = {}
  setmetatable(r,Rocket)
  r.color = color
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
  return r
end

function Rocket:draw()
  love.graphics.push()
  love.graphics.translate(self.position.x, self.position.y)
  love.graphics.rotate(math.atan2(self.speed.y, self.speed.x))
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

function Rocket:itinerary(old)
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
  return nil
end

DeadPlanet = {}
DeadPlanet.__index = DeadPlanet

function DeadPlanet.n(position, speed, mass, radius)
  local r = {}
  setmetatable(r,DeadPlanet)

  r.position = position

  r.speed = speed
  r.mass = mass

  r.to_remove = false

  r.radius = radius
  r.s_radius = r.radius^2
  r.poly = {}
  local delta = 2*math.pi/9
  for i=1,9 do
    local l = r.radius*(math.random()*0.3+0.7)
    r.poly[#r.poly+1]=math.cos(i*delta)*l
    r.poly[#r.poly+1]=math.sin(i*delta)*l
  end
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
  print('destroy debris')
  return nil
end

function DeadPlanet:contains(pos)
  local rp = pos-self.position
  if rp:mod2() < self.s_radius then
    return PointWithinShape(self.poly, rp.x,rp.y)
  end
  return false
end

Debris = {}
Debris.__index = Debris


function Debris.n(position, speed , color, mass, radius)
  local r = {}
  setmetatable(r,Debris)

  r.position = position
  r.max_life = 1500
  r.life =0
  r.speed = speed
  r.mass = mass
  r.color = color
  r.to_remove = false
  if radius == nil then
    r.radius = math.random()*1
  else
    r.radius = radius
  end
  r.s_radius = r.radius^2
  r.poly = {}
  local delta = 2*math.pi/5
  for i=1,5 do
    local l = r.radius*(math.random()*0.3+0.7)
    r.poly[#r.poly+1]=math.cos(i*delta)*l
    r.poly[#r.poly+1]=math.sin(i*delta)*l
  end
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
  love.graphics.polygon('line',self.poly)
  love.graphics.pop()
end

function Debris:target(b)
end

function Debris:remove()
  print('destroy debris')
  return nil
end

function Debris:contains(pos)
  local rp = pos-self.position
  if rp:mod2() < self.s_radius then
    return PointWithinShape(self.poly, rp.x,rp.y)
  end
  return false
end
