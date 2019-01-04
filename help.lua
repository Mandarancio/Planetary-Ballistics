Help = {}
Help.__index = Help

function Help.new(help)
  local m = {}
  setmetatable(m,Help)
  m.help = help
  m.active = false
  m.fh = bigFont:getHeight()
  m.fw = bigFont:getWidth("< ESC")
  m.x = 20
  m.y = 20
  return m
end

function Help:update(dt)
end

function Help:draw()
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle('fill', 0, 0,screen.w, screen.h)
  love.graphics.setFont(bigFont)
  love.graphics.setColor(0, 1, 0, 1)
  local fh = bigFont:getHeight()
  love.graphics.print("< ESC", 30,30)
  love.graphics.rectangle("line", 20, 20, self.fw+20, fh+20)
  local y = (screen.h/2-(fh*#self.help))
  for i=1,#self.help do
    love.graphics.print(self.help[i][1], 100, y+fh/2)
    love.graphics.print(":", 140, y+fh/2)
    love.graphics.print(self.help[i][2], 160, y+fh/2)

    y = y+3*fh
  end
end

function Help:keypressed(key)
  if key == 'escape' then
    self.active = false
    in_game = status.menu
  end
end

function Help:mousepressed(x,y, button)
  if button~=1 then
    return
  end
  if x >= self.x and x <= self.x + self.fw + 20 then
    if y >= self.y and y <= self.y + self.fh + 20 then
      self.active = false
      in_game = status.menu
    end
  end
end