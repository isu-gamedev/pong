Mover = {}
Mover.__index = Mover

function Mover:create(position, velocity)
    local mover = {}
    setmetatable(mover, Mover)

    mover.position = position
    mover.velocity = velocity

    return mover
end

function Mover:applyForce(force)
    self.position:add(force)
end
