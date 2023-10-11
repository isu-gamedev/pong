AiPlayer = {}
AiPlayer.__index = AiPlayer

setmetatable(AiPlayer, Player)

function AiPlayer:create(paddle)
    local player = Player:create(paddle)
    setmetatable(player, AiPlayer)

    player.prediction = nil

    return player
end

function AiPlayer:update(dt, ball)
    if self:isBallComming(ball) then
        self:predict(ball, dt)
    else
        self.prediction = nil
        self:moveToCenter()
    end
    Player.update(self, dt)
end

function AiPlayer:isBallComming(ball)
    local bbox = self:getBBox()
    return not (ball.position.x < bbox.left and ball:isMovingLeft()) and not (ball.position.x > bbox.right and ball:isMovingRight())
end

function AiPlayer:predict(ball, dt)
    local ballVelocityNorm = ball.velocity:norm()
    local bbox = self:getBBox()

    local needToPredict = not (self.prediction and self.prediction.dx * ballVelocityNorm.x > 0 and self.prediction.dy * ballVelocityNorm.y > 0)

    if needToPredict then
        local point = Utils.ballIntersect(ball, {
            left = bbox.left,
            right = bbox.right,
            top = -10000,
            bottom = 10000
        }, ball.velocity)

        if point then
            local upperBound = height + bbox.height - ball.radius
            local lowerBound = 0 + ball.radius

            while point.y < lowerBound or point.y > upperBound do
                if point.y < lowerBound then
                    point.y = lowerBound + (lowerBound - point.y)
                elseif point.y > upperBound then
                    point.y = lowerBound + (upperBound - lowerBound) - (point.y - upperBound)
                end
            end
            self.prediction = point
        else
            self.prediction = nil
        end

        if self.prediction then
            local centerOffset = love.math.random(-bbox.height / 2, bbox.height / 2)

            self.prediction.dx = ballVelocityNorm.x
            self.prediction.dy = ballVelocityNorm.y
            self.prediction.y = self.prediction.y + centerOffset
        end
    end

    if self.prediction then
        if self.prediction.y < bbox.center - 5 then
            self:moveUp()
        elseif self.prediction.y > bbox.center + 5 then
            self:moveDown()
        else
            self:stop()
        end
    end
end

function AiPlayer:moveToCenter()
    local centerY = height / 2
    local bbox = self:getBBox()

    if bbox.center < centerY - 5 then
        self.paddle:moveDown()
    elseif bbox.center > centerY + 5 then
        self.paddle:moveUp()
    else
        self:stop()
    end
end
