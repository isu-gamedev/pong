Paddle = {}
Paddle.__index = Paddle

setmetatable(Paddle, Mover)

PaddleDirection = {
    UP = 1,
    DOWN = 2
}

function Paddle:create(position, speed, width, height, minY, maxY)
    local paddle = Mover:create(position, Vector:create(0, speed))
    setmetatable(paddle, Paddle)

    paddle.width = width
    paddle.height = height
    paddle.minY = minY
    paddle.maxY = maxY
    paddle.direction = nil

    return paddle
end

function Paddle:draw()
    love.graphics.rectangle('fill', self.position.x, self.position.y, self.width, self.height)
end

function Paddle:update(dt)
    if self.direction == PaddleDirection.UP then
        self:applyForce(self.velocity * -dt)
    elseif self.direction == PaddleDirection.DOWN then
        self:applyForce(self.velocity * dt)
    end

    self:checkBounds()
end

function Paddle:isMoving()
    return self.direction == PaddleDirection.UP or self.direction == PaddleDirection.DOWN
end

function Paddle:moveUp()
    self.direction = PaddleDirection.UP
end

function Paddle:moveDown()
    self.direction = PaddleDirection.DOWN
end

function Paddle:stop()
    self.direction = nil
end

function Paddle:checkBounds()
    local upperBound = self.maxY - self.height
    local bottomBound = self.minY

    if self.position.y >= upperBound then
        self.position.y = upperBound
    elseif self.position.y <= bottomBound then
        self.position.y = bottomBound
    end
end

function Paddle:bbox()
    return {
        top = self.position.y,
        right = self.position.x + self.width,
        bottom = self.position.y + self.height,
        left = self.position.x
    }
end
