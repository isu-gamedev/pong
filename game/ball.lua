Ball = {}
Ball.__index = Ball

setmetatable(Ball, Mover)

function Ball:create(position, speed, radius, miny, maxy, footprintCount)
    local ball = Mover:create(position, Vector:create(speed, 0))
    setmetatable(ball, Ball)

    ball.speed = speed
    ball.radius = radius
    ball.miny = miny
    ball.maxy = maxy

    ball.footprints = {}
    ball.footprintCount = footprintCount
    ball.footprintTimeout = ball.radius / ball.speed * 2.5
    ball.footprintTimeoutLeft = ball.footprintTimeout

    return ball
end

function Ball:draw()
    love.graphics.circle('fill', self.position.x, self.position.y, self.radius)
    self:drawFootprints()
end

function Ball:drawFootprints()
    love.graphics.setColor(255, 255, 255)

    for idx, fp in pairs(self.footprints) do
        local alpha = 255 - (#self.footprints - idx) * 20
        love.graphics.setColor(255, 255, 255, alpha / 255)
        love.graphics.circle('line', fp.x, fp.y, self.radius)
    end

    love.graphics.setColor(255, 255, 255)
end

function Ball:update(dt, leftPaddle, rightPaddle)
    local force = self.velocity * dt
    local paddle = force.x < 0 and leftPaddle or rightPaddle

    self:intersectPaddle(paddle, force)
    self:addFootprint(dt)
    self:applyForce(force)
    self:checkBounds()
end

function Ball:intersectPaddle(paddle, force)
    local intersectionPoint = Utils.ballIntersect(self, paddle, force)

    if intersectionPoint ~= nil then
        if intersectionPoint.direction == 'left' or intersectionPoint.direction == 'right' then
            -- local bounceAngle = math.rad(60 * (2 * (self.position.y - paddle.position.y) / paddle.height - 1))
            -- self.velocity.y = self.velocity:mag() * math.sin(bounceAngle)
            self.velocity.x = -self.velocity.x
            force.x = -force.x
        elseif intersectionPoint.direction == 'top' or intersectionPoint.direction == 'bottom' then
            self.velocity.y = -self.velocity.y
            force.y = -force.y
        end
    end
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
    local upperBound = self.maxy - self.radius
    local bottomBound = self.miny + self.radius

    if self.position.y >= upperBound then
        self.position.y = upperBound
        self.velocity.y = -self.velocity.y
    elseif self.position.y <= bottomBound then
        self.position.y = bottomBound
        self.velocity.y = -self.velocity.y
    end
end
