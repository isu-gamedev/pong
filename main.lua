require('game.init')

function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    game = Game:create({
        vsAi = true
    })
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
