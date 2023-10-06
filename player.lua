local PaddleModule = require('paddle')

local Paddle, PaddleDirection = PaddleModule.Paddle, PaddleModule.PaddleDirection

local Player = {}
Player.__index = Player

local PlayerPosition = {
    LEFT = 1,
    RIGHT = 2
}

function Player:create(position)
    local self = {}
    setmetatable(self, Player)
    self.isLeft = position == PlayerPosition.LEFT
    -- FIX: Хардкод расположения взависимости от позиции, стоит ли выносить во внешние зависимости?
    local x = 20
    if not self.isLeft then
        x = width - Paddle.width - x
    end
    self.paddle = Paddle:create(x, height / 2 - Paddle.height / 2)
    return self
end

function Player:draw()
    self.paddle:draw()
end

function Player:update(dt)
    self.paddle:update(dt)
end

function Player:keypressed(key)
    if self.isLeft then
        if key == 'w' then
            self.paddle.direction = PaddleDirection.UP
        elseif key == 's' then
            self.paddle.direction = PaddleDirection.DOWN
        end
    else
        if key == 'up' then
            self.paddle.direction = PaddleDirection.UP
        elseif key == 'down' then
            self.paddle.direction = PaddleDirection.DOWN
        end
    end
end

function Player:keyreleased(key)
    self.paddle.direction = nil
end

return {
    Player = Player,
    PlayerPosition = PlayerPosition
}
