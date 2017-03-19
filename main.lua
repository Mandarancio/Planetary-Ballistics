
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
pause = true
gameover = false
winner = ''

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


function love.load()
  math.randomseed( os.time() )
  love.window.setTitle( "Orbital Ballistics" )

  sys = generate_system(3,2)
  -- local d = 1000
  -- local speed = 0 -- universe:orbit_speed(1e6,d)
  -- local player_body = Body.create("P1N2", Vec2D.n(0,d),Vec2D.n(speed,0),15,{red=100,blue=100,green=255,alpha=255},1000)
  -- local lspeed = universe:orbit_speed(1000,320)
  -- local p2 = Body.create("P1N1", Vec2D.n(0,d+300),Vec2D.n(speed+lspeed,0),5,{red=100,blue=100, green=255, alpha=255},90)
  -- player = Player.n("Player",{player_body, p2}, player_body)
  -- -- speed = universe:orbit_speed(1000,150)
  -- lspeed = universe:orbit_speed(1000,220)
  -- local p3 = Body.create("P2N4", Vec2D.n(220,d),Vec2D.n(speed,-lspeed),8,{red=255,blue=100, green=100,alpha=255},100)
  -- ai = PlayerAI.n("AI", {p3}, p3, player)
   local bodies = {}
  --
  -- bodies[#bodies+1]= player_body
  -- bodies[#bodies+1] = p3
  -- bodies[#bodies+1] = p2 --Star.n(Vec2D.null(),1e6,50)
  print(sys.player[1])
  player = Player.n("Player", shallowcopy(sys.player), sys.player[1])
  ai = PlayerAI.n("AI", shallowcopy(sys).ai, player)
  for _,p in pairs(sys.player) do
    bodies[#bodies+1]=p
  end

  for _,p in pairs(sys.ai) do
    bodies[#bodies+1]=p
  end
  player.selected= sys.player[1]
  ai.selected = sys.ai[1]
  ai.enemy = player
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
  if player.selected.create>0 then
    local hh = h*player.selected.create/1000
    love.graphics.rectangle('fill', x, y-hh, w, hh)
    love.graphics.rectangle('line', x, y-hh, w, hh)

  end
end

function love.draw()
  love.graphics.setColor(100, 255, 100, 255)
  love.graphics.draw(bg, 0, 0)
  local bfh = bigFont:getHeight()
  local sfh = smallFont:getHeight()
  love.graphics.setFont(bigFont)
  love.graphics.print(player.name..' : '..string.format("%.2f",player:points())..'%',2,bfh)
  local string = 'Planet : '
  if player.selected ~= nil then
    string = string .. player.selected.name..' ('..string.format("%.2f",player.selected.points)..'%)'
  else
    string = string .. " - "
  end
  love.graphics.setFont(smallFont)
  love.graphics.print(string, 2,bfh+4+sfh)
  love.graphics.print('Score : '..player.score,2, bfh+8+2*sfh)
  if player.selected~=nil then
    draw_rockets(player.selected.rockets, smallFont:getWidth(string)+10,bfh+2+2*sfh,4,sfh)
  end
  love.graphics.push()
  love.graphics.translate(screen.cx, screen.cy)
  love.graphics.scale(scale, scale)
  if player.selected~=nil then

    love.graphics.translate(-player.selected.position.x, - player.selected.position.y)
  end
  for _,body in pairs(universe.bodies) do
    body:draw()
  end
  love.graphics.pop()
  if gameover then
    love.graphics.setColor(0,0,0,180)
    love.graphics.rectangle('fill', 0, 0, screen.w, screen.h)
    love.graphics.setColor(255,255,255)
    love.graphics.setFont(bigFont)
    local string="Game Over"
    local w = bigFont:getWidth(string)
    love.graphics.print(string,screen.cx-w/2,screen.cy-bfh/2)
    string = "The Winner is: "..winner.."!"
    w = smallFont:getWidth(string)
    love.graphics.setFont(smallFont)
    love.graphics.print(string,screen.cx-w/2,screen.cy+bfh/2+sfh/2)

  elseif pause then
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

function love.update(dt)
  if not pause and not gameover then
    universe:update(dt)
    local r = ai:update(dt)
    if r~=nil then
        universe.bodies[#universe.bodies+1]=r
    end
    if player:points()==0 then
	gameover = true
	winner = ai.name
    elseif ai:points()==0 then 
	gameover = true
	winner = player.name
    end
  end
end

function love.mousepressed(x, y, button, isTouch)
  if pause or gameover then
    return
  end
  if button == 1 then
    local cx = (x - screen.cx)/scale
    local cy = (y - screen.cy)/scale
    if player.selected~= nil then
      cx = cx +player.selected.position.x
      cy = cy + player.selected.position.y
    end
    for _,p in pairs(player.bodies) do
      if p~=nil and p ~= player.selected and p.points>0 and p:clicked(cx,cy) then
        if player.selected ~= nil then
          player.selected.selected = false
        end
        p.selected = true
        player.selected = p
        return
      end
    end
    if player.selected~=nil and player.selected.rockets>0 then
      player.launching.status = true
      player.launching.x = (x - screen.cx)
      player.launching.y =  (y - screen.cy)
    end
  elseif button == 2 and   player.launching.status then
    player.launching.status = false
  end
end

function love.mousemoved(x, y, dx, dy)
  if pause or gameover then
    return
  end
  if player.launching.status then
    player.launching.x = (x-screen.cx)
    player.launching.y = (y-screen.cy)
  end
end

function love.mousereleased(x, y, button, isTouch)
  if pause or gameover then
    return
  end
  if button == 1 and player.launching.status and player.selected~=nil then
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
    if scale > 1/32 then
      scale = scale/2
    end
  elseif key == 'escape' then
    pause = not pause
    if pause then
      player.launching.status =false
    end
  end
  
end

function love.keyreleased(key)
end
