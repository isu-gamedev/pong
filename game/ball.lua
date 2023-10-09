Ball = {}
Ball.__index = Ball

BallDirection = {
    LEFT = 1,
    RIGHT = 2
}

setmetatable(Ball, Mover)

function Ball:create(position, velocity, radius, footprintCount)
    local ball = Mover:create(position, Vector:create(velocity, 0))
    setmetatable(ball, Ball)

    ball.velocity = velocity
    ball.radius = radius

    ball.footprints = {}
    ball.footprintCount = footprintCount
    ball.footprintTimeout = ball.radius / ball.velocity:mag() * 3
    ball.footprintTimeoutLeft = ball.footprintTimeout

    return ball
end

function Ball:draw()
    love.graphics.circle('fill', self.position.x, self.position.y, self.radius)
    self:drawFootprints()
end

function Ball:update(dt)
    self:addFootprint(dt)
    self:applyForce(self.velocity * dt)
    self:checkBounds()
end

function Ball:drawFootprints()
    love.graphics.setColor(255, 255, 255)

    for i, v in pairs(self.footprints) do
        local alpha = 255 - (#self.footprints - i) * 20
        love.graphics.setColor(255, 255, 255, alpha / 255)
        love.graphics.circle('line', v.x, v.y, self.radius)
    end

    love.graphics.setColor(255, 255, 255)
end

function Ball:addFootprint(dt)
    self.footprintTimeoutLeft = self.footprintTimeoutLeft - dt

    if self.footprintTimeoutLeft <= 0 then
        table.insert(self.footprints, {
            x = self.position.x,
            y = self.position.y
        })
        self.footprintTimeoutLeft = self.footprintTimeout
    end

    while #self.footprints > self.footprintCount do
        table.remove(self.footprints, 1)
    end
end

function Ball:checkBounds()
    local upperBound = height - self.radius
    local bottomBound = self.radius

    if self.position.y >= upperBound then
        self.position.y = upperBound
        self.velocity.y = -self.velocity.y
    elseif self.position.y <= bottomBound then
        self.position.y = bottomBound
        self.velocity.y = -self.velocity.y
    end
end

function Ball:horizontalBounce(angle)
    local mag = self.velocity:mag()
    -- self.velocity.y = mag * math.sin(angle)
    self.velocity.y = self.velocity.y > 0 and mag * math.sin(angle) or -mag * math.sin(angle)
    self.velocity.x = self.velocity.x > 0 and -mag * math.cos(angle) or mag * math.cos(angle)
end

function Ball:verticalBounce()
    self.velocity.y = -self.velocity.y
end

function Ball:getDirection()
    return self.velocity.x < 0 and BallDirection.LEFT or BallDirection.RIGHT
end

function Ball:isOutOfBounds()
    return self.position.x - self.radius >= width or self.position.x + self.radius <= 0
end
