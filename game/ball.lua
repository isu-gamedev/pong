Ball = {}
Ball.__index = Ball

setmetatable(Ball, Mover)

function Ball:create(position, velocity, radius, footprintCount, image, minY)
    local ball = Mover:create(position, velocity)
    setmetatable(ball, Ball)

    local footprintTimeout = radius / velocity:mag() * 3
    local diameter = radius * 2

    ball.radius = radius
    ball.footprints = {}
    ball.footprintCount = footprintCount
    ball.footprintTimeout = footprintTimeout
    ball.footprintSince = footprintTimeout
    ball.image = image
    ball.imageScale = {
        x = diameter / image:getHeight(),
        y = diameter / image:getHeight()
    }
    ball.minY = minY

    return ball
end

function Ball:draw()
    if GlobalConfig.__DEV__ then
        self:drawHitbox()
    end

    self:drawImage()
    self:drawFootprints()
end

function Ball:update(dt)
    self:addFootprint(dt)
    self:applyForce(self.velocity * dt)
    self:checkBounds()
end

function Ball:drawHitbox()
    love.graphics.circle('line', self.position.x, self.position.y, self.radius)
end

function Ball:drawImage(position)
    position = position or self.position

    local rotation = (2 * math.pi) * love.timer.getTime()

    love.graphics.push()
    love.graphics.translate(position.x, position.y)
    love.graphics.rotate(rotation)
    love.graphics.draw(self.image, -self.radius, -self.radius, 0, self.imageScale.x, self.imageScale.y)
    love.graphics.pop()
end

function Ball:drawFootprints()

    if not (self.footprintCount == 0) then
        local r, g, b, a = love.graphics.getColor()
        for i, v in pairs(self.footprints) do
            local alpha = 255 - (#self.footprints - i) * 10
            love.graphics.setColor(r, g, b, alpha / 255)
            self:drawImage(v)
        end
        love.graphics.setColor(r, g, b, a)
    end
end

function Ball:addFootprint(dt)
    self.footprintSince = self.footprintSince - dt
    if self.footprintSince <= 0 then
        table.insert(self.footprints, {
            x = self.position.x,
            y = self.position.y
        })
        self.footprintSince = self.footprintTimeout
    end

    while #self.footprints > self.footprintCount do
        table.remove(self.footprints, 1)
    end
end

function Ball:checkBounds()
    local upperBound = height - self.radius
    local lowerBound = self.minY + self.radius

    if self.position.y >= upperBound or self.position.y <= lowerBound then
        self.velocity.y = -self.velocity.y
    end
    self.position.y = math.min(upperBound, math.max(lowerBound, self.position.y))
end

function Ball:horizontalBounce(angle)
    self.velocity = self.velocity:reflect(angle)
end

function Ball:verticalBounce()
    self.velocity.y = -self.velocity.y
end

function Ball:isMovingRight()
    return self.velocity.x > 0
end

function Ball:isMovingLeft()
    return self.velocity.x < 0
end

function Ball:isOutOfBounds()
    return self.position.x - self.radius >= width or self.position.x + self.radius <= 0
end

