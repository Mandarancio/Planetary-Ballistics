
require("vec2d")
require("bodies")
require("player")
require("phys")
require("utils")

screen ={
  w=0,
  h=0,
  cx = 0,
  cy = 0
}

scale = 1
player = nil
ai = nil
bigFont = love.graphics.newFont("whitrabt.ttf",18)
smallFont = love.graphics.newFont("whitrabt.ttf",16)
universe = Phys.n(1e2)
bg = nil


function love.load()
  local player_body = Body.create("P1N2", Vec2D.null(),Vec2D.null(),15,{red=100,blue=100,green=255,alpha=255},1000)
  local speed = universe:orbit_speed(1000,250)
  local p2 = Body.create("P1N1", Vec2D.n(250,0),Vec2D.n(0,speed),8,{red=100,blue=100, green=255, alpha=255},150)
  player = Player.n("Player",{player_body, p2}, player_body)
  speed = universe:orbit_speed(1000,150)
  local p3 = Body.create("P2N4", Vec2D.n(0,150),Vec2D.n(speed,0),6,{red=255,blue=100, green=100,alpha=255},100)
  ai = PlayerAI.n("AI", {p3}, p3, player)
  local bodies = {}

  bodies[#bodies+1]= player_body
  bodies[#bodies+1] = p3
  bodies[#bodies+1] = p2
  universe.bodies= bodies
  screen.w = love.graphics.getWidth()
  screen.h = love.graphics.getHeight()
  screen.cx = screen.w/2
  screen.cy = screen.h/2
  -- rint(screen.w..'x'..screen.h)
  bg = love.graphics.newImage("bg.png")
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

  love.graphics.draw(bg, 0, 0)
  local bfh = bigFont:getHeight()
  local sfh = smallFont:getHeight()
  love.graphics.setFont(bigFont)
  love.graphics.print(player.name..' : '..string.format("%.2f",player:points())..'%',2,bfh)
  local string = 'Planet : '..player.selected.name..' ('..string.format("%.2f",player.selected.points)..'%)'
  love.graphics.setFont(smallFont)
  love.graphics.print(string, 2,bfh+4+sfh)
  love.graphics.print('Score : '..player.score,2, bfh+8+2*sfh)
  draw_rockets(player.selected.rockets, smallFont:getWidth(string)+10,bfh+2+2*sfh,4,sfh)
  love.graphics.push()
  love.graphics.translate(screen.cx, screen.cy)
  love.graphics.scale(scale, scale)
  love.graphics.translate(-player.selected.position.x, - player.selected.position.y)
  for _,body in pairs(universe.bodies) do
    body:draw()
  end
  love.graphics.pop()
end

function love.update(dt)
  universe:update(dt)
  local r = ai:update(dt)
  if r~=nil then
      universe.bodies[#universe.bodies+1]=r
  end

end

function love.mousepressed(x, y, button, isTouch)
  local cx = (x - screen.cx)/scale
  local cy = (y - screen.cy)/scale
  for _,p in pairs(player.bodies) do
    if p~=nil and p ~= player.selected and p.points > 0 and p:clicked(cx+player.selected.position.x,cy+player.selected.position.y) then
      player.selected.selected = false
      p.selected = true
      player.selected = p
      return
    end
  end
  if player.selected.rockets>0 then
    player.launching.status = true
    player.launching.x = cx*scale
    player.launching.y = cy*scale
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
    local r = player.selected:launch((x-screen.cx)/scale,(y-screen.cy)/scale)
    if r~=nil then
      universe.bodies[#universe.bodies+1]=r
    end
  end
end

function love.keypressed(key, scancode, isrepeat)
  if key == 'p' then
    if scale < 4 then
      scale = scale*2
    end
  elseif key == 'm' then
    if scale > 0.125 then
      scale = scale/2
    end
  end
end

function love.keyreleased(key)
end
