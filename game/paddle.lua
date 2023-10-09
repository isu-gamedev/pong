Paddle = {}
Paddle.__index = Paddle

setmetatable(Paddle, Mover)

function Paddle:create(position, speed, width, height)
    local paddle = Mover:create(position, Vector:create(0, speed))
    setmetatable(paddle, Paddle)

    paddle.width = width
    paddle.height = height
    paddle.up = false
    paddle.down = false

    return paddle
end

function Paddle:draw()
    love.graphics.rectangle('fill', self.position.x, self.position.y, self.width, self.height)
end

function Paddle:update(dt)
    if self.up then
        self:applyForce(self.velocity * -dt)
    elseif self.down then
        self:applyForce(self.velocity * dt)
    end

    self:checkBounds()
end

function Paddle:isMoving()
    return self.up or self.down
end

function Paddle:moveUp()
    self.up = true
    self.down = false
end

function Paddle:moveDown()
    self.up = false
    self.down = true
end

function Paddle:stop()
    self.up = false
    self.down = false
end

function Paddle:checkBounds()
    local upperBound = height - self.height
    local bottomBound = 0

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
