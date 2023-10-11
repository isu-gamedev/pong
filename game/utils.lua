Utils = {}
Utils.__index = Utils

IntersectionDirection = {
    TOP = 1,
    RIGHT = 2,
    BOTTOM = 3,
    LEFT = 4
}

function Utils.ballIntersect(ball, rectBBox, velocityDelta)
    local dx = velocityDelta.x
    local dy = velocityDelta.y

    local point = nil

    if dx < 0 then
        point = Utils.intersect(ball.position.x, ball.position.y, ball.position.x + dx, ball.position.y + dy, rectBBox.right + ball.radius,
            rectBBox.top - ball.radius, rectBBox.right + ball.radius, rectBBox.bottom + ball.radius, IntersectionDirection.RIGHT)
    elseif dx > 0 then
        point = Utils.intersect(ball.position.x, ball.position.y, ball.position.x + dx, ball.position.y + dy, rectBBox.left - ball.radius,
            rectBBox.top - ball.radius, rectBBox.left - ball.radius, rectBBox.bottom + ball.radius, IntersectionDirection.LEFT)
    end

    if not point then
        if dy < 0 then
            point = Utils.intersect(ball.position.x, ball.position.y, ball.position.x + dx, ball.position.y + dy, rectBBox.left - ball.radius,
                rectBBox.bottom + ball.radius, rectBBox.right + ball.radius, rectBBox.bottom + ball.radius, IntersectionDirection.BOTTOM)
        elseif dy > 0 then
            point = Utils.intersect(ball.position.x, ball.position.y, ball.position.x + dx, ball.position.y + dy, rectBBox.left - ball.radius,
                rectBBox.top - ball.radius, rectBBox.right + ball.radius, rectBBox.top - ball.radius, IntersectionDirection.TOP)
        end
    end

    return point
end

function Utils.intersect(x1, y1, x2, y2, x3, y3, x4, y4, direction)
    local denom = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1)
    if denom ~= 0 then
        local ua = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / denom
        if ua >= 0 and ua <= 1 then
            local ub = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / denom
            if ub >= 0 and ub <= 1 then
                local x = x1 + ua * (x2 - x1)
                local y = y1 + ua * (y2 - y1)
                return {
                    x = x,
                    y = y,
                    direction = direction
                }
            end
        end
    end
    return nil
end
