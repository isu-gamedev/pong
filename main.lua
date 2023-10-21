require('game')
require('menu')

GameState = {
    MAIN_MENU = 1,
    GAME = 2,
    PAUSED = 3,
    GAME_OVER = 4
}

function love.load()
    scale = 0.75
    love.window.setMode(1920 * scale, 1080 * scale)
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    local menuItem = love.graphics.newImage('assets/images/menu-item.png')
    pauseMenu = Menu:create('Menu', {MenuItem:create('Continue', function()
        gameState = GameState.GAME
    end, {}, menuItem), MenuItem:create('Sound on', toggleSound, {}, menuItem), MenuItem:create('To menu', function()
        menu = createMenu()
    end, {}, menuItem), MenuItem:create('Quit', love.event.quit, {0}, menuItem)}, nil, nil, love.graphics.newImage('assets/images/menu-background.png'))

    menu = createMenu()
end

function love.draw()
    if gameState == GameState.GAME then
        game:draw()
    elseif gameState == GameState.PAUSED then
        game:draw()
        pauseMenu:draw(false)
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
            difficulty = mode,
            soundOn = menu:isSoundOn()
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
    -- local title = winningSide .. ' player wins! Score: ' .. scoreLeft .. ':' .. scoreRigth
    local title = 'You are loser'
    local image = love.graphics.newImage('assets/images/menu-lost.png')
    local gameOverMenu = Menu:create(title, {MenuItem:create('Play again', function()
        game = createGame(game.settings)
    end, {}, image), MenuItem:create('To menu', function()
        menu = createMenu()
    end, {}, image), MenuItem:create('Quit', love.event.quit, {0}, image)}, nil, 520 * scale)
    gameOverMenu.titleHeight = 150 * scale
    gameOverMenu.titleFont = love.graphics.newFont('assets/fonts/BrahmsGotischCyr.otf', 150 * scale)
    gameOverMenu.titleColor = {211, 0, 0, 1}
    return gameOverMenu
end

function toggleSound()
    -- TODO: toggle logic
    if game.settings.soundOn then
        pauseMenu.items[pauseMenu.chosenItem].text = 'Sound on'
    else
        pauseMenu.items[pauseMenu.chosenItem].text = 'Sound off'
    end
end
