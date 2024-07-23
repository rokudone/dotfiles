on run argv
    if (count of argv) is 0 then
        return
    end if

    set appName to item 1 of argv

    -- .appの拡張子を削除
    if appName ends with ".app" then
        set appName to text 1 thru -5 of appName
    end if

    tell application "System Events"
        try
            -- アプリケーションが実行中かチェック
            if not (exists process appName) then
                tell application appName to activate
                delay 2 -- アプリケーションの起動を待つ
            end if

            tell process appName
                set frontmost to true
                delay 1 -- アプリケーションがアクティブになるのを待つ

                -- フルスクリーンが可能なウィンドウを探す
                set targetWindow to first window whose subrole is "AXStandardWindow"
                set value of attribute "AXFullScreen" of targetWindow to true
            end tell
        end try
    end tell
end run
