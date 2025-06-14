local windowManagement = {}

-- アニメーションを無効化
hs.window.animationDuration = 0

-- ウィンドウが画面の左半分にあるかチェック
local function isLeftHalf(win, screen)
    local winFrame = win:frame()
    local screenFrame = screen:frame()
    
    local tolerance = 10
    return math.abs(winFrame.x - screenFrame.x) < tolerance and
           math.abs(winFrame.w - screenFrame.w / 2) < tolerance and
           math.abs(winFrame.h - screenFrame.h) < tolerance
end

-- ウィンドウが画面の右半分にあるかチェック
local function isRightHalf(win, screen)
    local winFrame = win:frame()
    local screenFrame = screen:frame()
    
    local tolerance = 10
    return math.abs(winFrame.x - (screenFrame.x + screenFrame.w / 2)) < tolerance and
           math.abs(winFrame.w - screenFrame.w / 2) < tolerance and
           math.abs(winFrame.h - screenFrame.h) < tolerance
end

-- 最も右にあるスクリーンを取得
local function getRightmostScreen()
    local screens = hs.screen.allScreens()
    local rightmost = screens[1]
    
    for _, screen in ipairs(screens) do
        if screen:frame().x > rightmost:frame().x then
            rightmost = screen
        end
    end
    
    return rightmost
end

-- 最も左にあるスクリーンを取得
local function getLeftmostScreen()
    local screens = hs.screen.allScreens()
    local leftmost = screens[1]
    
    for _, screen in ipairs(screens) do
        if screen:frame().x < leftmost:frame().x then
            leftmost = screen
        end
    end
    
    return leftmost
end

-- 左方向の動作
function windowManagement.moveLeft()
    local win = hs.window.focusedWindow()
    if not win then return end
    
    local screen = win:screen()
    local screenFrame = screen:frame()
    local winFrame = win:frame()
    
    
    -- 現在左半分にある場合
    if isLeftHalf(win, screen) then
        -- 左の画面を探す
        local westScreen = screen:toWest()
        if westScreen then
            -- 左の画面の右半分に移動
            local westFrame = westScreen:frame()
            win:setFrame({
                x = westFrame.x + westFrame.w / 2,
                y = westFrame.y,
                w = westFrame.w / 2,
                h = westFrame.h
            })
            win:moveToScreen(westScreen, false, true)
        else
            -- 左端にいる場合は、最も右の画面の右半分に移動
            local rightmostScreen = getRightmostScreen()
            if rightmostScreen and rightmostScreen ~= screen then
                local rightmostFrame = rightmostScreen:frame()
                win:setFrame({
                    x = rightmostFrame.x + rightmostFrame.w / 2,
                    y = rightmostFrame.y,
                    w = rightmostFrame.w / 2,
                    h = rightmostFrame.h
                })
                win:moveToScreen(rightmostScreen, false, true)
            end
        end
    else
        -- 現在の画面の左半分に配置
        win:setFrame({
            x = screenFrame.x,
            y = screenFrame.y,
            w = screenFrame.w / 2,
            h = screenFrame.h
        })
    end
end

-- 右方向の動作
function windowManagement.moveRight()
    local win = hs.window.focusedWindow()
    if not win then return end
    
    local screen = win:screen()
    local screenFrame = screen:frame()
    
    -- 現在右半分にある場合
    if isRightHalf(win, screen) then
        -- 右の画面を探す
        local eastScreen = screen:toEast()
        if eastScreen then
            -- 右の画面の左半分に移動
            local eastFrame = eastScreen:frame()
            win:moveToScreen(eastScreen)
            win:setFrame({
                x = eastFrame.x,
                y = eastFrame.y,
                w = eastFrame.w / 2,
                h = eastFrame.h
            })
        else
            -- 右端にいる場合は、最も左の画面の左半分に移動
            local leftmostScreen = getLeftmostScreen()
            local leftmostFrame = leftmostScreen:frame()
            win:moveToScreen(leftmostScreen)
            win:setFrame({
                x = leftmostFrame.x,
                y = leftmostFrame.y,
                w = leftmostFrame.w / 2,
                h = leftmostFrame.h
            })
        end
    else
        -- 現在の画面の右半分に配置
        win:setFrame({
            x = screenFrame.x + screenFrame.w / 2,
            y = screenFrame.y,
            w = screenFrame.w / 2,
            h = screenFrame.h
        })
    end
end

-- 最大化（全画面）
function windowManagement.maximize()
    local win = hs.window.focusedWindow()
    if not win then return end
    
    local screen = win:screen()
    local screenFrame = screen:frame()
    
    win:setFrame(screenFrame)
end

return windowManagement