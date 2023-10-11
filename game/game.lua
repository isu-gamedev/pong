Game = {}
Game.__index = Game

GameConfig = {
    Defaults = {
        Paddle = {
            WIDTH = 10,
            HEIGHT = 80,
            SPEED = 500
        },
        Ball = {
            RADIUS = 8,
            SPEED = 300,
            FIRST_HIT_MULTIPLIER = 2,
            MAX_BOUNCE_ANGLE = 45,
            FOOTPRINT_COUNT = 20
        }
    },

    Controls = {
        Players = {
            Left = {
                UP = 'w',
                DOWN = 's'
            },
            Right = {
                UP = 'up',
                DOWN = 'down'
            }
        }
    }
}

PlayerSide = {
    LEFT = 1,
    RIGHT = 2
}

function Game:create(isPlayingVsAi)
    local game = {}
    setmetatable(game, Game)

    local paddleX = 0
    local paddleY = height / 2 - GameConfig.Defaults.Paddle.HEIGHT / 2

    local leftPaddle = Paddle:create(Vector:create(paddleX, paddleY), GameConfig.Defaults.Paddle.SPEED, GameConfig.Defaults.Paddle.WIDTH,
        GameConfig.Defaults.Paddle.HEIGHT)

    local rightPaddle = Paddle:create(Vector:create(width - paddleX - GameConfig.Defaults.Paddle.WIDTH, paddleY), GameConfig.Defaults.Paddle.SPEED,
        GameConfig.Defaults.Paddle.WIDTH, GameConfig.Defaults.Paddle.HEIGHT)

    game.leftPlayer = Player:create(leftPaddle)
    game.rightPlayer = isPlayingVsAi and AiPlayer:create(rightPaddle) or Player:create(rightPaddle)

    local ballPosition = self:getInitialBallPosition()
    local ballVelocity = self:getInitialBallVelocity()

    game.ball = Ball:create(ballPosition, ballVelocity, GameConfig.Defaults.Ball.RADIUS, GameConfig.Defaults.Ball.FOOTPRINT_COUNT)

    game.isPlayingVsAi = isPlayingVsAi
    game.isFirstHit = false

    return game
end

function Game:getInitialBallPosition(lastScorerSide)
    lastScorerSide = lastScorerSide or PlayerSide.LEFT

    local x = 0 - GameConfig.Defaults.Ball.RADIUS
    local y = love.math.random(height / 6, height - height / 6)

    if lastScorerSide == PlayerSide.RIGHT then
        x = width + GameConfig.Defaults.Ball.RADIUS
    end

    return Vector:create(x, y)
end

function Game:getInitialBallVelocity(lastScorerSide)
    lastScorerSide = lastScorerSide or PlayerSide.LEFT

    local direction = 1
    if lastScorerSide == PlayerSide.RIGHT then
        direction = -1
    end

    local ballSpeed = GameConfig.Defaults.Ball.SPEED
    local maxBounceAngle = GameConfig.Defaults.Ball.MAX_BOUNCE_ANGLE
    local bounceAngle = math.rad(love.math.random(maxBounceAngle / 4, maxBounceAngle))

    return Vector:create(direction * ballSpeed * math.cos(bounceAngle), ballSpeed * math.sin(bounceAngle))
end

function Game:draw()
    self.leftPlayer:draw()
    self.rightPlayer:draw()
    self.ball:draw()
    self:drawScore()
end

function Game:drawScore()
    local font = love.graphics.newFont(52)

    local scoreText = string.format('%d:%d', self.leftPlayer.score, self.rightPlayer.score)
    local scoreWidth = font:getWidth(scoreText)

    love.graphics.setFont(font)
    love.graphics.print(scoreText, width / 2 - scoreWidth / 2, 20)
end

function Game:update(dt)
    self.leftPlayer:update(dt)

    if self.isPlayingVsAi then
        self.rightPlayer:update(dt, self.ball)
    else
        self.rightPlayer:update(dt)
    end

    self:checkBallCollisions(dt)
    self.ball:update(dt)
    self:checkScore()
end

function Game:keypressed(key)
    if key == GameConfig.Controls.Players.Left.UP then
        self.leftPlayer:moveUp()
    elseif key == GameConfig.Controls.Players.Left.DOWN then
        self.leftPlayer:moveDown()
    end

    if not self.isPlayingVsAi then
        if key == GameConfig.Controls.Players.Right.UP then
            self.rightPlayer:moveUp()
        elseif key == GameConfig.Controls.Players.Right.DOWN then
            self.rightPlayer:moveDown()
        end
    end
end

function Game:keyreleased(key)
    local leftControls = GameConfig.Controls.Players.Left
    local rightControls = GameConfig.Controls.Players.Right
    local leftUp = key == leftControls.UP and not love.keyboard.isDown(leftControls.DOWN)
    local leftDown = key == leftControls.DOWN and not love.keyboard.isDown(leftControls.UP)
    local rightUp = key == rightControls.UP and not love.keyboard.isDown(leftControls.DOWN)
    local rightDown = key == rightControls.DOWN and not love.keyboard.isDown(leftControls.UP)

    -- local leftUp = key == GameConfig.Controls.Players.Left.UP and self.leftPlayer.paddle.direction == PaddleDirection.UP
    -- local leftDown = key == GameConfig.Controls.Players.Left.DOWN and self.leftPlayer.paddle.direction == PaddleDirection.DOWN
    -- local rightUp = key == GameConfig.Controls.Players.Right.UP and self.rightPlayer.paddle.direction == PaddleDirection.UP
    -- local rightDown = key == GameConfig.Controls.Players.Right.DOWN and self.rightPlayer.paddle.direction == PaddleDirection.DOWN
    if leftUp or leftDown then
        self.leftPlayer:stop()        
    elseif rightUp or rightDown then
        self.rightPlayer:stop()
    end
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
            local centerOffset = math.abs((point.y - paddleBBox.center) / (paddleBBox.height / 2) * GameConfig.Defaults.Ball.MAX_BOUNCE_ANGLE)
            local bounceAngle = math.rad(centerOffset)
            -- -- local angle = math.rad(GameConfig.Defaults.bounceAngle * (2 * (point.y - paddle:bbox().top) / paddle.height - 1))
            self.ball:horizontalBounce(bounceAngle)
        elseif point.direction == IntersectionDirection.TOP or point.direction == IntersectionDirection.BOTTOM then
            self.ball:verticalBounce()
        end

        if not self.isFirstHit then
            self.ball.velocity:mul(GameConfig.Defaults.Ball.FIRST_HIT_MULTIPLIER)
            self.isFirstHit = true
        end
    end
end

function Game:checkScore()
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

        self.isFirstHit = false
    end
end
