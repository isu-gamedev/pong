Player = {}
Player.__index = Player

Player.paddleWidth = 10
Player.paddleHeight = 80

function Player:create(location, speed)
    local player = {}
    setmetatable(player, Player)

    player.paddle = Paddle:create(location, Vector:create(0, speed), Player.paddleWidth, Player.paddleHeight)

    return player
end

function Player:draw()
    self.paddle:draw()
end

function Player:update(dt)
    self.paddle:update(dt)
end

function Player:moveUp()
    self.paddle.direction = PaddleDirection.UP
end

function Player:moveDown()
    self.paddle.direction = PaddleDirection.DOWN
end

function Player:stop()
    self.paddle.direction = nil
end
