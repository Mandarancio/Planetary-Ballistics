require("vec2d")
require("bodies")
require("phys")

Menu = {}
Menu.__index = Menu

function Menu.new()
  N = 100
  local m = {}
  setmetatable(m,Menu)
  m.logo = love.graphics.newImage("logo_nobg.png")
  m.selected = 1
  m.items = {'Planetary System', 'Solar System', 'Commands', 'Quit'}
  m.bodies = {}
  m.G = 1e-11
  m.r = Vec2D.null()
  for i=1, N do
    p = Vec2D.rand(200)
    m.bodies[i] = {p, -0.1*math.random()*p/p:mod(), math.random()*1e9}
    m.r = m.r + p
  end
  m.r = m.r / #m.bodies
  return m
end

function Menu:update(dt)
  r = Vec2D.null()
  G = self.G
  for i, b1 in pairs(self.bodies) do
    x1 = b1[1]
    v1 = b1[2]
    m1 = b1[3]
    for j=i+1, #self.bodies do
      b2 = self.bodies[j]
      x2 = b2[1]
      v2 = b2[2]
      m2 = b2[3]
      d = x1 - x2
      F = G*m1*m2*d/(d:mod()^3)
      a12 = F/m1
      a21 = F/(-m2)
      v1 = v1 + a12 * dt
      v2 = v2 + a21 * dt
      x1 = x1 + v1 * dt
      x2 = x2 + v2 * dt
      b2[1] = x2
      b2[2] = v2
    end
    b1[1] = x1
    b1[2] = v1
    r = r + x1
  end
  self.r = r / #self.bodies
end

function Menu:draw()
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle('fill', 0, 0,screen.w, screen.h)
  
  cx = screen.w / 2 - self.r.x
  cy = screen.h / 2 + 50 - self.r.y
  love.graphics.push()
  love.graphics.translate(cx, cy)
  love.graphics.setColor(1,1,1,0.9)
  for _, b in pairs(self.bodies) do
    love.graphics.points(b[1].x, b[1].y)
  end
  love.graphics.pop()
  love.graphics.setColor(0, 0, 0, 0.3)

  love.graphics.rectangle('fill', 0, 0,screen.w, screen.h)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.logo,0,0)
  love.graphics.setColor(0, 1, 0, 1)
  love.graphics.setFont(bigFont)
  local fh = bigFont:getHeight()
  local y =250
  local rh = 50
  local rw = 300
  for i=1,#self.items do
    if i == self.selected then
      love.graphics.setColor(0, 1, 0, 1)
    else
      love.graphics.setColor(1, 1, 1, 1)
    end

    local string = self.items[i]
    local fw = bigFont:getWidth(string)
    love.graphics.rectangle('line', screen.cx-rw/2, y,rw, rh)
    love.graphics.print(string, screen.cx-fw/2, y+rh/2-fh/2)
    y = y+75

  end
end

function Menu:exec(value)
  if value == 1 then
    game =  Game.new("Player",2,3,true, false)
    in_game= status.game
  elseif value == 2 then
    game = Game.new("Player",4,4,true, true)
    in_game = status.game
  elseif value == 3 then
    in_game = status.help
  elseif value == 4 then
    love.event.quit()
  end
end

function Menu:mousepressed(x,y, button)
  if button~=1 then
    return
  end
  x = x-screen.cx

  if x>=-150 and x<=150 then
    local ry = 250

    for i=1,#self.items do
      if y>=ry and y<=ry+50 then
        self.selected = i
        self:exec(i)
        return
      end
      ry = ry+75
    end
  end
end

function Menu:keypressed(key)
  if key == 'down' and self.selected<table.getn(self.items) then
    self.selected = self.selected+1
  elseif key == 'up' and self.selected>1 then
    self.selected = self.selected-1
  elseif key == 'return' then
    self:exec(self.selected)
  end
end
