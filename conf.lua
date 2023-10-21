GlobalConfig = {
    __DEV__ = false,
    WINDOW_WIDTH = 1920,
    WINDOW_HEIGHT = 1080,
    SCALE = 0.75
}

function love.conf(t)
    t.window.title = 'Pong'
    t.window.width = GlobalConfig.WINDOW_WIDTH * GlobalConfig.SCALE
    t.window.height = GlobalConfig.WINDOW_HEIGHT * GlobalConfig.SCALE
    t.window.msaa = 8
    t.console = GlobalConfig.__DEV__
end
