Game = {}
Game.__index = Game

GameConfig = {
    Defaults = {
        paddleWidth = 20,
        paddleHeight = 100,
        paddleSpeed = 500,
        ballRadius = 10,
        ballFootprintCount = 20,
        ballSpeed = 300,
        firstHitMultiplier = 2,
        strikeAngle = 60
    }
}

PlayerType = {
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
    game.attacker = nil

    local ballPosition = self:getInitialBallPosition()
    local ballVelocity = self:getInitialBallVelocity()

    game.ball = Ball:create(ballPosition, ballVelocity, GameConfig.Defaults.ballRadius, GameConfig.Defaults.ballFootprintCount)

    game.firstHit = false

    return game
end

function Game:getInitialBallPosition(lastScorer)
    lastScorer = lastScorer or nil

    local x = 0 - GameConfig.Defaults.ballRadius
    local y = love.math.random(height / 6, height - height / 6)

    if lastScorer == PlayerType.RIGHT then
        x = width + GameConfig.Defaults.ballRadius
    end

    return Vector:create(x, y)
end

function Game:getInitialBallVelocity(lastScorer)
    lastScorer = lastScorer or nil

    local direction = 1
    if lastScorer == PlayerType.RIGHT then
        direction = -1
    end

    local startSpeed = GameConfig.Defaults.ballSpeed
    local strikeAngle = GameConfig.Defaults.strikeAngle
    local angle = love.math.random(strikeAngle / 4, strikeAngle)

    return Vector:create(direction * startSpeed * math.cos(math.rad(angle)), startSpeed * math.sin(math.rad(angle)))
end

function Game:draw()
    self.leftPlayer.paddle:draw()
    self.rightPlayer.paddle:draw()
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
    self.leftPlayer.paddle:update(dt)
    self.rightPlayer.paddle:update(dt)

    self:checkBallColissions(dt)

    self.ball:update(dt)

    self:checkGoal()
end

function Game:keypressed(key)
    if key == 'w' then
        self.leftPlayer.paddle:moveUp()
    elseif key == 's' then
        self.leftPlayer.paddle:moveDown()
    elseif key == 'up' then
        self.rightPlayer.paddle:moveUp()
    elseif key == 'down' then
        self.rightPlayer.paddle:moveDown()
    end
end

function Game:keyreleased(key)
    self.leftPlayer.paddle:stop()
    self.rightPlayer.paddle:stop()
end

function Game:checkBallColissions(dt)
    local ballDirection = self.ball:getDirection()

    local paddle = ballDirection == BallDirection.LEFT and self.leftPlayer.paddle or self.rightPlayer.paddle
    local paddleBbox = paddle:bbox()

    local point = Utils.ballIntersect(self.ball, paddleBbox, self.ball.velocity * dt)

    if point ~= nil then
        if point.direction == IntersectionDirection.LEFT or point.direction == IntersectionDirection.RIGHT then
            local center = paddle:bbox().top + paddle.height / 2
            local offset = math.abs((point.y - center) / (paddle.height / 2) * GameConfig.Defaults.strikeAngle)
            local angle = math.rad(offset)
            -- local angle = math.rad(GameConfig.Defaults.strikeAngle * (2 * (point.y - paddle:bbox().top) / paddle.height - 1))
            self.ball:horizontalBounce(angle)
        elseif point.direction == IntersectionDirection.TOP or point.direction == IntersectionDirection.BOTTOM then
            self.ball:verticalBounce()
        end

        if not self.firstHit then
            self.ball.velocity:mul(GameConfig.Defaults.firstHitMultiplier)
            self.firstHit = true
        end
    end

    self.attacker = ballDirection == BallDirection.LEFT and PlayerType.RIGHT or PlayerType.LEFT
end

function Game:checkGoal()
    if self.ball:isOutOfBounds() then
        local lastScorer = nil

        if self.attacker == PlayerType.RIGHT then
            lastScorer = PlayerType.RIGHT
            self.rightPlayer:goal()
        elseif self.attacker == PlayerType.LEFT then
            lastScorer = PlayerType.LEFT
            self.leftPlayer:goal()
        end

        self.ball.position = self:getInitialBallPosition(lastScorer)
        self.ball.velocity = self:getInitialBallVelocity(lastScorer)

        self.attacker = nil
        self.firstHit = false
    end
end
