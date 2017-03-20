
require("utils")
require("game")
require("menu")

screen ={
  w=0,
  h=0,
  cx = 0,
  cy = 0
}


bigFont = love.graphics.newFont("whitrabt.ttf",18)
smallFont = love.graphics.newFont("whitrabt.ttf",16)
game = nil
menu = nil
in_game = false

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

  screen.w = love.graphics.getWidth()
  screen.h = love.graphics.getHeight()
  screen.cx = screen.w/2
  screen.cy = screen.h/2
  menu = Menu.new()
  game = Game.new("Player",2,3,true)
end



function love.draw()
  if in_game then
    game:draw()
  else
    menu:draw()
  end
end

function love.update(dt)
  if in_game then
    game:update(dt)
  else
    menu:update(dt)
  end
end

function love.mousepressed(x, y, button, isTouch)
  if in_game then
    game:mousepressed(x,y, button)
  else
    menu:mousepressed(x,y, button)
  end
end

function love.mousemoved(x, y, dx, dy)
  if in_game then
    game:mousemoved(x,y)
  end
end

function love.mousereleased(x, y, button, isTouch)
  if in_game then
    game:mousereleased(x,y, button)
  end
end

function love.keypressed(key, scancode, isrepeat)
  if in_game then
    game:keypressed(key)
  else
    menu:keypressed(key)
  end
end

function love.keyreleased(key)
end
