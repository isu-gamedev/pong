require('core.utils')
require('core.vector')
require('core.mover')
require('modules.paddle')
require('modules.player')
require('modules.ball')
require('modules.game')

function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    game = Game:create()
end

function love.draw()
    game:draw()
end

function love.update(dt)
    game:update(dt)
end

function love.keypressed(key)
    game:keypressed(key)
end

function love.keyreleased(key)
    game:keyreleased(key)
end
