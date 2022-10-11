# RoImGui
A powerful, versatile and ridiculously easy-to-use immediate mode UI library for debugging and logging Roblox projects. RoImGui is a visual library for  testing and debugging of code through on-screen windows and panels which are hooked to anywhere in your project.

The library is based heavily, both in code and style, off [Dear ImGui](https://github.com/ocornut/imgui/), an open source immediate mode library for C++.

RoImGui is **not** designed for building front-end interfaces due to its limited individual control over the styling of UI elements. If you want to make a UI for players then I would recommend either [Fusion](https://github.com/Elttob/Fusion) by Elltob or [Roact](https://github.com/Roblox/roact/) by Roblox. 

## Immediate-Mode Graphical User Interface (ImGui)
Immediate-mode UIs are an entirely different way of developing UI compared to the much more common retain-mode UI frameworks. With immediate-mode UIs you do not need to manage the initialisation, updating or cleanup of UI elements or worry about managing state. Elements are created each frame and can be appended anywhere in the codebase.

# Install
You can use RoImGui by either:
- Installing the plugin to ensure RoImGui stays up-to-date: [RoImGui Plugin](https://www.roblox.com/develop)
- Downloading the .rbxm file from Itch.io: [Itch.io](https://www.itch.io)
- Downloading the latest .rbxm release from the GitHub releases: [Releases](https://github.com/SirMallard/RoImGui/releases)
- Building the project yourself: [Build](#build)


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

For more help, check out [the Rojo documentation](https://rojo.space/docs)."# RoImGui" 


# Issues

If you have any issues please open a GitHub issue and explain your issue with any outputs and reproducable steps.

# Credits
Developed by SirMallard: [Roblox Profile](https://www.roblox.com/users/165956092/profile)