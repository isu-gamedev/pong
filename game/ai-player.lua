AiPlayer = {}
AiPlayer.__index = AiPlayer

setmetatable(AiPlayer, Player)

local difficultyLevels = {{
    reactionTimeout = 2,
    hitError = 0.4
}, {
    reactionTimeout = 1.5,
    hitError = 0.2
}, {
    reactionTimeout = 0,
    hitError = 0
}}

function AiPlayer:create(paddle, difficultyLevel)
    local player = Player:create(paddle)
    setmetatable(player, AiPlayer)

    player.difficulty = difficultyLevels[difficultyLevel]
    player.prediction = nil
    player.predictionSince = 0

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

    local needToPredict = self.predictionSince > self.difficulty.reactionTimeout and
                              (not self.prediction or self.prediction.norm.x * ballVelocityNorm.x < 0 or self.prediction.norm.y * ballVelocityNorm.y < 0)

    if not needToPredict then
        self.predictionSince = self.predictionSince + dt
    else
        local point = Utils.ballIntersect(ball, {
            left = bbox.left,
            right = bbox.right,
            top = -10000,
            bottom = 10000
        }, ball.velocity)

        if point then
            local upperBound = height + bbox.height - ball.radius
            local lowerBound = ball.radius

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
            local centerOffsetWithError = centerOffset + centerOffset * self.difficulty.hitError

            self.prediction.norm = ballVelocityNorm
            self.prediction.y = self.prediction.y + centerOffsetWithError
            self.predictionSince = 0
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
    else
        self:moveToCenter()
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
