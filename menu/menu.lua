Menu = {}
Menu.__index = Menu

function Menu:create(title, items)
    local menu = {}
    setmetatable(menu, Menu)

    menu.title = title
    menu.betweenItems = 20
    menu.items = items
    menu.y = (height - menu:getHeight()) / 2
    menu.x = (width - menu:getWidth()) / 2
    menu.chosenItem = 1
    menu.titleFont = love.graphics.newFont('fonts/MartianMono.ttf', 32)

    return menu
end

function Menu:drawMenu()
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle('fill', 0, 0, width, height)
    love.graphics.setColor(r, g, b, a)
    love.graphics.printf(self.title, self.titleFont, 0, 30, width, 'center')
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
        return chosenItem.func, chosenItem.args
    end
end

function Menu:revert()
    self.chosenItem = 1
end
