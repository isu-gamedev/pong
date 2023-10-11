require('game')
require('menu')

GameState = {
    MAIN_MENU = 1,
    GAME = 2,
    PAUSED = 3
}

function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    pauseMenu = Menu:create('Pause', {MenuItem:create('Continue', function()
        gameState = GameState.GAME
    end), MenuItem:create('To menu', function()
        menu = createMenu()
    end), MenuItem:create('Quit', love.event.quit, {0})})
    menu = createMenu()
end

function love.draw()
    if gameState == GameState.GAME then
        game:draw()
    elseif gameState == GameState.PAUSED then
        game:draw()
        pauseMenu:drawMenu()
    elseif gameState == GameState.MAIN_MENU then
        menu:draw()
    end
end

function love.update(dt)
    if gameState == GameState.GAME then
        game:update(dt)
    end
end

function love.keypressed(key)
    if gameState == GameState.GAME then
        if key == 'escape' then
            gameState = GameState.PAUSED
            return
        end
        game:keypressed(key)
    elseif gameState == GameState.MAIN_MENU then
        local mode = menu:keypressed(key)
        if not mode then
            return
        end
        -- TODO: Разная сложность в зависимости от выбора
        game = createGame({
            vsAi = mode ~= MainMenu.mode.PvP
        })
    elseif gameState == GameState.PAUSED then
        local func = pauseMenu:keypressed(key)
        if func then
            func()
        end
    end
end

function love.keyreleased(key)
    if gameState == GameState.GAME then
        game:keyreleased(key)
    end
end

function createGame(settings)
    gameState = GameState.GAME
    return Game:create(settings)
end

function createMenu()
    game = nil -- Очищаем память
    pauseMenu:revert() -- Сбрасываем меню паузы в дефолт
    gameState = GameState.MAIN_MENU
    return MainMenu:create()
end
