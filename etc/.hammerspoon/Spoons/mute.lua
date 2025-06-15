muteAlertId = nil

-- Clear the alert if exists to avoid notifications stacking
local function clearMuteAlert()
  if muteAlertId then
    hs.alert.closeSpecific(muteAlertId)
  end
end

-- Hold the hotkey for Push To Talk
local holdingToTalk = false
local function pushToTalk()
  holdingToTalk = true
  local audio = hs.audiodevice.defaultInputDevice()
  local muted = audio:inputMuted()
  if muted then
    clearMuteAlert()
    muteAlertId = hs.alert.show("🎤 Microphone on", true)
    audio:setInputMuted(false)
  end
end

-- Toggles the default microphone's mute state on hotkey release
-- or performs PTT when holding down the hotkey
local function toggleMuteOrPTT()
  local audio = hs.audiodevice.defaultInputDevice()
  local muted = audio:inputMuted()
  local muting = not muted
  if holdingToTalk then
    holdingToTalk = false
    audio:setInputMuted(true)
    muting = true
  else
    audio:setInputMuted(muting)
  end
  clearMuteAlert()
  if muting then
    muteAlertId = hs.alert.show("📵 Microphone muted")
  else
    muteAlertId = hs.alert.show("🎤 Microphone on")
  end
end

-- `⌘ ⇧ A` but you could also map to F13 for a macropad
hs.hotkey.bind({"cmd", "shift"}, "a", nil, toggleMuteOrPTT, pushToTalk)
