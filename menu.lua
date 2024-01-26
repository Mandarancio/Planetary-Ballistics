require("vec2d")
require("bodies")
require("phys")

Menu = {}
Menu.__index = Menu

function Menu.new()
  N = 100
  local m = {}
  setmetatable(m, Menu)
  m.logo = love.graphics.newImage("logo_nobg.png")
  m.selected = 1
  m.items = { 'Planetary System', 'Solar System', 'Commands', 'Quit' }
  m.bodies = {}
  m.G = 1e-11
  m.r = Vec2D.null()
  for i = 1, N do
    local p = Vec2D.rand(200)
    m.bodies[i] = { p, -0.1 * math.random() * p / p:mod(), math.random() * 1e9 }
    m.r = m.r + p
  end
  m.r = m.r / #m.bodies
  m.bg = love.graphics.newImage("bg_tail.png")
  m.bg:setWrap("repeat", "repeat")
  m.quad = love.graphics.newQuad(-8 * PBGame.screen.w, -8 * PBGame.screen.h, 16 * PBGame.screen.w, 16 * PBGame.screen.h,
    m.bg:getWidth(), m.bg:getHeight())

  return m
end

function Menu:update(_)
  --  r = Vec2D.null()
  --  G = self.G
  --  for i, b1 in pairs(self.bodies) do
  --    x1 = b1[1]
  --    v1 = b1[2]
  --    m1 = b1[3]
  --    for j=i+1, #self.bodies do
  --      b2 = self.bodies[j]
  --      x2 = b2[1]
  --      v2 = b2[2]
  --      m2 = b2[3]
  --      d = x1 - x2
  --      F = G*m1*m2*d/(d:mod()^3)
  --      a12 = F/m1
  --      a21 = F/(-m2)
  --      v1 = v1 + a12 * dt
  --      v2 = v2 + a21 * dt
  --      x1 = x1 + v1 * dt
  --      x2 = x2 + v2 * dt
  --      b2[1] = x2
  --      b2[2] = v2
  --    end
  --    b1[1] = x1
  --    b1[2] = v1
  --    r = r + x1
  --  end
  --  self.r = r / #self.bodies
end

function Menu:draw()
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle('fill', 0, 0, PBGame.screen.w, PBGame.screen.h)
  love.graphics.setColor(0.5, 1, 0.5, 1)

  love.graphics.draw(self.bg, self.quad, -PBGame.screen.w * 8, -PBGame.screen.h * 8)

  local cx = PBGame.screen.w / 2 - self.r.x
  local cy = PBGame.screen.h / 2 + 50 - self.r.y
  love.graphics.push()
  love.graphics.translate(cx, cy)
  love.graphics.setColor(1, 1, 1, 0.9)
  -- for _, b in pairs(self.bodies) do
  --   love.graphics.points(b[1].x, b[1].y)
  -- end
  love.graphics.pop()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.logo, 0, 0)
  love.graphics.setColor(0, 1, 0, 1)
  love.graphics.setFont(PBGame.bigFont)
  local fh = PBGame.bigFont:getHeight()
  local y = 250
  local rh = 50
  local rw = 300
  for i = 1, #self.items do
    if i == self.selected then
      love.graphics.setColor(0, 1, 0, 1)
    else
      love.graphics.setColor(1, 1, 1, 1)
    end

    local string = self.items[i]
    local fw = PBGame.bigFont:getWidth(string)
    love.graphics.rectangle('line', PBGame.screen.cx - rw / 2, y, rw, rh)
    love.graphics.print(string, PBGame.screen.cx - fw / 2, y + rh / 2 - fh / 2)
    y = y + 75
  end
end

function Menu:exec(value)
  if value == 1 then
    Game = Game.new("Player", 2, 3, true, false)
    PBGame.inGame = PBGame.status.game
  elseif value == 2 then
    Game = Game.new("Player", 4, 4, true, true)
    PBGame.inGame = PBGame.status.game
  elseif value == 3 then
    PBGame.inGame = PBGame.status.help
  elseif value == 4 then
    love.event.quit()
  end
end

function Menu:mousepressed(x, y, button)
  if button ~= 1 then
    return
  end
  x = x - PBGame.screen.cx

  if x >= -150 and x <= 150 then
    local ry = 250

    for i = 1, #self.items do
      if y >= ry and y <= ry + 50 then
        self.selected = i
        self:exec(i)
        return
      end
      ry = ry + 75
    end
  end
end

function Menu:keypressed(key)
  local N = #self.items
  if key == 'down' then
    self.selected = (self.selected % N) + 1
  elseif key == 'up' then
    self.selected = ((self.selected - 2) % N) + 1
  elseif key == 'return' then
    self:exec(self.selected)
  end
end
