Player = {}
Player.__index = Player

function Player:create(name, paddle)
    local player = {}
    setmetatable(player, Player)

    player.name = name
    player.paddle = paddle
    player.score = 0

    return player
end

function Player:draw()
    self.paddle:draw()
end

function Player:update(dt)
    self.paddle:update(dt)
end

function Player:moveUp()
    self.paddle:moveUp()
end

function Player:moveDown()
    self.paddle:moveDown()
end

function Player:stop()
    self.paddle:stop()
end

function Player:addScore()
    self.score = self.score + 1
end

function Player:isMovingUp()
    return self.paddle:isMovingUp()
end

function Player:isMovingDown()
    return self.paddle:isMovingDown()
end

function Player:getBBox()
    return self.paddle:getBBox()
end
