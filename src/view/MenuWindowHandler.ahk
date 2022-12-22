﻿;Handles changes to the menu
class MenuWindowHandler {
	static menuGui
	static totalScreenWidth, totalScreenHeight
	static guiWidth, guiHeight
	static reloadOnHide := False
	__New(menuGui) {
		this.menuGui := menuGui
		hideGuiOnOutsideClickFn := ObjBindMethod(this, "watchMouseClickAndHideGuiOnOutsideClick")
		Hotkey, ~LButton, % hideGuiOnOutsideClickFn
		Hotkey, ~LButton, Off

		CoordMode, Mouse, Screen
		SysGet, tmp, 78
		this.totalScreenWidth := tmp
		SysGet, tmp, 79
		this.totalScreenHeight := tmp
	}

	watchMouseClickAndHideGuiOnOutsideClick() {
		MouseGetPos, , , windowClicked, controlClicked
		if(controlClicked = "ListBox1") {
			Sleep, 100 ;allows time for Gui to show what was selected
			this.hideMenuGui(playFadeAnimation := False)
			this.menuGui.menuClipsViewHandler.pasteSelectedClip()
			this.resetGuiState()
		} else if(windowClicked = this.menuGui.HANDLE_GUI) {
			return
		} else {
			this.hideMenuGui()
			this.resetGuiState()
		}
	}

	showGui() {
		GuiControl, Focus, % this.menuGui.HANDLE_SEARCH_BOX
		GuiControl, Choose, % this.menuGui.HANDLE_CLIPS_VIEW, 1
		Hotkey, ~LButton, On

		MouseGetPos, mouseXPos, mouseYPos
		dispXPos := % mouseXPos + this.guiWidth > this.totalScreenWidth ? mouseXPos - this.guiWidth : mouseXPos
		dispYPos := % mouseYPos + this.guiHeight > this.totalScreenHeight ? mouseYPos - this.guiHeight : mouseYPos
		Gui ClipMenu:Show, AutoSize x%dispXPos% y%dispYPos%
		WinSet, Transparent, Off, % "ahk_id " this.menuGui.HANDLE_GUI
		this.handleKeyPresses()
	}

	handleKeyPresses() {
		Input, tmp, V, {Esc}{LWin}{RWin}{AppsKey}{LAlt}{RAlt}{Up}{Down}{Delete}
		if(InStr(ErrorLevel, "EndKey:")) {
			if(InStr(ErrorLevel, "Up")) {
				GuiControl, Focus, % this.menuGui.HANDLE_CLIPS_VIEW
				Send, {Up}
				GuiControl, Focus, % this.menuGui.HANDLE_SEARCH_BOX
			} else if(InStr(ErrorLevel, "Down")) {
				GuiControl, Focus, % this.menuGui.HANDLE_CLIPS_VIEW
				Send, {Down}
				GuiControl, Focus, % this.menuGui.HANDLE_SEARCH_BOX
			} else if(InStr(ErrorLevel, "Delete")) {
				GuiControl, Focus, % this.menuGui.HANDLE_CLIPS_VIEW
				selectedClipIndex := GetControlValue(this.menuGui.HANDLE_CLIPS_VIEW)
				if (selectedClipIndex >0) {
					this.menuGui.menuClipsViewHandler.deleteItemAtIndex(selectedClipIndex)
					this.menuGui.clipStore.deleteAtIndex(selectedClipIndex)
					Send, {Down}
				}
				GuiControl, Focus, % this.menuGui.HANDLE_SEARCH_BOX
			} else {
				this.hideMenuGui()
				this.resetGuiState()
				return
			}
			this.handleKeyPresses()
		}
	}

	hideMenuGui(playFadeAnimation := True) {
		; if(playFadeAnimation) {
		; 	Loop, % loopIndex := 10
		; 	{
		; 		WinSet, Transparent, % loopIndex-- * 25, % "ahk_id " this.menuGui.HANDLE_GUI
		; 		Sleep 25
		; 	}
		; }
		Gui ClipMenu:Hide
		if(this.reloadOnHide) {
			Reload
		}
	}

	resetGuiState() {
		GuiControl, , % this.menuGui.HANDLE_SEARCH_BOX
		Input
		Hotkey, ~LButton, Off
		Send, {Ctrl up} ;depresses Ctrl if you're using Ctrl in the showMenu shortcut
	}

	updateGuiDims() {
		Gui ClipMenu:Show, Hide ;Renders it once to give it dimensions for the handler to use
		GetGuiSize(this.menuGui.HANDLE_GUI, guiWidth, guiHeight)
		this.guiWidth := guiWidth
		this.guiHeight := guiHeight
	}
}