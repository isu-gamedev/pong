Mover = {}
Mover.__index = Mover

function Mover:create(location, velocity)
    local mover = {}
    setmetatable(mover, Mover)

    mover.location = location
    mover.velocity = velocity

    return mover
end

function Mover:applyForce(force)
    self.location:add(force)
end
