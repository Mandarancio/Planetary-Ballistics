require("player")
require("phys")
require("bodies")
require("vec2d")

Game  ={}
Game.__index = Game

function Game:generate_system(N,M)
  local system = {
    player ={},
    ai = {}
  }
  local player_color = {red=100,green = 255, blue = 100 , alpha = 255}
  local ai_color = {red=255, green = 100, blue=100, alpha =255}
  local central_body_mass = math.random(3000,5000)
  local min_radius = 4
  local max_radius = 20
  local min_dist = 90
  local max_dist = 500
  local min_mass = 90
  local max_mass = 200
  system.player[1] = Body.create("P1N1",Vec2D.null(), Vec2D.null(), math.random(max_radius-min_radius, max_radius), player_color, central_body_mass)
  max_radius = 10
  for i=2,N do
    local d = math.random(min_dist,max_dist)
    local r = math.random(min_radius,max_radius)
    local mass = math.random(min_mass,max_mass)
    local speed = self.universe:orbit_speed(central_body_mass,d)
    local a = math.random()*2*math.pi
    local pos = Vec2D.n(d*math.cos(a),d*math.sin(a))
    local spe = Vec2D.n(-speed*math.sin(a), speed*math.cos(a))
    system.player[i]= Body.create("P1"..i.."N",pos,spe,r,player_color,mass)
  end
  for i=1,M do
    local d = math.random(min_dist,max_dist)
    local r = math.random(min_radius,max_radius)
    local mass = math.random(min_mass,max_mass)
    local speed = self.universe:orbit_speed(central_body_mass,d)
    local a = math.random()*2*math.pi
    local pos = Vec2D.n(d*math.cos(a),d*math.sin(a))
    local spe = Vec2D.n(-speed*math.sin(a), speed*math.cos(a))
    system.ai[i]= Body.create("P2"..i.."N",pos,spe,r,ai_color,mass)
  end
  return system
end

function Game.new(player_name,N_player, N_ai, Player_center)
  local g = {}
  setmetatable(g,Game)
  g.n_player = N_player
  g.player_name = player_name
  g.n_ai = N_ai
  g.player_center = Player_center
  g.in_pause = false
  g.gameove = false
  g.player = nil
  g.ai = nil
  g.scale = 1
  g.universe =  Phys.n(1e2)
  g.winner = ""
  g.bg =love.graphics.newImage("bg.png")
  g:init()
  return g
end

function Game:draw_rocket(x,y,w,h)
  local th=h/4
  love.graphics.line(x,y,x+w,y,x+w,y-h+th,x+w/2,y-h,x,y-h+th,x,y)
end

function  Game:draw_rockets(num, x,y, w,h)
  ts= 4
  for i=1,num do
    self:draw_rocket(x,y,w,h)
    x = x+w+ts
  end
  if self.player.selected.create>0 then
    local hh = h*self.player.selected.create/1000
    love.graphics.rectangle('fill', x, y-hh, w, hh)
    love.graphics.rectangle('line', x, y-hh, w, hh)
  end
end

function Game:init()
  local system = nil
  if self.player_center then
    system = self:generate_system(self.n_player, self.n_ai)
    self.player = Player.n(self.player_name, system.player, system.player[math.random(1, self.n_player)])
    self.ai = PlayerAI.n("AI", system.ai, system.ai[math.random(1, self.n_ai)], self.player)
  else
    system = self:generate_system(self.n_ai, self.n_player)
    self.player = Player.n(self.player_name, system.ai, system.ai[math.random(1, self.n_player)])
    self.ai = PlayerAI.n("AI", system.player, system.player[math.random(1, self.n_ai)], self.player)
  end
  for _,p in pairs(system.player) do
    self.universe.bodies[#self.universe.bodies+1]=p
  end
  for _,p in pairs(system.ai) do
    self.universe.bodies[#self.universe.bodies+1]=p
  end
end

function Game:draw()
  love.graphics.setColor(100, 255, 100, 255)
  love.graphics.draw(self.bg, 0, 0)
  local bfh = bigFont:getHeight()
  local sfh = smallFont:getHeight()
  love.graphics.setFont(bigFont)
  love.graphics.print(self.player.name..' : '..string.format("%.2f",self.player:points())..'%',2,bfh)
  local string = 'Planet : '
  if self.player.selected ~= nil then
    string = string .. self.player.selected.name..' ('..string.format("%.2f",self.player.selected.points)..'%)'
  else
    string = string .. " - "
  end
  love.graphics.setFont(smallFont)
  love.graphics.print(string, 2,bfh+4+sfh)
  love.graphics.print('Score : '..self.player.score,2, bfh+8+2*sfh)
  if self.player.selected~=nil then
    self:draw_rockets(self.player.selected.rockets, smallFont:getWidth(string)+10,bfh+2+2*sfh,4,sfh)
  end
  love.graphics.push()
  love.graphics.translate(screen.cx, screen.cy)
  love.graphics.scale(self.scale, self.scale)
  if self.player.selected~=nil then
    love.graphics.translate(-self.player.selected.position.x, - self.player.selected.position.y)
  end
  for _,body in pairs(self.universe.bodies) do
    body:draw(self.scale)
  end
  love.graphics.pop()
  if self.gameover then
    love.graphics.setColor(0,0,0,180)
    love.graphics.rectangle('fill', 0, 0, screen.w, screen.h)
    love.graphics.setColor(255,255,255)
    love.graphics.setFont(bigFont)
    local string="Game Over"
    local w = bigFont:getWidth(string)
    love.graphics.print(string,screen.cx-w/2,screen.cy-bfh/2)
    string = "The Winner is: "..self.winner.."!"
    w = smallFont:getWidth(string)
    love.graphics.setFont(smallFont)
    love.graphics.print(string,screen.cx-w/2,screen.cy+bfh/2+sfh/2)

  elseif self.in_pause then
    love.graphics.setColor(0,0,0,180)
    love.graphics.rectangle('fill', 0, 0, screen.w, screen.h)
    love.graphics.setColor(255,255,255)
    love.graphics.setFont(bigFont)
    local string="Pause"
    local w = bigFont:getWidth(string)
    love.graphics.print(string,screen.cx-w/2,screen.cy-bfh/2)
    string = "Press ESC to resume"
    w = smallFont:getWidth(string)
    love.graphics.setFont(smallFont)
    love.graphics.print(string,screen.cx-w/2,screen.cy+bfh/2+sfh/2)
  end
end

function Game:update(dt)
  if not self.in_pause and not self.gameover then
    self.universe:update(dt)
    local r = self.ai:update(dt)
    if r~=nil then
        self.universe.bodies[#self.universe.bodies+1]=r
    end
    if self.player:points()==0 then
      self.gameover = true
      self.winner = self.ai.name
    elseif self.ai:points()==0 then
      self.gameover = true
      self.winner = self.player.name
    end
  end
end

function Game:mousepressed(x, y, button)
  if self.in_pause or self.gameover then
    return
  end
  if button == 1 then
    local cx = (x - screen.cx)/self.scale
    local cy = (y - screen.cy)/self.scale
    if self.player.selected~= nil then
      cx = cx + self.player.selected.position.x
      cy = cy + self.player.selected.position.y
    end
    for _,p in pairs(self.player.bodies) do
      if p~=nil and p ~= self.player.selected and p.points>0 and p:clicked(cx,cy,self.scale) then
        if self.player.selected ~= nil then
          self.player.selected.selected = false
        end
        p.selected = true
        self.player.selected = p
        return
      end
    end
    if self.player.selected~=nil and self.player.selected.rockets>0 then
      self.player.launching.status = true
      self.player.launching.x = (x - screen.cx)
      self.player.launching.y =  (y - screen.cy)
    end
  elseif button == 2 and   self.player.launching.status then
    self.player.launching.status = false
  end
end

function Game:mousemoved(x, y)
  if self.in_pause or self.gameover then
    return
  end
  if self.player.launching.status then
    self.player.launching.x = (x-screen.cx)
    self.player.launching.y = (y-screen.cy)
  end
end

function Game:mousereleased(x, y, button)
  if self.in_pause or self.gameover then
    return
  end
  if button == 1 and self.player.launching.status and self.player.selected~=nil then
    self.player.launching.status = false
    local r = self.player.selected:launch((x-screen.cx)/self.scale,(y-screen.cy)/self.scale,self.scale)
    if r~=nil then
      self.universe.bodies[#self.universe.bodies+1]=r
    end
  end
end

function Game:keypressed(key)
  if key == 'p' then
    if self.scale < 4 then
      self.scale = self.scale*2
    end
  elseif key == 'm' then
    if self.scale > 1/32 then
      self.scale = self.scale/2
    end
  elseif key == 'escape' then

    self.in_pause = not self.in_pause
    if self.gameover then
      in_game = false
    end
    if self.in_pause then
      self.player.launching.status =false
    end
  end
end