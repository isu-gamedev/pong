MainMenu = {}
MainMenu.__index = MainMenu

MainMenu.mode = {
    EASY = 1,
    MEDIUM = 2,
    HARD = 3,
    PvP = 4
}

function MainMenu:create()
    local mainMenu = {}
    setmetatable(mainMenu, MainMenu)
    local mainItem = love.graphics.newImage('assets/images/menu-item.png')
    local difficultyItem = love.graphics.newImage('assets/images/difficulty-item.png')
    self.diffMenu = Menu:create('Choose the difficulty level', {MenuItem:create('Easy', MainMenu.chooseMode, {self, MainMenu.mode.EASY}, difficultyItem),
                                                                MenuItem:create('Medium', MainMenu.chooseMode, {self, MainMenu.mode.MEDIUM}, difficultyItem),
                                                                MenuItem:create('Hard', MainMenu.chooseMode, {self, MainMenu.mode.HARD}, difficultyItem),
                                                                MenuItem:create('Back', MainMenu.goBack, {self}, difficultyItem)}, nil, 430 * scale)
    self.menu = Menu:create('Pong',
        {MenuItem:create('One player', MainMenu.goForward, {self, self.diffMenu}),
         MenuItem:create('Two players', MainMenu.chooseMode, {self, MainMenu.mode.PvP}), MenuItem:create('Sound on', MainMenu.toggleSound, {self}),
         MenuItem:create('Quit', love.event.quit, {0})}, 1070 * scale, 530 * scale)

    self.currMenu = self.menu
    self.menuStack = {}
    self.background = {love.graphics.newImage('assets/images/menu-background.png'), love.graphics.newImage('assets/images/executioners.png')}
    self.title = love.graphics.newImage('assets/images/title.png')
    self.music = love.audio.newSource('assets/sounds/menu.mp3', 'stream')
    self.music:play()
    return mainMenu
end

function MainMenu:goForward(newMenu)
    table.insert(self.menuStack, self.currMenu)
    self.currMenu = newMenu
end

function MainMenu:goBack()
    self.currMenu:revert()
    self.currMenu = table.remove(self.menuStack)
end

function MainMenu:chooseMode(mode)
    self.music:pause()
    return mode
end

function MainMenu:keypressed(key)
    local func, args = self.currMenu:keypressed(key)
    if not func then
        return nil
    end
    return func(unpack(args))
end

function MainMenu:draw()
    if not self.music:isPlaying() then
        self.msuic:rewind()
    end
    self:drawBackground()
    local showTitle = true
    if self.currMenu == self.menu then
        love.graphics.draw(self.title, 1070 * scale, 195 * scale, 0, scale, scale)
        showTitle = false
    end
    self.currMenu:draw(false, showTitle)
end

function MainMenu:toggleSound()
    if self:isSoundOn() then
        self.music:setVolume(0)
        self.menu.items[self.menu.chosenItem].text = 'Sound off'
    else
        self.music:setVolume(1)
        self.menu.items[self.menu.chosenItem].text = 'Sound on'
    end
end

function MainMenu:isSoundOn()
    return self.music:getVolume() ~= 0
end

function MainMenu:drawBackground()
    love.graphics.draw(self.background[1], 0, 0, 0, scale, scale)
    if self.currMenu == self.menu then
        love.graphics.draw(self.background[2], 65 * scale, 120 * scale, 0, scale, scale)

    end

end
