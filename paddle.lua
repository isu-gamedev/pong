local Paddle = {}
Paddle.__index = Paddle

local PaddleDirection = {
    UP = 1,
    DOWN = 2
}

local PaddleConfig = {
    width = 10,
    hegiht = 80,
    speed = 200
}

function Paddle:create(x, y)
    local self = {}
    setmetatable(self, Paddle)

    self.width = PaddleConfig.width
    self.height = PaddleConfig.hegiht
    self.speed = PaddleConfig.speed
    self.location = Vector:create(x, y - self.height / 2)
    self.direction = nil

    return self
end

function Paddle:draw()
    love.graphics.rectangle('fill', self.location.x, self.location.y, self.width, self.height)
end

function Paddle:update(dt)
    if self.direction == PaddleDirection.UP then
        self:move(-self.speed * dt)
    elseif self.direction == PaddleDirection.DOWN then
        self:move(self.speed * dt)
    end

    self:checkBounds()
end

function Paddle:move(dy)
    self.location:add(Vector:create(0, dy))
end

function Paddle:checkBounds()
    local upperBound = height - self.height
    local bottomBound = 0

    if self.location.y >= upperBound then
        self.location.y = upperBound
    elseif self.location.y <= bottomBound then
        self.location.y = bottomBound
    end
end

return Paddle
