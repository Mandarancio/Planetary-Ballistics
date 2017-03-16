
require("vec2d")
require("bodies")
require("player")
require("phys")


screen ={
  w=0,
  h=0,
  cx = 0,
  cy = 0
}


player = nil
bigFont = love.graphics.newFont("whitrabt.ttf",18)
smallFont = love.graphics.newFont("whitrabt.ttf",16)
universe = Phys.n(1e2)

function love.load()
  local player_body = Body.create("P1N2", Vec2D.null(),Vec2D.null(),25,{red=100,blue=100,green=255,alpha=255},1000)
  player = Player.n("Player",{player_body}, player_body)
  local bodies = {}

  bodies[#bodies+1]= player_body
  local speed = universe:orbit_speed(1000,200)
  bodies[#bodies+1] = Body.create("P2N4", Vec2D.n(0,200),Vec2D.n(speed,0),10,{red=255,blue=100, green=100,alpha=255},100)
  universe.bodies= bodies
  screen.w = love.graphics.getWidth()
  screen.h = love.graphics.getHeight()
  screen.cx = screen.w/2
  screen.cy = screen.h/2
end

function draw_rocket(x,y,w,h)
  local th=h/4
  love.graphics.line(x,y,x+w,y,x+w,y-h+th,x+w/2,y-h,x,y-h+th,x,y)
end

function draw_rockets(num, x,y, w,h)
  ts= 4
  for i=1,num do
    draw_rocket(x,y,w,h)
    x = x+w+ts
  end
end

function love.draw()
  love.graphics.setColor(100, 255, 100, 255)
  local bfh = bigFont:getHeight()
  local sfh = smallFont:getHeight()
  love.graphics.setFont(bigFont)
  love.graphics.print(player.name..' : '..player:points()..'%',2,bfh)
  local string = 'Planet : '..player.selected.name..' ('..player.selected.points..'%)'
  love.graphics.setFont(smallFont)
  love.graphics.print(string, 2,bfh+4+sfh)
  love.graphics.print('Score : '..player.score,2, bfh+8+2*sfh)
  draw_rockets(player.selected.rockets, smallFont:getWidth(string)+10,bfh+2+2*sfh,4,sfh)
  love.graphics.push()
  love.graphics.translate(screen.cx-player.selected.position.x, screen.cy-player.selected.position.y)
  for _,body in pairs(universe.bodies) do
    body:draw()
  end
  love.graphics.pop()
end

function love.update(dt)
  universe:update(dt)
end

function love.mousepressed(x, y, button, isTouch)
  if player.selected.rockets>0 then
    player.launching.status = true
    player.launching.x = (x-screen.cx)
    player.launching.y = (y-screen.cy)
  end
end

function love.mousemoved(x, y, dx, dy)
  if player.launching.status then
    player.launching.x = (x-screen.cx)
    player.launching.y = (y-screen.cy)
  end
end

function love.mousereleased(x, y, button, isTouch)
  if player.launching.status then
    player.launching.status = false
    local r = player.selected:launch((x-screen.cx),(y-screen.cy))
    if r~=nil then
      universe.bodies[#universe.bodies+1]=r
    end
  end
end
