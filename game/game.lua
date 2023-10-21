Game = {}
Game.__index = Game

GameConfig = {
    Defaults = {
        Paddle = {
            X_OFFSET = 30 * GlobalConfig.SCALE,
            HEIGHT = 160 * GlobalConfig.SCALE,
            SPEED = 700 * GlobalConfig.SCALE
        },
        Ball = {
            RADIUS = 40 * GlobalConfig.SCALE,
            SPEED = 500 * GlobalConfig.SCALE,
            FIRST_HIT_MULTIPLIER = 2.5,
            MAX_BOUNCE_ANGLE = 45,
            FOOTPRINT_COUNT = 0
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
    },

    Sounds = {
        HIT = '/assets/sounds/hit.mp3',
        BACKGROUND = '/assets/sounds/game.mp3'
    },

    Images = {
        LEFT_PLAYER = '/assets/images/left-player.png',
        RIGHT_PLAYER = '/assets/images//right-player.png',
        BALL = '/assets/images/ball.png',
        BACKGROUND = '/assets/images/game-background.jpg'
    },

    HEADER_HEIGHT = 100 * GlobalConfig.SCALE,
    FONT_SIZE = 70 * GlobalConfig.SCALE
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
    ---------------------------------------
    settings = settings or {}
    settings.vsAi = settings.vsAi or false
    settings.difficulty = settings.difficulty or GameDifficulty.MEDIUM
    settings.soundOn = settings.soundOn or false
    ---------------------------------------
    local game = {}
    setmetatable(game, Game)
    ---------------------------------------
    local paddleY = (height + GameConfig.HEADER_HEIGHT) / 2 - GameConfig.Defaults.Paddle.HEIGHT / 2

    local leftPaddleImage = love.graphics.newImage(GameConfig.Images.LEFT_PLAYER)
    local leftPaddleWidth = leftPaddleImage:getWidth() / leftPaddleImage:getHeight() * GameConfig.Defaults.Paddle.HEIGHT
    local leftPaddle = Paddle:create(Vector:create(GameConfig.Defaults.Paddle.X_OFFSET, paddleY), GameConfig.Defaults.Paddle.SPEED, leftPaddleWidth,
        GameConfig.Defaults.Paddle.HEIGHT, leftPaddleImage, GameConfig.HEADER_HEIGHT, height)

    local rightPaddleImage = love.graphics.newImage(GameConfig.Images.RIGHT_PLAYER)
    local rightPaddleWidth = rightPaddleImage:getWidth() / rightPaddleImage:getHeight() * GameConfig.Defaults.Paddle.HEIGHT
    local rightPaddle = Paddle:create(Vector:create(width - GameConfig.Defaults.Paddle.X_OFFSET - rightPaddleWidth, paddleY), GameConfig.Defaults.Paddle.SPEED,
        rightPaddleWidth, GameConfig.Defaults.Paddle.HEIGHT, rightPaddleImage, GameConfig.HEADER_HEIGHT, height)

    game.leftPlayer = Player:create('Left', leftPaddle)
    game.rightPlayer = settings.vsAi and AiPlayer:create('Right', rightPaddle, settings.difficulty, false) or Player:create('Right', rightPaddle)
    ---------------------------------------
    local ballPosition = self:getInitialBallPosition()
    local ballVelocity = self:getInitialBallVelocity()
    local ballImage = love.graphics.newImage(GameConfig.Images.BALL)

    game.ball = Ball:create(ballPosition, ballVelocity, GameConfig.Defaults.Ball.RADIUS, GameConfig.Defaults.Ball.FOOTPRINT_COUNT, ballImage, 0, width,
        GameConfig.HEADER_HEIGHT, height)
    ---------------------------------------
    game.settings = settings
    game.isFirstHit = false
    game.winner = nil
    ---------------------------------------
    game.hitSound = love.audio.newSource(GameConfig.Sounds.HIT, 'static')
    game.backgroundSound = love.audio.newSource(GameConfig.Sounds.BACKGROUND, 'stream')
    game.backgroundSound:setLooping(true)
    if settings.soundOn then
        game.backgroundSound:play()
    end
    ---------------------------------------
    local backgroundImage = love.graphics.newImage(GameConfig.Images.BACKGROUND)

    game.backgroundImage = backgroundImage
    game.backgroundImageScale = {
        x = width / backgroundImage:getWidth(),
        y = (height - GameConfig.HEADER_HEIGHT) / backgroundImage:getHeight()
    }
    ---------------------------------------
    game.font = love.graphics.newFont('/assets/fonts/BrahmsGotischCyr.otf', GameConfig.FONT_SIZE)
    ---------------------------------------
    return game
end

function Game:draw()
    self:drawBackgroundImage()
    self:drawScore()
    self.leftPlayer:draw()
    self.rightPlayer:draw()
    self.ball:draw()
end

function Game:update(dt)
    self.leftPlayer:update(dt)
    self.rightPlayer:update(dt, self.ball)
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

function Game:getInitialBallPosition(side)
    side = side or PlayerSide.LEFT

    local x = 0 - GameConfig.Defaults.Ball.RADIUS + 1
    local y = love.math.random(GameConfig.HEADER_HEIGHT + height / 6, height - height / 6)

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

function Game:drawScore()
    local r, g, b, a = love.graphics.getColor()

    love.graphics.setColor(154 / 255, 83 / 255, 33 / 255, a)
    love.graphics.rectangle('fill', 0, 0, width, GameConfig.HEADER_HEIGHT)

    local scoreText = string.format('%d:%d', self.leftPlayer.score, self.rightPlayer.score)
    local scoreHeight = self.font:getHeight(scoreText)

    love.graphics.setFont(self.font)
    love.graphics.setColor(225 / 255, 170 / 255, 96 / 255)
    love.graphics.printf(scoreText, 0, GameConfig.HEADER_HEIGHT / 2 - scoreHeight / 2, width, 'center')

    love.graphics.setColor(r, g, b, a)
end

function Game:drawBackgroundImage()
    love.graphics.draw(self.backgroundImage, 0, GameConfig.HEADER_HEIGHT, 0, self.backgroundImageScale.x, self.backgroundImageScale.y)
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

        if self.settings.soundOn then
            self.hitSound:play()
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
    return self.ball:isMovingLeft() and PlayerSide.RIGHT or PlayerSide.LEFT
end

function Game:isOver()
    local hasLeftWon = self.leftPlayer.score == GameConfig.Defaults.MAX_SCORE
    local hasRightWon = self.rightPlayer.score == GameConfig.Defaults.MAX_SCORE

    if hasLeftWon or hasRightWon then
        return hasLeftWon and self.leftPlayer or self.rightPlayer
    end
    return nil
end

function Game:toggleSound()
    if (self.settings.soundOn) then
        self.backgroundSound:stop()
    else
        self.backgroundSound:play()
    end
    self.settings.soundOn = not self.settings.soundOn
end
