Help = {}
Help.__index = Help

function Help.new(help)
  local m = {}
  setmetatable(m,Help)
  m.help = help
  m.active = false
  return m
end

function Help:update(dt)
end

function Help:draw()

end

function Help:keypressed(key)
  if key == 'escape' then
    self.active = false
    in_game = status.menu
  end
end
