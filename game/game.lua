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
        },
        MAX_SCORE = 5
    },

    Controls = {
        LeftPlayer = {
            UP = 'w',
            DOWN = 's'
        },
        RightPlayer = {
            UP = 'up',
            DOWN = 'down'
        }
    }
}

PlayerSide = {
    LEFT = 1,
    RIGHT = 2
}

GameDifficulty = {
    EASY = 1,
    MEDIUM = 2,
    HARD = 3
}

function Game:create(settings)
    settings = settings or {}
    settings.vsAi = settings.vsAi or false
    settings.difficulty = settings.difficulty or GameDifficulty.MEDIUM

    local game = {}
    setmetatable(game, Game)

    local paddleX = 0
    local paddleY = height / 2 - GameConfig.Defaults.Paddle.HEIGHT / 2

    local leftPaddle = Paddle:create(Vector:create(paddleX, paddleY), GameConfig.Defaults.Paddle.SPEED, GameConfig.Defaults.Paddle.WIDTH,
        GameConfig.Defaults.Paddle.HEIGHT)

    local rightPaddle = Paddle:create(Vector:create(width - paddleX - GameConfig.Defaults.Paddle.WIDTH, paddleY), GameConfig.Defaults.Paddle.SPEED,
        GameConfig.Defaults.Paddle.WIDTH, GameConfig.Defaults.Paddle.HEIGHT)

    game.leftPlayer = Player:create('Left', leftPaddle)
    game.rightPlayer = settings.vsAi and AiPlayer:create('Right', rightPaddle, settings.difficulty) or Player:create('Right', rightPaddle)

    local ballPosition = self:getInitialBallPosition()
    local ballVelocity = self:getInitialBallVelocity()

    game.ball = Ball:create(ballPosition, ballVelocity, GameConfig.Defaults.Ball.RADIUS, GameConfig.Defaults.Ball.FOOTPRINT_COUNT)

    game.settings = settings
    game.isFirstHit = false
    game.winner = nil

    return game
end

function Game:getInitialBallPosition(side)
    side = side or PlayerSide.LEFT

    local x = 0 - GameConfig.Defaults.Ball.RADIUS + 1
    local y = love.math.random(height / 6, height - height / 6)

    if side == PlayerSide.RIGHT then
        x = width + GameConfig.Defaults.Ball.RADIUS - 1
    end

    return Vector:create(x, y)
end

function Game:getInitialBallVelocity(side)
    side = side or PlayerSide.LEFT

    local direction = 1
    if side == PlayerSide.RIGHT then
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

    if self.settings.vsAi then
        self.rightPlayer:update(dt, self.ball)
    else
        self.rightPlayer:update(dt)
    end

    self:checkBallCollisions(dt)
    self.ball:update(dt)
    self:checkScore()
end

function Game:keypressed(key)
    if key == GameConfig.Controls.LeftPlayer.UP then
        self.leftPlayer:moveUp()
    elseif key == GameConfig.Controls.LeftPlayer.DOWN then
        self.leftPlayer:moveDown()
    end

    if not self.settings.vsAi then
        if key == GameConfig.Controls.RightPlayer.UP then
            self.rightPlayer:moveUp()
        elseif key == GameConfig.Controls.RightPlayer.DOWN then
            self.rightPlayer:moveDown()
        end
    end
end

function Game:keyreleased(key)
    local leftUp = self.leftPlayer:isMovingUp() and key == GameConfig.Controls.LeftPlayer.UP
    local leftDown = self.leftPlayer:isMovingDown() and key == GameConfig.Controls.LeftPlayer.DOWN

    local rightUp = self.rightPlayer:isMovingUp() and key == GameConfig.Controls.RightPlayer.UP
    local rightDown = self.rightPlayer:isMovingDown() and key == GameConfig.Controls.RightPlayer.DOWN

    if leftUp or leftDown then
        self.leftPlayer:stop()
    elseif (rightUp or rightDown) and not self.settings.vsAi then
        self.rightPlayer:stop()
    end
end

function Game:checkBallCollisions(dt)
    self:checkBallAndPlayerCollision(dt)
end

function Game:checkBallAndPlayerCollision(dt)
    local player = self:getAttackingSide() == PlayerSide.RIGHT and self.leftPlayer or self.rightPlayer
    local playerBBox = player:getBBox()

    local point = Utils.ballIntersect(self.ball, playerBBox, self.ball.velocity * dt)

    if point then
        if point.direction == IntersectionDirection.LEFT or point.direction == IntersectionDirection.RIGHT then
            local centerOffset = math.abs((point.y - playerBBox.center) / (playerBBox.height / 2) * GameConfig.Defaults.Ball.MAX_BOUNCE_ANGLE)
            local bounceAngle = math.rad(centerOffset)
            -- local angle = math.rad(GameConfig.Defaults.bounceAngle * (2 * (point.y - paddle:bbox().top) / paddle.height - 1))
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
        local attackingSide = self:getAttackingSide()

        if attackingSide == PlayerSide.RIGHT then
            self.rightPlayer:addScore()
        elseif attackingSide == PlayerSide.LEFT then
            self.leftPlayer:addScore()
        end

        self.ball.position = self:getInitialBallPosition(attackingSide)
        self.ball.velocity = self:getInitialBallVelocity(attackingSide)

        self.isFirstHit = false
    end
end

function Game:getAttackingSide()
    if self.ball:isMovingLeft() then
        return PlayerSide.RIGHT
    end
    return PlayerSide.LEFT
end

function Game:isOver()
    local maxScore = GameConfig.Defaults.MAX_SCORE
    local hasLeftWon = self.leftPlayer.score == maxScore
    local hasRightWon = self.rightPlayer.score == maxScore

    if hasLeftWon or hasRightWon then
        return hasLeftWon and self.leftPlayer or self.rightPlayer
    end
    return nil
end
