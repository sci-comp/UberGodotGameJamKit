# Godot-Blender RPG Framework

## Welcome early visitor

This project has just been started! Come back soon!

![demo](./Documentation/Image/Demo.png)

## Introduction

This repository is a collection of freely usable art, scripts, and sounds that hopes to benefit many projects.

### Purpose and structure

The primary goal of the Godot-Blender RPG Framework is to serve as a way to test the contents of the StandardAssets repository. We will do this by creating a small mini-game, a single quest for the player to accomplish.

#### Standard Assets
The StandardAssets repository is a submodule that aims to be a lightweight and reusable collection of scripts, textures, materials, and so on. Since I use this submodule for my owns games, any form of feedback or collaboration is greatly appreciated.

#### Editor Toolbox

Also included here is the EditorToolbox submodule, which is a collection of editor-time utilities. In addition to being a sort of grab-bag full of productivity tools, there are scripts included that suggest a workflow for mesh and materials between Blender and Godot. Please see [glb_post_import.gd](https://github.com/sci-comp/EditorToolbox/blob/main/Import/glb_post_import.gd) for more information.

## Dependency

This project assumes that the following have already been added to your project,

- [Godot Dialogue Manager](https://github.com/nathanhoad/godot_dialogue_manager)

## Installation

Simply type,

`git clone https://github.com/sci-comp/GodotBlenderRPGFramework

or use Github Desktop. By cloning, submodules will automatically be included.

### Submodules

Links to submobule repositories,

- EditorToolbox  [link](https://github.com/sci-comp/EditorToolbox)
- StandardAssets  [link](https://github.com/sci-comp/StandardAssets)

### Adding and Removing Submodules

Although the Godot-Blender RPG Framework already has submodules added, you will need to add them yourself if you start from a new project. The following commands serve as helpful reminders.

Note for Github Desktop users: Github Desktop cannot add or remove submodules. However, once a submodule has been added through the console, we can manage it from within the Github Desktop UI.

We can add submodules with,

	- git submodule add --force https://github.com/sci-comp/ExampleSubmodule addons/ExampleSubmodule
	- git submodule init
	- git submodule update

We remove submodules with,

	- git submodule deinit -f addons/ExampleSubmodule
	- git rm --cached addons/ExampleSubmodule
	- rm -r addons/ExampleSubmodule

If you delete a submodule without first calling submodule deinit, which is an easy mistake to make, then we have to manully remove the submodule references in the following locations,

	- ./.git/config
	- ./.git/modules/

## License

All included or references content was originally licensed as MIT or cc0. Please see license.txt files in their respective folders for more information. A summary of imported and referenced content is also below,

### Standard Assets

- The lookup tables for color grading come from this project: https://github.com/thiagoamendola/godot-color-lut-shader
- The saver was forked from: https://github.com/Ardot66/SaveAccess/tree/main
- The scene manager used the following repository for guidance: https://github.com/glass-brick/Scene-Manager
- Nathan Hoad's Godot Dialogue Manager: https://github.com/nathanhoad/godot_dialogue_manager

### Demo content

- FlynnCat: https://flynncat.itch.io/mrd-terrain
- Kenney: https://kenney.itch.io/
- Sound files by FilmCow

