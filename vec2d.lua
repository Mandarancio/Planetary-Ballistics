Vec2D = {}
Vec2D.__index = Vec2D

function Vec2D.create(x,y)
  local v = {}
  setmetatable(v,Vec2D)
  v.x = x
  v.y = y
  return v
end

function Vec2D.null()
  local v = {}
  setmetatable(v,Vec2D)
  v.x=0
  v.y=0
  return v
end

function Vec2D.n(x,y)
  return Vec2D.create(x,y)
end


function Vec2D:mod()
  return math.sqrt(self.x*self.x + self.y*self.y)
end

function Vec2D:mod2()
  return self.x*self.x + self.y*self.y
end

function Vec2D.__add(lhs, rhs)
  return Vec2D.create(lhs.x+rhs.x,lhs.y+rhs.y)
end

function Vec2D.__sub(lhs,rhs)
  return Vec2D.create(lhs.x-rhs.x,lhs.y-rhs.y)
end

function Vec2D.__mul(lhs,rhs)
  if getmetatable(lhs) == Vec2D then
    return Vec2D.create(lhs.x*rhs,lhs.y*rhs)
  elseif getmetatable(rhs) == Vec2D then
    return Vec2D.create(lhs*rhs.x, lhs*rhs.y)
  else
    return lhs.x*rhs.x + lhs.y*rhs.y
  end
end

function Vec2D.__div(lhs,rhs)
  if getmetatable(lhs) == Vec2D then
    return Vec2D.create(lhs.x/rhs,lhs.y/rhs)
  elseif getmetatable(rhs) == Vec2D then
    return Vec2D.create(lhs/rhs.x, lhs/rhs.y)
  end
end
