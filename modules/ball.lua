Ball = {}
Ball.__index = Ball

setmetatable(Ball, Mover)

function Ball:create(location, velocity, size)
    local ball = Mover:create(location, velocity)
    setmetatable(ball, Ball)
    ball.size = size
    return ball
end

function Ball:draw()
    love.graphics.circle('fill', self.location.x, self.location.y, self.size)
end

function Ball:update(dt)
    self:applyForce(self.velocity * dt)
    self:checkBounds()
end

function Ball:checkBounds()
    if self.location.y + self.size > height then
        self.location.y = height - self.size
        self.velocity.y = -self.velocity.y
    elseif self.location.y - self.size < 0 then
        self.location.y = self.size
        self.velocity.y = -self.velocity.y
    end
end

function Ball:checkCollision(player)
    local bbox = self:bbox()
    local paddleBbox = player.paddle:bbox()

    -- if bbox.right <= paddleBbox.left or bbox.left >= paddleBbox.right or bbox.bottom <= paddleBbox.top or bbox.top >=
    --     paddleBbox.bottom then
    --     return false
    -- end

    -- self.velocity.x = -self.velocity.x

    return true
end

function Ball:bbox()
    local top = self.location.y - self.size
    local right = self.location.x + self.size
    local bottom = self.location.y + self.size
    local left = self.location.x - self.size
    return {
        top = top,
        right = right,
        bottom = bottom,
        left = left
    }
end
