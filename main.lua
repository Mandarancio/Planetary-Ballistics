
require("utils")
require("game")
require("menu")
require("enum")
require("help")

screen ={
  w=0,
  h=0,
  cx = 0,
  cy = 0
}

status = enum({"menu", "game", "help"})
bigFont = love.graphics.newFont("whitrabt.ttf",18)
smallFont = love.graphics.newFont("whitrabt.ttf",16)
game = nil
help = nil
menu = nil
in_game = status.menu

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
  help = Help.new({{"ESC", "Pause game"}, {"TAB","Change planet"}, {"I", "Zoom In"}, {"O", "Zoom Out"}})
--  game = Game.new("Player",2,3,true)
end



function love.draw()
  if in_game == status.game then
    game:draw()
  elseif in_game == status.menu then
    menu:draw()
  elseif in_game == status.help then
    help:draw()
  end
end

function love.update(dt)
  if in_game == status.game then
    game:update(dt)
  elseif in_game == status.menu then
    menu:update(dt)
  end
end

function love.mousepressed(x, y, button, isTouch)
  if in_game == status.game then
    game:mousepressed(x, y, button)
  elseif in_game == status.menu then
    menu:mousepressed(x, y, button)
  elseif in_game == status.help then
    help:mousepressed(x, y, button)
  end
end

function love.mousemoved(x, y, dx, dy)
  if in_game == status.game then
    game:mousemoved(x,y)
  end
end

function love.mousereleased(x, y, button, isTouch)
  if in_game == status.game then
    game:mousereleased(x,y, button)
  end
end

function love.keypressed(key, scancode, isrepeat)
  if in_game == status.game then
    game:keypressed(key)
  elseif in_game == status.menu then
    menu:keypressed(key)
  elseif in_game == status.help then
    help:keypressed(key)
  end
end

function love.keyreleased(key)
end
