Paddle = {}
Paddle.__index = Paddle

setmetatable(Paddle, Mover)

PaddleDirection = {
    UP = 1,
    DOWN = 2
}

function Paddle:create(location, velocity, width, height)
    local paddle = Mover:create(location, velocity)
    setmetatable(paddle, Paddle)

    paddle.width = width
    paddle.height = height
    paddle.direction = nil

    return paddle
end

function Paddle:draw()
    love.graphics.rectangle('fill', self.location.x, self.location.y, self.width, self.height)
end

function Paddle:update(dt)
    self:move(dt)
    self:checkBounds()
end

function Paddle:move(dt)
    if self.direction == PaddleDirection.UP then
        self:applyForce(self.velocity * dt * -1)
    elseif self.direction == PaddleDirection.DOWN then
        self:applyForce(self.velocity * dt)
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

function Paddle:bbox()
    local top = self.location.y
    local right = self.location.x + self.width
    local bottom = self.location.y + self.height
    local left = self.location.x
    return {
        top = top,
        right = right,
        bottom = bottom,
        left = left
    }
end
