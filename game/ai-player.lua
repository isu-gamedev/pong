AiPlayer = {}
AiPlayer.__index = AiPlayer

setmetatable(AiPlayer, Player)

function AiPlayer:create(paddle, ballX)
    local player = Player:create(paddle)
    setmetatable(player, AiPlayer)

    player.ballXDiff = ballX

    return player
end

function AiPlayer:update(dt, ball)
    if self:isBallComing(ball) then
        self:goToBall(ball)
    else
        self:goToCenter()
    end

    Player.update(self, dt)
end

function AiPlayer:isBallComing(ball)
    local ballDirection = ball:getDirection()
    local paddleBBox = self.paddle:getBBox()

    local newBallXDiff = self.ballXDiff
    if ballDirection == BallDirection.RIGHT then
        newBallXDiff = math.abs(paddleBBox.right - ball.position.x)
    elseif ballDirection == BallDirection.LEFT then
        newBallXDiff = math.abs(ball.position.x - paddleBBox.left)
    end

    local isComing = false
    if self.ballXDiff > newBallXDiff then
        isComing = true
    end

    self.ballXDiff = newBallXDiff

    return isComing
end

function AiPlayer:goToBall(ball)
    local paddleBBox = self.paddle:getBBox()
    local verticalOffset = ball.position.y - paddleBBox.center

    local randomVerticalOffset = love.math.random(-50, 50)
    verticalOffset = verticalOffset + randomVerticalOffset

    if verticalOffset > 0 then
        self.paddle:moveDown()
    elseif verticalOffset < 0 then
        self.paddle:moveUp()
    else
        self.paddle:stop()
    end
end

function AiPlayer:goToCenter()
    local centerY = height / 2
    local paddleBBox = self.paddle:getBBox()

    if paddleBBox.center < centerY then
        self.paddle:moveDown()
    elseif paddleBBox.center > centerY then
        self.paddle:moveUp()
    else
        self:stop()
    end
end
