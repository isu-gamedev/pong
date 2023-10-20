MenuItem = {}
MenuItem.__index = MenuItem

function MenuItem:create(text, func, args, itemImage)
    local item = {}
    setmetatable(item, MenuItem)

    item.text = text
    -- item.height = 50
    -- item.width = 120
    item.func = func
    item.args = args

    -- item.font = love.graphics.newFont('fonts/MartianMono.ttf', 12)
    item.font = love.graphics.newFont('assets/fonts/BrahmsGotischCyr.otf', 70 * scale)
    item.background = itemImage or love.graphics.newImage('assets/images/menu-item.png')
    item.height = item.background:getHeight() * scale
    item.width = item.background:getWidth() * scale
    return item
end

function MenuItem:draw(menuOffsetX, menuOffsetY, chosen)
    local x = menuOffsetX
    local y = menuOffsetY
    local padding = self:getPadding()

    local textColor = {255, 255, 255, 255}
    local fillMode = 'line'
    if chosen then
        textColor = {0, 0, 0, 255}
        fillMode = 'fill'
    end
    love.graphics.draw(self.background, x, y, 0, scale, scale)
    -- love.graphics.rectangle(fillMode, x, y, self.width, self.height)
    love.graphics.printf({textColor, self.text}, self.font, x, y + padding, self.width, 'center')
end

function MenuItem:getPadding()
    return (self.height - self.font:getHeight()) / 2
end
