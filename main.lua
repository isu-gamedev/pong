require('game')
require('menu')

GameState = {
    MAIN_MENU = 1,
    GAME = 2,
    PAUSED = 3,
    GAME_OVER = 4
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
        pauseMenu:draw()
    elseif gameState == GameState.MAIN_MENU then
        menu:draw()
    elseif gameState == GameState.GAME_OVER then
        game:draw()
        gameOverMenu:draw()
    end
end

function love.update(dt)
    if gameState == GameState.GAME then
        local winner = game:isOver()
        if winner ~= nil then
            gameOverMenu = createGameOver(winner.name, game.leftPlayer.score, game.rightPlayer.score)
            return
        end
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
        local settings = {
            vsAi = mode ~= MainMenu.mode.PvP,
            difficulty = mode
        }
        game = createGame(settings)
    elseif gameState == GameState.PAUSED then
        local func = pauseMenu:keypressed(key)
        if func then
            func()
        end
    elseif gameState == GameState.GAME_OVER then
        local func = gameOverMenu:keypressed(key)
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

function createGameOver(winningSide, scoreLeft, scoreRigth)
    gameState = GameState.GAME_OVER
    local title = winningSide .. ' player wins! Score: ' .. scoreLeft .. ':' .. scoreRigth
    local gameOverMenu = Menu:create(title, {MenuItem:create('Play again', createGame, game.settings), MenuItem:create('To menu', function()
        menu = createMenu()
    end), MenuItem:create('Quit', love.event.quit, {0})})
    return gameOverMenu
end
