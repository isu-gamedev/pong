Menu = {}
Menu.__index = Menu

function Menu:create(title, items, x, y, background)
    local menu = {}
    setmetatable(menu, Menu)

    menu.title = title
    -- menu.titleY = (430 - 305) * scale -- relative to menu
    menu.titleY = 70 * scale
    menu.titleHeight = 70 * scale
    menu.betweenItems = 25 * scale
    menu.items = items
    menu.y = y or (height - menu:getHeight()) / 2
    menu.x = x or (width - menu:getWidth()) / 2
    menu.chosenItem = 1
    menu.background = background
    -- menu.titleFont = love.graphics.newFont('fonts/MartianMono.ttf', 32)
    menu.titleFont = love.graphics.newFont('/assets/fonts/BrahmsGotischCyr.otf', menu.titleHeight)
    menu.titleColor = {0, 0, 0, 1}
    return menu
end

function Menu:draw(darken, showTitle)
    if darken == nil then
        darken = true
    end
    if showTitle == nil then
        showTitle = true
    end
    if self.background then
        love.graphics.draw(self.background, 0, 0, 0, scale, scale)
    end
    if darken then
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle('fill', 0, 0, width, height)
        love.graphics.setColor(r, g, b, a)
    end
    if showTitle then
        love.graphics.printf({self.titleColor, self.title}, self.titleFont, 0, self.y - self.titleY - self.titleHeight, width, 'center')
    end
    self:drawItems()
end

function Menu:drawItems()
    for n, i in ipairs(self.items) do
        local added = (i.height + self.betweenItems) * (n - 1)
        local chosen = n == self.chosenItem
        i:draw(self.x, self.y + added, chosen)
    end
end

function Menu:getHeight()
    local menuHeight = 0
    for n, i in ipairs(self.items) do
        if n ~= 1 then
            menuHeight = menuHeight + self.betweenItems
        end
        menuHeight = menuHeight + i.height
    end
    return menuHeight
end

function Menu:getWidth()
    return self.items[1].width
end

function Menu:keypressed(key, scancode)
    if key == 'up' then
        if self.chosenItem > 1 then
            self.chosenItem = self.chosenItem - 1
        end
    elseif key == 'down' then
        if self.chosenItem < #self.items then
            self.chosenItem = self.chosenItem + 1
        end
    elseif key == 'space' or key == 'return' then
        local chosenItem = self.items[self.chosenItem]
        if chosenItem.sound:isPlaying() then
            chosenItem.sound:stop()
        end
        chosenItem.sound:play()

        return chosenItem.func, chosenItem.args
    end
end

function Menu:revert()
    self.chosenItem = 1
end
