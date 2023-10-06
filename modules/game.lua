Game = {}
Game.__index = Game

function Game:create()
    local game = {}
    setmetatable(game, Game)

    local playerLocation = Vector:create(20, height / 2 - Player.paddleHeight / 2)
    local playerSpeed = 300
    game.leftPlayer = Player:create(playerLocation, playerSpeed)
    game.rightPlayer = Player:create(Vector:create(width - playerLocation.x - Player.paddleWidth, playerLocation.y),
        playerSpeed)

    game.ball = Ball:create(Vector:create(width / 2, height / 2), Vector:create(500, 0), 10)

    return game
end

function Game:draw()
    self.leftPlayer:draw()
    self.rightPlayer:draw()
    self.ball:draw()
end

function Game:update(dt)
    self.leftPlayer:update(dt)
    self.rightPlayer:update(dt)
    self.ball:update(dt)

    if self.ball:checkCollision(self.leftPlayer) or self.ball:checkCollision(self.rightPlayer) then
        print('Pong')
    end
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
