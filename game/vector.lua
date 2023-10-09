Vector = {}
Vector.__index = Vector

function Vector:create(x, y)
    local vector = {}
    setmetatable(vector, Vector)

    vector.x = x
    vector.y = y

    return vector
end

function Vector:random(minx, maxx, miny, maxy)
    local x = love.math.random(minx, maxx)
    local y = love.math.random(miny, maxy)
    return Vector:create(x, y)
end

function Vector:__tostring()
    return 'Vector(x = ' .. self.x .. ', y = ' .. self.y .. ')'
end

function Vector:__add(other)
    return Vector:create(self.x + other.x, self.y + other.y)
end

function Vector:__sub(other)
    return Vector:create(self.x - other.x, self.y - other.y)
end

function Vector:__mul(value)
    return Vector:create(self.x * value, self.y * value)
end

function Vector:__div(value)
    return Vector:create(self.x / value, self.y / value)
end

function Vector:mag()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vector:norm()
    local mag = self:mag()
    if mag > 0 then
        return self / mag
    end
end

function Vector:limit(max)
    if self:mag() > max then
        local norm = self:norm()
        return norm * max
    end
    return self
end

function Vector:add(other)
    self.x = self.x + other.x
    self.y = self.y + other.y
end

function Vector:sub(other)
    self.x = self.x - other.x
    self.y = self.y - other.y
end

function Vector:mul(value)
    self.x = self.x * value
    self.y = self.y * value
end

function Vector:div(value)
    self.x = self.x / value
    self.y = self.y / value
end

function Vector:reflect(angle)
    local mag = self:mag()
    local sin = mag * math.sin(angle)
    local cos = mag * math.cos(angle)
    return Vector:create(self.x > 0 and -cos or cos, self.y > 0 and sin or -sin)
end
