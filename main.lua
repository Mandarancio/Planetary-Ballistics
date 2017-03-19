
require("vec2d")
require("bodies")
require("player")
require("phys")
require("utils")
require("game")

screen ={
  w=0,
  h=0,
  cx = 0,
  cy = 0
}


bigFont = love.graphics.newFont("whitrabt.ttf",18)
smallFont = love.graphics.newFont("whitrabt.ttf",16)
game= nil

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
  game = Game.new("Player",2,3,true)
end



function love.draw()
  game:draw()
end

function love.update(dt)
  game:update(dt)
end

function love.mousepressed(x, y, button, isTouch)
  game:mousepressed(x,y, button)
end

function love.mousemoved(x, y, dx, dy)
  game:mousemoved(x,y)
end

function love.mousereleased(x, y, button, isTouch)
  game:mousereleased(x,y, button)
end

function love.keypressed(key, scancode, isrepeat)
  game:keypressed(key)
end

function love.keyreleased(key)
end
