Paddle = {}
Paddle.__index = Paddle

setmetatable(Paddle, Mover)

PaddleDirection = {
    UP = 1,
    DOWN = 2
}

function Paddle:create(position, speed, width, height)
    local paddle = Mover:create(position, Vector:create(0, speed))
    setmetatable(paddle, Paddle)

    paddle.width = width
    paddle.height = height
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

function Paddle:checkBounds()
    local upperBound = height - self.height
    local lowerBound = 0

    self.position.y = math.max(lowerBound, math.min(self.position.y, upperBound))
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

function Paddle:getBBox()
    return {
        top = self.position.y,
        right = self.position.x + self.width,
        bottom = self.position.y + self.height,
        left = self.position.x,
        width = self.width,
        height = self.height,
        center = self.position.y + self.height / 2
    }
end
