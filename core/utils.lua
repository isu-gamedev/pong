Utils = {}
Utils.__index = Utils

function Utils.randomBetween(min, max)
    return math.random() * (max - min) + min
end
