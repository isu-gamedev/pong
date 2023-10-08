Player = {}
Player.__index = Player

function Player:create(paddle)
    local player = {}
    setmetatable(player, Player)

    player.paddle = paddle

    return player
end
