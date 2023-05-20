# RoImGui
A powerful, versatile and ridiculously easy-to-use immediate mode UI library for Roblox projects. RoImGui is a visual library for testing and debugging of code through on-screen windows and panels which are hooked to anywhere in your project.

[RoImGui Preview Window]

| [**RoImGui**](https://github.com/SirMallard/RoImGui) |
| :- |
| [About](#about) - [Features](#features) |
| [Images]() - [Releases](#releases) |
| [Install](#install) - [Build](#build) |
| [Contriubte](#contribute) - [Credits](#credits) |



# About

The library is based heavily, both in code and style, off [Dear ImGui](https://github.com/ocornut/imgui/), an open source immediate mode library for C++.

RoImGui is **not** designed for building front-end interfaces due to its limited individual control over the styling of UI elements. If you want to make a UI for players then I would recommend either [Fusion](https://github.com/Elttob/Fusion) by Elttob or [Roact](https://github.com/Roblox/roact/) by Roblox. 

## Immediate-Mode Graphical User Interface (ImGui)
Immediate-mode UIs are an entirely different way of developing UI compared to the much more common retain-mode UI frameworks. With immediate-mode UIs you do not need to manage the initialisation, updating or cleanup of UI elements or worry about managing state. Elements are created each frame and can be appended to anywhere in the codebase.



# Features

- [ ] Window
  - [x] Title
    - [x] Collapsing
    - [x] Close
    - [x] Double-click Close
  - [x] Menubar
    - [ ] Dropdown
  - [x] Frame
  - [x] Moving
  - [x] Resizing
- [ ] Text
  - [x] Text
  - [x] Indent
  - [x] Disabled
  - [x] Bullet
  - [x] Coloured
  - [x] Tree Node
  - [ ] Selectable
- [ ] Button
  - [x] Button
  - [x] Coloured Button
  - [ ] Arrow Button
  - [ ] Repeat Button
  - [ ] Disabled
  - [x] Checkbox
  - [x] Radio
- [ ] Input
  - [ ] Combobox
  - [ ] Listbox
  - [x] Text
  - [x] Number
    - [x] Integer or Float
    - [ ] Increment
    - [ ] Drag
  - [ ] Vector2
    - [ ] Integer or Float
    - [ ] Increment
    - [ ] Drag
  - [ ] Vector3
    - [ ] Interger or Float
    - [ ] Increment
    - [ ] Drag
  - [ ] Enum
  - [ ] Color3
- [ ] Table
- [ ] Ploting
  - [ ] Line
  - [ ] Histogram
  - [ ] Progress
- [x] Collapsing Header
  - [x] Collapsing
  - [x] Closing



# Releases
The latest release is version 0.1.0-alpha and can be found [here](https://github.com/SirMallard/RoImGui/releases).

The changelog can be found [here](/CHANGELOG.md).

The version naming scheme uses [Semantic Version 2.0.0](https://semver.org/spec/v2.0.0.html).



# Install
You can use RoImGui by either:
- Installing the plugin to ensure RoImGui stays up-to-date: [RoImGui Plugin](https://www.roblox.com/develop)
- Downloading the .rbxm file from Itch.io: [Itch.io](https://www.itch.io)
- Downloading the latest .rbxm release from the GitHub releases: [Releases](https://github.com/SirMallard/RoImGui/releases)
- Building the project yourself: [Build](#build)



# Contribute
RoImGui is designed to produce a very similar experience to [Dear ImGui](https://github.com/ocornut/imgui) and thus the API and Style is a very near copy.

## Bugs
If you find a bug, ensure that there is not already a bug report, especially if it is not on the latest release. If it is a new bug then [open an issue](https://github.com/SirMallard/RoImGui/issues/new). Make the title clear and concise and include as much detail possible in the description including full reproduction steps and any images or videos relevant to the bug. If you cannot reproduce the bug multiple times then it is unlikely that I can help. If you realise the issue was on your side, then you can just close the issue.

## Tweaks
I will undoubtedly make spelling mistakes and inconsistencies in the documentation and code for RoImGui. You can open up an issue or make a [pull request](#pull-requests) if you want to update it yourself.

## New Features
There are so many features I can add at a time. For now, these features are based off what is included in [Dear ImGui](https://github.com/ocornut/imgui/) which may be altered to work in Roblox. Check that your features is not already in [Features](#features) before requesting it to be added. I may add your request to the list so that I can work on it later. Alternatively, you can code it yourself and submit a [pull request](#pull-requests).

## Pull Requests
If you want to add code to the project then ensure that you are using StyLua to style check your code before typing. Please read through my code to see my coding style. Commits have a specific style and follow the scheme below:
```
👆 [MAIN POINTS]

✨ New features:
	[NEW ADDITIONS]

🔧 Tweaks, changes and bug-fixes:
	[NOT-NEW ADDITIONS]

😡 Known bugs and issues to fix:
	[NEW BUG AND ISSUE ADDITIONS]
```
For example, the folling merge uses:
- a relatively short description of each change or addition.
  - documentation even though it may be small 
- [an emoji for each line](https://youtu.be/HkdAHXoRtos?t=259) which is relevant to the feaure.
- except for the `✨ New features:` or `🔧 Tweaks, changes and bug-fixes:` lines which are unchanged.
```
✏️ Text and Indents

✨ New features:
	✏️ New :Text() API to create text directly in the window!
	👉 Indent and Unindent text.
	🖼️ Window frame background.
	🪟 Debug window with Id and Window statuses.

🔧 Tweaks, changes and bug-fixes:
	🖨️ Fixed the font API and centralised it in the Style.lua file.
	🌈 Created some default variables for black and white.
	🖱️ Moved DrawCursor to be on a per-element basis rather than per-window.
	🖼️ ElementFrames are now appended and popped from a stack to place items.
	🟦 Window titles will maintain width when collapsed.
	💡 Fixed flickering of elements by moving cleanup to the end so deleted elements would not be rendered.
	↖️↘️ Instances now use scale to preserve size when resizing.
```



# Build
The library was developed and tested using Rojo but any tool to convert .lua files into Roblox should work.

## Rojo

If you want to build the library yourself, you will need to have [rojo](https://github.com/rojo-rbx/rojo) installed on your system and added as an environment variable.

### Build library

1. Download the source code in the latest [release](https://github.com/SirMallard/RoImGui/releases).

2. Build the library using Rojo:

	```bash
	rojo build -o RoImGui.rbxmx .\model.project.json
	```

3. Drag and drop the file into Studio.

### Build development place

1. Download the source code in the latest [release](https://github.com/SirMallard/RoImGui/releases).

2. Build the development place:

	```bash
	rojo build -o RoImGui.rbxlx .\development.project.json
	```

3. Open the place: 

	```bash
	.\RoImGui.rbxlx
	```

4. Connect using Rojo:

	```bash
	rojo serve .\development.project.json
	```

For more help, check out [the Rojo documentation](https://rojo.space/docs). 



# Credits
Developed by SirMallard:
- Roblox: [ThePyooterMallard](https://www.roblox.com/users/165956092/profile)
- Discord: SirMallard#3908