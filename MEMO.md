# Custom Key Map Set for Windows
- Win + R -> regedit
- HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout
- Make new binary file named `ScanCode Map`
- Type following
```
00 00 00 00 00 00 00 00
02 00 00 00 1D 00 3A 00
00 00 00 00
```

# New PC setting
- Wallpaper
- Chrome setting
- Teamviewer
- Kakaotalk
- Everything
- Webcam
- nvim setting
    - scoop
    - nvim
    - init.lua (AppData/Local/nvim/init.lua)
    - ripgrep
    - gcc
    - nodejs
    - JetbrainsMono Nerd Font
    - TeX Live (scheme-small with korean and bibtex option selected)
    - nvr (pip install neovim-remote in default python env)
    - sumatrapdf (EnableTeXEnhancements = true) (`nvr.exe --remote-silent +"%l" "%f"` in inverse search setting)
    - latexmk (tlmgr install latexmk)
- Git setting
- Cursor
- Miniconda
- Zoom
- ScreentoGif
- Bandizip
- Printer connect
- Screenshot setting
- Scone

# Sumatrapdf (<= v3.6)
InverseSearchCmdLine = nvr.exe --remote-silent +"%l" "%f"
EnableTeXEnhancements = true
Shortcuts [
	[
		Cmd = CmdScrollDown 5
		Key = j
	]
	[
		Cmd = CmdScrollUp 5
		Key = k
	]
	[
		Cmd = CmdScrollDownHalfPage
		Key = d
	]
	[
		Cmd = CmdScrollUpHalfPage
		Key = f
	]
	[
		Cmd = CmdGoToFirstPage
		Key = g
	]
	[
		Cmd = CmdGoToLastPage
		Key = G
	]
	[
		Cmd = CmdNextTab
		Key = Right
	]
	[
		Cmd = CmdPrevTab
		Key = Left
	]
]
SmoothScroll = true
