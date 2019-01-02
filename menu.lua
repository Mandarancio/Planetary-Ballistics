Menu = {}
Menu.__index = Menu

function Menu.new()
  local m = {}
  setmetatable(m,Menu)
  m.logo = love.graphics.newImage("logo.png")
  m.selected = 1
  m.items = {'Planetary System', 'Solar System', 'Commands'}
  return m
end

function Menu:update(dt)
end

function Menu:draw()
  love.graphics.setColor(0, 0, 0, 1)
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
    in_game= true
  elseif value == 2 then
    game = Game.new("Player",4,4,true, true)
    in_game = true
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
  if key == 'down' and self.selected<3 then
    self.selected = self.selected+1
  elseif key == 'up' and self.selected>1 then
    self.selected = self.selected-1
  elseif key == 'return' then
    self:exec(self.selected)
  end
end
