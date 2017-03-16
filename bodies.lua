
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
  cb.points = 100
  cb.rockets = 10
  cb.selected = false
  cb.value = 100
  cb.player = nil
  cb.to_remove = false
  cb.poly = {}
  local delta = 2*math.pi/20
  for i=1,21 do
    cb.poly[#cb.poly+1]=math.cos(i*delta)*radius
    cb.poly[#cb.poly+1]=math.sin(i*delta)*radius
  end

  return cb
end



function Body:draw_launch(x,y)
  d = x*x+y*y
  if d > self.s_radius then
    a = math.atan2(y, x)
    x0 = (self.radius+5)*math.cos(a)
    y0 = (self.radius+5)*math.sin(a)

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
    print(s:mod())
    return Rocket.n(Vec2D.n(x0,y0)+self.position, s+self.speed, self)
  end
  return nil
end

function Body:draw()
  love.graphics.push()
  love.graphics.translate(self.position.x, self.position.y)
  love.graphics.setColor(self.color.red, self.color.green, self.color.blue, self.color.alpha)
  -- love.graphics.circle("line", 0, 0, self.radius, 2*self.radius)
  love.graphics.line(self.poly)
  if self.selected then
    if self.player.launching.status then
      self:draw_launch(self.player.launching.x, self.player.launching.y)
    end
  end
  love.graphics.pop()
end

function Body:contains(x,y)
  if self.points>0 then
    return (Vec2D.n(x,y)-self.position):mod2()<self.s_radius
  end
  return false
end

function Body:impact(pos,speed)
  local max = 20
  for i=1,21 do
    local x = self.poly[i*2-1]
    local y = self.poly[i*2]

    local v = Vec2D.n(x+self.position.x,y+self.position.y)
    local d = (v-pos):mod2()
    if d<max then
      local int = 0.5*(1-math.abs(d/max))
      local lr = (1 - int +(math.random()-0.5)*0.3)*math.sqrt(x*x+y*y)
      self.poly[i*2-1]= lr*math.cos(i*math.pi/10)
      self.poly[i*2]= lr*math.sin(i*math.pi/10)
    end
  end
  local d = math.random(2,5)
  local to_generate = {}
  local base = -(math.random()*0.2+0.2)*speed
  for i=1,d do
    to_generate[i] = Debris.n(pos+base*0.2+Vec2D.rand(10),self.speed+base+Vec2D.rand(5), self.color)
  end
  self.points = self.points - 20
  return to_generate
end

function Body:itinerary(old)
end

Rocket = {}
Rocket.__index = Rocket


function Rocket.n(position, speed, origin)
  local r = {}
  setmetatable(r,Rocket)

  r.position = position
  r.max_histo = 80
  r.radius=0
  r.speed = speed
  r.mass = 1
  r.owner = origin.player
  r.origin = origin
  r.__itinerary={position}
  r.to_remove = false
  return r
end

function Rocket:draw()
  love.graphics.push()
  love.graphics.translate(self.position.x, self.position.y)
  love.graphics.rotate(math.atan2(self.speed.y, self.speed.x))
  love.graphics.setColor(255,255,255,255)
  love.graphics.line(-4,2, 2,2,4,0,2,-2,-4,-2,-4,2)
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

Debris = {}
Debris.__index = Debris


function Debris.n(position, speed , color)
  local r = {}
  setmetatable(r,Debris)

  r.position = position
  r.max_life = 1500
  r.life =0
  r.speed = speed
  r.mass = 1
  r.color = color
  r.to_remove = false
  r.radius = math.random()*3
  r.poly = {}
  local delta = 2*math.pi/5
  for i=1,6 do
    r.poly[#r.poly+1]=math.cos(i*delta)*r.radius
    r.poly[#r.poly+1]=math.sin(i*delta)*r.radius
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
  love.graphics.line(self.poly)
  love.graphics.pop()
end

function Debris:target(b)
end
