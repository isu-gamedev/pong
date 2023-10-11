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
    
    self.diffMenu = Menu:create("Choose difficulty", 
                                {MenuItem:create("Easy", MainMenu.chooseMode, {self, MainMenu.mode.EASY}),
                                    MenuItem:create("Medium", MainMenu.chooseMode, {self, MainMenu.mode.MEDIUM}),
                                    MenuItem:create("Hard", MainMenu.chooseMode, {self, MainMenu.mode.HARD}),
                                    MenuItem:create("Back", MainMenu.goBack, {self})})
    self.menu = Menu:create("Pong", 
                            {MenuItem:create("One player", MainMenu.goForward, {self, self.diffMenu}),
                                MenuItem:create("Two players", MainMenu.chooseMode, {self, MainMenu.mode.PvP}),
                                MenuItem:create("Quit", love.event.quit, {0})})
    self.currMenu = self.menu

    self.menuStack = {}
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

function  MainMenu:chooseMode(mode)
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
    self.currMenu:drawMenu()
end