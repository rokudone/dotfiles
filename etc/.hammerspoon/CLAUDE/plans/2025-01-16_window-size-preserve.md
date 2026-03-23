# 実装計画: Hammerspoonウィンドウサイズ保持機能

## 概要（日本語）

### 問題の説明
現在のwindow-management.luaは、ウィンドウを移動する際に必ず画面の半分サイズに強制的にリサイズしてしまう。これにより、小さいウィンドウや特定のサイズのウィンドウを移動する際に、意図しないサイズ変更が発生する。

### 解決方法
1. ウィンドウの元のサイズを保持しながら移動する新しい関数を追加
2. キーバインディングに修飾キーを追加して、サイズ保持モードと自動リサイズモードを切り替え可能にする
3. 小さいウィンドウ（画面の25%未満）に対する特別な処理を実装

### 実装チェックリスト
- [ ] window-management.luaのバックアップを作成
- [ ] サイズ保持用の新しい移動関数を実装
- [ ] キーバインディングの修正（Shift追加でサイズ保持モード）
- [ ] 小さいウィンドウの判定関数を追加
- [ ] エッジケースのテスト（複数モニター、極小ウィンドウなど）

## Technical Specification

### Implementation Overview
The current window management system forces windows to resize to half-screen when moving. This implementation will add size-preserving movement functions while maintaining backward compatibility with existing behavior.

### Key Features
1. **Size-Preserving Movement**: New functions that maintain original window dimensions
2. **Modifier Key Support**: Shift+Alt for size-preserving mode, Alt only for resize mode
3. **Small Window Detection**: Special handling for windows smaller than 25% of screen area
4. **Multi-Monitor Support**: Proper size calculation when moving between screens

### Implementation Steps

#### 1. Add Helper Functions for Window Size Management
- [ ] Create `preserveWindowSize()` function to store current dimensions
- [ ] Create `isSmallWindow()` function to detect windows < 25% of screen
- [ ] Create `calculateRelativePosition()` for cross-screen movement

#### 2. Implement Size-Preserving Movement Functions
- [ ] Create `moveLeftPreserveSize()` function
  - Get current window frame
  - Calculate new position maintaining size
  - Handle screen boundaries
  - Apply frame with original dimensions
- [ ] Create `moveRightPreserveSize()` function
  - Mirror logic of moveLeftPreserveSize
  - Handle right screen edge cases
- [ ] Create `moveToScreenPreserveSize()` function
  - Calculate relative position on new screen
  - Scale dimensions if new screen is smaller
  - Maintain aspect ratio

#### 3. Modify Existing Functions for Backward Compatibility
- [ ] Add optional `preserveSize` parameter to existing functions
- [ ] Default to current behavior when parameter is false/nil
- [ ] Refactor duplicate code into shared utility functions

#### 4. Update Key Bindings in init.lua
- [ ] Alt+Left: Current behavior (resize to half)
- [ ] Shift+Alt+Left: Size-preserving left movement
- [ ] Alt+Right: Current behavior (resize to half)
- [ ] Shift+Alt+Right: Size-preserving right movement
- [ ] Add help notification for new bindings

#### 5. Handle Edge Cases
- [ ] Prevent windows from becoming inaccessible off-screen
- [ ] Handle windows larger than target screen
- [ ] Manage floating windows and dialogs properly
- [ ] Test with Alacritty special case

### Code Structure
```lua
-- New utility functions
local function getWindowSizeRatio(win)
local function isSmallWindow(win, threshold)
local function preserveWindowFrame(win, newScreen, position)

-- Modified movement functions
local function moveLeft(preserveSize)
local function moveRight(preserveSize)
local function moveToScreen(win, screen, position, preserveSize)

-- New movement functions
local function moveLeftPreserveSize()
local function moveRightPreserveSize()
```

### Testing Checklist
- [ ] Single monitor: size preservation works correctly
- [ ] Multi-monitor: windows scale appropriately
- [ ] Small windows: maintain size and position
- [ ] Edge cases: windows stay accessible
- [ ] Performance: no lag or delays