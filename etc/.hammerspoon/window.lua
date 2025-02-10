-- アニメーションを無効化
hs.window.animationDuration = 0

-- ウィンドウの現在の状態を判断する関数
local function getCurrentWindowState(win)
    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    -- 位置とサイズの比率を計算
    local widthRatio = math.floor((f.w / max.w) * 100 + 0.5)
    local heightRatio = math.floor((f.h / max.h) * 100 + 0.5)
    local xRatio = math.floor(((f.x - max.x) / max.w) * 100 + 0.5)
    local yRatio = math.floor(((f.y - max.y) / max.h) * 100 + 0.5)

    local state = "unknown"

    -- 左側の判定
    if xRatio < 1 then
        if widthRatio >= 45 and widthRatio <= 55 then
            if heightRatio >= 95 then
                state = "left-full"
            elseif heightRatio >= 45 and heightRatio <= 55 then
                if yRatio < 1 then
                    state = "left-top"
                else
                    state = "left-bottom"
                end
            end
        end
    end

    -- 右側の判定
    if xRatio >= 45 and xRatio <= 55 then
        if widthRatio >= 45 and widthRatio <= 55 then
            if heightRatio >= 95 then
                state = "right-full"
            elseif heightRatio >= 45 and heightRatio <= 55 then
                if yRatio < 1 then
                    state = "right-top"
                else
                    state = "right-bottom"
                end
            end
        end
    end

    -- 状態が不明な場合は、x座標で左右どちらかを判断
    if state == "unknown" then
        if xRatio < 50 then
            state = "left-unknown"
        else
            state = "right-unknown"
        end
    end

    return state
end

-- 左側のウィンドウ操作
hs.hotkey.bind({"alt"}, "left", function()
    local win = hs.window.focusedWindow()
    if not win then return end

    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    local currentState = getCurrentWindowState(win)

    if currentState:find("^right") then
        -- 右側から来た場合は左半分に
        f.x = max.x
        f.y = max.y
        f.w = max.w / 2
        f.h = max.h
    else
        -- 左側の状態を循環
        if currentState == "left-unknown" or currentState == "left-bottom" then
            -- 左半分
            f.x = max.x
            f.y = max.y
            f.w = max.w / 2
            f.h = max.h
        elseif currentState == "left-full" then
            -- 左上1/4
            f.x = max.x
            f.y = max.y
            f.w = max.w / 2
            f.h = max.h / 2
        elseif currentState == "left-top" then
            -- 左下1/4
            f.x = max.x
            f.y = max.y + (max.h / 2)
            f.w = max.w / 2
            f.h = max.h / 2
        end
    end

    win:setFrame(f)
end)

-- 右側のウィンドウ操作
hs.hotkey.bind({"alt"}, "right", function()
    local win = hs.window.focusedWindow()
    if not win then return end

    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()
    local nextScreen = screen:next()

    local currentState = getCurrentWindowState(win)

    if currentState:find("^left") then
        -- 左側から来た場合は右半分に
        f.x = max.x + (max.w / 2)
        f.y = max.y
        f.w = max.w / 2
        f.h = max.h
    else
        -- 右側の状態を循環
        if currentState == "right-unknown" or currentState == "right-bottom" then
            -- 右半分
            f.x = max.x + (max.w / 2)
            f.y = max.y
            f.w = max.w / 2
            f.h = max.h
        elseif currentState == "right-full" then
            -- 右上1/4
            f.x = max.x + (max.w / 2)
            f.y = max.y
            f.w = max.w / 2
            f.h = max.h / 2
        elseif currentState == "right-top" then
            -- 右下1/4
            f.x = max.x + (max.w / 2)
            f.y = max.y + (max.h / 2)
            f.w = max.w / 2
            f.h = max.h / 2
        end
    end

    win:setFrame(f)
end)

-- ディスプレイ間移動と全画面化
hs.hotkey.bind({"alt"}, "up", function()
    local win = hs.window.focusedWindow()
    if not win then return end

    local screen = win:screen()
    local max = screen:frame()
    local f = win:frame()

    -- 現在のウィンドウが全画面かどうかを判定
    local isFullScreen = math.floor((f.w / max.w) * 100 + 0.5) >= 95 and
                        math.floor((f.h / max.h) * 100 + 0.5) >= 95

    if isFullScreen then
        -- 全画面の場合は次のスクリーンに移動
        local nextScreen = screen:next()
        win:moveToScreen(nextScreen)
        win:setFrame(nextScreen:frame())
    else
        -- 全画面でない場合は現在のスクリーンで全画面化
        win:setFrame(max)
    end
end)

-- 1/3-2/3トグル
hs.hotkey.bind({"alt"}, "down", function()
    local win = hs.window.focusedWindow()
    if not win then return end

    local f = win:frame()
    local screen = win:screen()
    local max = screen:frame()

    -- 現在のウィンドウの位置と幅を計算
    local xRatio = math.floor(((f.x - max.x) / max.w) * 100 + 0.5)
    local widthRatio = math.floor((f.w / max.w) * 100 + 0.5)

    -- サイズ計算用の定数
    local thirdWidth = max.w / 3
    local twoThirdsWidth = (max.w / 3) * 2

    -- 現在の状態を判断して次の状態に移動
    if xRatio < 1 then
        if widthRatio >= 32 and widthRatio <= 34 then
            -- 左1/3から左2/3へ
            f.x = max.x
            f.w = twoThirdsWidth
        else
            -- 左2/3から中央へ
            f.x = max.x + thirdWidth
            f.w = thirdWidth
        end
    elseif xRatio >= 32 and xRatio <= 34 and widthRatio >= 32 and widthRatio <= 34 then
        -- 中央から右2/3へ
        f.x = max.x + thirdWidth
        f.w = twoThirdsWidth
    elseif xRatio >= 32 and xRatio <= 34 and widthRatio >= 65 and widthRatio <= 67 then
        -- 右2/3から右1/3へ
        f.x = max.x + (thirdWidth * 2)
        f.w = thirdWidth
    else
        -- それ以外の場合は左1/3へ
        f.x = max.x
        f.w = thirdWidth
    end

    -- 高さと垂直位置は常に画面いっぱいに
    f.y = max.y
    f.h = max.h

    win:setFrame(f)
end)