Help = {}
Help.__index = Help

function Help.new(help)
  local m = {}
  setmetatable(m, Help)
  m.help = help
  m.active = false
  m.fh = PBGame.bigFont:getHeight()
  m.fw = PBGame.bigFont:getWidth("< ESC")
  m.x = 20
  m.y = 20
  m.bg = love.graphics.newImage("bg_tail.png")
  m.bg:setWrap("repeat", "repeat")
  m.quad = love.graphics.newQuad(-8 * PBGame.screen.w, -8 * PBGame.screen.h, 16 * PBGame.screen.w, 16 * PBGame.screen.h,
    m.bg:getWidth(),
    m.bg:getHeight())

  return m
end

function Help:update(_)
end

function Help:draw()
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle('fill', 0, 0, PBGame.screen.w, PBGame.screen.h)
  love.graphics.setColor(0.5, 1, 0.5, 1)
  love.graphics.draw(self.bg, self.quad, -PBGame.screen.w * 8, -PBGame.screen.h * 8)
  love.graphics.setFont(PBGame.bigFont)
  love.graphics.setColor(0, 1, 0, 1)
  local fh = PBGame.bigFont:getHeight()
  love.graphics.print("< ESC", 30, 30)
  love.graphics.rectangle("line", 20, 20, self.fw + 20, fh + 20)
  local y = (PBGame.screen.h / 2 - (fh * #self.help))
  for i = 1, #self.help do
    love.graphics.print(self.help[i][1], 100, y + fh / 2)
    love.graphics.print(":", 140, y + fh / 2)
    love.graphics.print(self.help[i][2], 160, y + fh / 2)

    y = y + 3 * fh
  end
end

function Help:keypressed(key)
  if key == 'escape' then
    self.active = false
    InGame = PBGame.status.menu
  end
end

function Help:mousepressed(x, y, button)
  if button ~= 1 then
    return
  end
  if x >= self.x and x <= self.x + self.fw + 20 then
    if y >= self.y and y <= self.y + self.fh + 20 then
      self.active = false
      InGame = PBGame.status.menu
    end
  end
end
