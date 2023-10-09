Player = {}
Player.__index = Player

function Player:create(paddle)
    local player = {}
    setmetatable(player, Player)

    player.paddle = paddle
    player.score = 0

    return player
end

function Player:goal()
    self.score = self.score + 1
end
