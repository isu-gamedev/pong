Game = {}
Game.__index = Game

GameConfig = {
    Defaults = {
        paddleWidth = 20,
        paddleHeight = 100,
        paddleSpeed = 500,
        ballRadius = 10,
        ballSpeed = 500,
        ballFootprintCount = 20
    }
}

function Game:create()
    local game = {}
    setmetatable(game, Game)

    local px, py = 20, height / 2 - GameConfig.Defaults.paddleHeight / 2
    local leftPaddle = Paddle:create(Vector:create(px, py), GameConfig.Defaults.paddleSpeed, GameConfig.Defaults.paddleWidth,
        GameConfig.Defaults.paddleHeight, 0, height)
    local rightPaddle = Paddle:create(Vector:create(width - px - GameConfig.Defaults.paddleWidth, py), GameConfig.Defaults.paddleSpeed,
        GameConfig.Defaults.paddleWidth, GameConfig.Defaults.paddleHeight, 0, height)

    game.leftPlayer = Player:create(leftPaddle)
    game.rightPlayer = Player:create(rightPaddle)

    local bx, by = width / 2, height / 2

    game.ball = Ball:create(Vector:create(bx, by), GameConfig.Defaults.ballSpeed, GameConfig.Defaults.ballRadius, 0, height,
        GameConfig.Defaults.ballFootprintCount)

    return game
end

function Game:draw()
    self.leftPlayer.paddle:draw()
    self.rightPlayer.paddle:draw()
    self.ball:draw()
end

function Game:update(dt)
    self.leftPlayer.paddle:update(dt)
    self.rightPlayer.paddle:update(dt)
    self.ball:update(dt, self.leftPlayer.paddle, self.rightPlayer.paddle)
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
