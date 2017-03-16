
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
    return Rocket.n(Vec2D.n(x0,y0)+self.position, s, self.player)
  end
  return nil
end

function Body:draw()
  love.graphics.push()
  love.graphics.translate(self.position.x, self.position.y)
  love.graphics.setColor(self.color.red, self.color.green, self.color.blue, self.color.alpha*self.points/100.)
  love.graphics.circle("line", 0, 0, self.radius, 2*self.radius)

  if self.selected then
    if self.player.launching.status then
      self:draw_launch(self.player.launching.x, self.player.launching.y)
    end
  end
  love.graphics.pop()
end

function Body:contains(x,y)
  if self.points>0 then
    return (Vec2D.n(x,y)-self.position).mod()<self.radius
  end
  return false
end

function Body:itinerary(old)
end

Rocket = {}
Rocket.__index = Rocket

function Rocket.n(position, speed, owner)
  local r = {}
  setmetatable(r,Rocket)
  r.position = position
  r.speed = speed
  r.mass = 1
  r.owner = owner
  r.__itinerary={}
  return r
end

function Rocket:draw()
  love.graphics.push()
  love.graphics.translate(self.position.x, self.position.y)
  love.graphics.rotate(math.atan2(self.speed.y, self.speed.x))
  love.graphics.setColor(255,255,255,255)
  love.graphics.line(-4,2, 2,2,4,0,2,-2,-4,-2,-4,2)
  love.graphics.pop()
  love.graphics.setColor(255,255,255,100)

  for i=1,#self.__itinerary do
    -- love.graphics.line(self.__itinerary[i-1].x,self.__itinerary[i-1].y, self.__itinerary[i].x,self.__itinerary[i].y)
    love.graphics.points(self.__itinerary[i].x,self.__itinerary[i].y)
  end
end
function Rocket:itinerary(old)
  if #self.__itinerary>300 then
    table.remove(self.__itinerary,1)
  end
  self.__itinerary[#self.__itinerary+1]=old
end
