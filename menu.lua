require("vec2d")
require("bodies")
require("phys")

Menu = {}
Menu.__index = Menu

function Menu.new()
  local m = {}
  setmetatable(m,Menu)
  m.logo = love.graphics.newImage("logo.png")
  m.selected = 1
  m.items = {'Planetary System', 'Solar System', 'Commands', 'Quit'}
  m.b1 = Body.create("a", Vec2D.n(50, 0), Vec2D.n(60, -60), 30, {red=1, green = 1, blue=1, alpha =0.5}, 10000, 1)
  m.b1.selected = true
  m.b2 = Body.create("b", Vec2D.n(-50, 0), Vec2D.n(-10, 60), 25, {red=1, green = 1, blue=1, alpha =0.5}, 8000, 1)
  m.b2.selected = true
  m.universe = Phys.n(1e2)
  m.universe.bodies = {m.b1, m.b2}
  return m
end

function Menu:update(dt)
  self.universe:update(dt)
end

function Menu:draw()
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle('fill', 0, 0,screen.w, screen.h)
  r = (self.b1.position + self.b2.position)/2
  cx = screen.w / 2 - r.x
  cy = screen.h / 2 + 50 - r.y
  love.graphics.push()
  love.graphics.translate(cx, cy)
  self.b1:draw()
  self.b2:draw()
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
