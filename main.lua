require("utils")
require("game")
require("menu")
require("enum")
require("help")

PBGame = {
  screen = {
    w = 0,
    h = 0,
    cx = 0,
    cy = 0
  },

  status = enum({ "menu", "game", "help" }),
  bigFont = love.graphics.newFont("whitrabt.ttf", 18),
  smallFont = love.graphics.newFont("whitrabt.ttf", 16),
  game = nil,
  help = nil,
  menu = nil,
  inGame = nil,
}

function love.load()
  math.randomseed(os.time())
  love.window.setTitle("Orbital Ballistics")

  PBGame.screen.w = love.graphics.getWidth()
  PBGame.screen.h = love.graphics.getHeight()
  PBGame.screen.cx = PBGame.screen.w / 2
  PBGame.screen.cy = PBGame.screen.h / 2
  PBGame.menu = Menu.new()
  PBGame.help = Help.new({ { "ESC", "Pause game" }, { "TAB", "Change planet" }, { "I", "Zoom In" }, { "O", "Zoom Out" } })
  PBGame.game = Game.new("Player", 2, 3, true)
  PBGame.inGame = PBGame.status.menu
end

function love.draw()
  if PBGame.inGame == PBGame.status.game then
    PBGame.game:draw()
  elseif PBGame.inGame == PBGame.status.menu then
    PBGame.menu:draw()
  elseif PBGame.inGame == PBGame.status.help then
    PBGame.help:draw()
  end
end

function love.update(dt)
  if PBGame.inGame == PBGame.status.game then
    PBGame.game:update(dt)
  elseif PBGame.inGame == PBGame.status.menu then
    PBGame.menu:update(dt)
  end
end

function love.mousepressed(x, y, button, _)
  if PBGame.inGame == PBGame.status.game then
    PBGame.game:mousepressed(x, y, button)
  elseif PBGame.inGame == PBGame.status.menu then
    PBGame.menu:mousepressed(x, y, button)
  elseif PBGame.inGame == PBGame.status.help then
    PBGame.help:mousepressed(x, y, button)
  end
end

function love.mousemoved(x, y, _, _)
  if PBGame.inGame == PBGame.status.game then
    PBGame.game:mousemoved(x, y)
  end
end

function love.mousereleased(x, y, button, _)
  if PBGame.inGame == PBGame.status.game then
    PBGame.game:mousereleased(x, y, button)
  end
end

function love.keypressed(key, _, _)
  if PBGame.inGame == PBGame.status.game then
    PBGame.game:keypressed(key)
  elseif PBGame.inGame == PBGame.status.menu then
    PBGame.menu:keypressed(key)
  elseif PBGame.inGame == PBGame.status.help then
    PBGame.help:keypressed(key)
  end
end

function love.keyreleased(_)
end
