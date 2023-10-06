require('vector')
local PlayerModule = require('player')

local Player, PlayerPosition = PlayerModule.Player, PlayerModule.PlayerPosition

function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    leftPlayer = Player:create(PlayerPosition.LEFT)
    rightPlayer = Player:create(PlayerPosition.RIGHT)
end

function love.draw()
    leftPlayer:draw()
    rightPlayer:draw()
end

function love.update(dt)
    leftPlayer:update(dt)
    rightPlayer:update(dt)
end

function love.keypressed(key)
    leftPlayer:keypressed(key)
    rightPlayer:keypressed(key)
end

function love.keyreleased(key)
    leftPlayer:keyreleased(key)
    rightPlayer:keyreleased(key)
end

