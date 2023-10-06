local Paddle = {}
Paddle.__index = Paddle

local PaddleDirection = {
    UP = 1,
    DOWN = 2
}

Paddle.width = 10
Paddle.height = 80
Paddle.speed = 300

function Paddle:create(x, y)
    local self = {}
    setmetatable(self, Paddle)
    self.width = Paddle.width
    self.height = Paddle.height
    self.speed = Paddle.speed
    self.location = Vector:create(x, y)
    self.direction = nil
    return self
end

function Paddle:draw()
    love.graphics.rectangle('fill', self.location.x, self.location.y, self.width, self.height)
end

function Paddle:update(dt)
    self:move(dt)
    self:checkBounds()
end

function Paddle:move(dt)
    -- HINT: Делаю без Vector:add, так как легче залезть внутрь, чем создавать инстанс вектора для изменения одного поля
    if self.direction == PaddleDirection.UP then
        self.location.y = self.location.y - self.speed * dt
    elseif self.direction == PaddleDirection.DOWN then
        self.location.y = self.location.y + self.speed * dt
    end
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

return {
    Paddle = Paddle,
    PaddleDirection = PaddleDirection
}
