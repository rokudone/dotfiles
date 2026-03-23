# 実装計画: Hammerspoonウィンドウ切り替え機能

## 概要（日本語）

### 問題の説明
現在のwindow-management.luaは、小さいウィンドウがフォーカスされている時に、Alt+矢印キーを押しても他のウィンドウに切り替えることができない。代わりに、その小さいウィンドウを画面の半分にリサイズしてしまう。

### 期待される動作
- 小さいウィンドウから大きいウィンドウ（または他のウィンドウ）に切り替えられるようにする
- 矢印キーの方向に応じて、適切なウィンドウにフォーカスを移動する

### 解決方法
1. 現在のウィンドウが小さい（画面の半分ではない）場合、同じ画面または隣接する画面の他のウィンドウを探す
2. 方向に応じて最も適切なウィンドウにフォーカスを切り替える
3. 適切なウィンドウがない場合のみ、現在のウィンドウをリサイズする

### 実装チェックリスト
- [ ] ウィンドウ検索関数の実装（方向別）
- [ ] ウィンドウの位置関係を判定する関数の実装
- [ ] moveLeft/moveRight関数の修正
- [ ] エッジケースのテスト

## Technical Specification

### Implementation Overview
Add window switching capability to the existing window management system. When a small window is focused, the system should switch to other windows instead of resizing the current one.

### Key Features
1. **Direction-based Window Search**: Find windows in the specified direction
2. **Smart Window Selection**: Choose the most appropriate window based on position and size
3. **Fallback Behavior**: Resize current window only when no other windows are available
4. **Multi-screen Support**: Search across screens when appropriate

### Implementation Steps

#### 1. Add Window Search and Selection Functions
- [ ] Create `findWindowsInDirection(direction)` function
  - Get all visible windows
  - Filter by direction relative to current window
  - Sort by distance and relevance
- [ ] Create `getWindowCenter(win)` helper function
  - Calculate center point of window
  - Used for distance calculations
- [ ] Create `isWindowInDirection(targetWin, currentWin, direction)` function
  - Determine if target window is in the specified direction
  - Consider both x and y coordinates

#### 2. Modify Movement Functions
- [ ] Update `moveLeft()` function
  ```lua
  -- Pseudo-code structure
  if not isLeftHalf(win, screen) then
      -- Try to find another window to switch to
      local targetWindow = findWindowToLeft()
      if targetWindow then
          targetWindow:focus()
          return
      end
  end
  -- Continue with existing resize logic
  ```
- [ ] Update `moveRight()` function
  - Mirror the logic of moveLeft
  - Search for windows to the right

#### 3. Implement Window Finding Logic
- [ ] Create `findWindowToLeft()` function
  - Search current screen first
  - If not found, search screen to the left
  - Prioritize larger windows
  - Exclude minimized and hidden windows
- [ ] Create `findWindowToRight()` function
  - Mirror logic for right direction
  - Handle screen boundaries

#### 4. Add Configuration Options
- [ ] Add threshold for "small window" detection
- [ ] Option to disable window switching
- [ ] Customizable search behavior

### Code Structure
```lua
-- New utility functions
local function getWindowCenter(win)
local function calculateDistance(win1, win2)
local function isWindowInDirection(targetWin, currentWin, direction)
local function findWindowsInDirection(currentWin, direction)
local function selectBestWindow(windows, currentWin, direction)

-- Modified movement functions
function windowManagement.moveLeft()
    local win = hs.window.focusedWindow()
    if not win then return end
    
    local screen = win:screen()
    
    -- If not in left half, try to switch windows first
    if not isLeftHalf(win, screen) then
        local targetWindow = findWindowToLeft(win)
        if targetWindow then
            targetWindow:focus()
            return
        end
    end
    
    -- Continue with existing logic...
end
```

### Window Selection Criteria
1. **Direction**: Window must be in the correct direction
2. **Distance**: Closer windows are preferred
3. **Size**: Larger windows are prioritized
4. **Visibility**: Only consider visible, non-minimized windows
5. **Application**: Optionally prefer windows from different applications

### Testing Checklist
- [ ] Small window can switch to large window on same screen
- [ ] Window switching works across multiple screens
- [ ] Correct fallback to resize when no windows available
- [ ] Performance with many windows
- [ ] Edge cases: minimized windows, full-screen apps