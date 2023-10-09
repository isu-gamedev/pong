Game = {}
Game.__index = Game

GameConfig = {
    Defaults = {
        paddleWidth = 20,
        paddleHeight = 100,
        paddleSpeed = 500,

        ballRadius = 10,
        ballSpeed = 300,
        ballFirstHitMultiplier = 2,
        ballBounceAngle = 45,
        ballFootprintCount = 20
    }
}

PlayerSide = {
    LEFT = 1,
    RIGHT = 2
}

function Game:create()
    local game = {}
    setmetatable(game, Game)

    local paddleX = 0
    local paddleY = height / 2 - GameConfig.Defaults.paddleHeight / 2
    local leftPaddle = Paddle:create(Vector:create(paddleX, paddleY), GameConfig.Defaults.paddleSpeed, GameConfig.Defaults.paddleWidth,
        GameConfig.Defaults.paddleHeight)
    local rightPaddle = Paddle:create(Vector:create(width - paddleX - GameConfig.Defaults.paddleWidth, paddleY),
        GameConfig.Defaults.paddleSpeed, GameConfig.Defaults.paddleWidth, GameConfig.Defaults.paddleHeight)

    game.leftPlayer = Player:create(leftPaddle)
    game.rightPlayer = Player:create(rightPaddle)

    local ballPosition = self:getInitialBallPosition()
    local ballVelocity = self:getInitialBallVelocity()

    game.ball = Ball:create(ballPosition, ballVelocity, GameConfig.Defaults.ballRadius, GameConfig.Defaults.ballFootprintCount)

    game.firstHit = false

    return game
end

function Game:getInitialBallPosition(lastScorerSide)
    lastScorerSide = lastScorerSide or nil

    local x = 0 - GameConfig.Defaults.ballRadius
    local y = love.math.random(height / 6, height - height / 6)
    if lastScorerSide == PlayerSide.RIGHT then
        x = width + GameConfig.Defaults.ballRadius
    end

    return Vector:create(x, y)
end

function Game:getInitialBallVelocity(lastScorerSide)
    lastScorerSide = lastScorerSide or nil

    local direction = 1
    if lastScorerSide == PlayerSide.RIGHT then
        direction = -1
    end

    local startSpeed = GameConfig.Defaults.ballSpeed
    local bounceAngle = GameConfig.Defaults.ballBounceAngle
    local angle = love.math.random(bounceAngle / 4, bounceAngle)

    return Vector:create(direction * startSpeed * math.cos(math.rad(angle)), startSpeed * math.sin(math.rad(angle)))
end

function Game:draw()
    self.leftPlayer:draw()
    self.rightPlayer:draw()
    self.ball:draw()
    self:drawScore()
end

function Game:drawScore()
    local scoreText = string.format('%d:%d', self.leftPlayer.score, self.rightPlayer.score)
    local font = love.graphics.newFont(52)
    local scoreWidth = font:getWidth(scoreText)

    love.graphics.setFont(font)
    love.graphics.print(scoreText, width / 2 - scoreWidth / 2, 20)
end

function Game:update(dt)
    self.leftPlayer:update(dt)
    self.rightPlayer:update(dt)

    self:checkBallCollisions(dt)
    self.ball:update(dt)

    self:checkGoal()
end

function Game:keypressed(key)
    if key == 'w' then
        self.leftPlayer:moveUp()
    elseif key == 's' then
        self.leftPlayer:moveDown()
    elseif key == 'up' then
        self.rightPlayer:moveUp()
    elseif key == 'down' then
        self.rightPlayer:moveDown()
    end
end

function Game:keyreleased(key)
    self.leftPlayer:stop()
    self.rightPlayer:stop()
end

function Game:checkBallCollisions(dt)
    self:checkBallAndPaddleCollision(dt)
end

function Game:checkBallAndPaddleCollision(dt)
    local ballDirection = self.ball:getDirection()
    local paddle = ballDirection == BallDirection.LEFT and self.leftPlayer.paddle or self.rightPlayer.paddle
    local paddleBBox = paddle:getBBox()

    local point = Utils.ballIntersect(self.ball, paddleBBox, self.ball.velocity * dt)

    if point ~= nil then
        if point.direction == IntersectionDirection.LEFT or point.direction == IntersectionDirection.RIGHT then
            local paddleCenter = paddleBBox.top + paddleBBox.height / 2
            local centerOffset = math.abs((point.y - paddleCenter) / (paddleBBox.height / 2) * GameConfig.Defaults.ballBounceAngle)
            local bounceAngle = math.rad(centerOffset)
            -- -- local angle = math.rad(GameConfig.Defaults.bounceAngle * (2 * (point.y - paddle:bbox().top) / paddle.height - 1))
            self.ball:horizontalBounce(bounceAngle)
        elseif point.direction == IntersectionDirection.TOP or point.direction == IntersectionDirection.BOTTOM then
            self.ball:verticalBounce()
        end

        if not self.firstHit then
            self.ball.velocity:mul(GameConfig.Defaults.ballFirstHitMultiplier)
            self.firstHit = true
        end
    end
end

function Game:checkGoal()
    if self.ball:isOutOfBounds() then
        local ballDirection = self.ball:getDirection()
        local lastScorerSide = nil

        if ballDirection == BallDirection.LEFT then
            lastScorerSide = PlayerSide.RIGHT
            self.rightPlayer:addScore()
        elseif ballDirection == BallDirection.RIGHT then
            lastScorerSide = PlayerSide.LEFT
            self.leftPlayer:addScore()
        end

        self.ball.position = self:getInitialBallPosition(lastScorerSide)
        self.ball.velocity = self:getInitialBallVelocity(lastScorerSide)

        self.firstHit = false
    end
end
