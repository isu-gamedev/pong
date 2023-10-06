Config = {
    __DEV__ = true
}

function love.conf(t)
    t.window.title = 'Pong'
    t.window.width = 800
    t.window.height = 600
    t.window.msaa = 8
    t.console = Config.__DEV__
end
