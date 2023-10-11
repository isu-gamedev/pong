require('game')
require('menu')

function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    menu = createMenu()
end

function love.draw()
    if gameScreen == "game" then
        game:draw()        
    elseif gameScreen == "menu_main" then
        menu:draw()
    end
end

function love.update(dt)
    if gameScreen == "game" then
        game:update(dt)
    end
end

function love.keypressed(key)
    if gameScreen == "game" then
        game:keypressed(key)
    elseif gameScreen == "menu_main" then
        local mode = menu:keypressed(key)
        if not mode then
            return
        end
        game = createGame(mode ~= MainMenu.mode.PvP)
    end
end

function love.keyreleased(key)
    if gameScreen == "game" then
        game:keyreleased(key)        
    end
end

function createGame(isPlayingVsAi)
    gameScreen = "game"
    -- HINT: Флаг на игру с гигачадом
    return Game:create(isPlayingVsAi)
end

function createMenu()
    gameScreen = "menu_main"
    return MainMenu:create()
end