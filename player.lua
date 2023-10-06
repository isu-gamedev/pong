Player = {}
Player.__index = Player

function Player:create()
    local player = {}
    setmetatable(player, Player)

    -- player.paddle = 

    return player
end
