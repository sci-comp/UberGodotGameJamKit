# Godot-Standard-Assets

## Welcome early visitor

This project has just been started! Come back soon!

![demo](./Documentation/Image/demo.png)

## Introduction

This repository is a collection of freely usable art, scripts, and sounds that hopes to benefit many projects.

This project is currently empty, it serves as a base for addons. A scene will soon be added that demonstrates how to use multiple addons together.

Since advanced users often have their own solutions, I hope that a modular approach will enable collaboration between many different projects.

## Installation

### Creating an empty project

	- For new users, I would recommend GitHub Desktop as a way to manage your new project.
	- After installing GitHub Desktop, go to github.com -> Repositories -> New, and set up an empty repository for your game.
	- In GitHub Desktop, clone your new empty respository.

### Adding submodules

#### Why Submodules?

You do not need to add repositories as a submodule. You can simply download a project from github as a zip file, then unpack /addons into your project. Some addons are available through Godot's UI in the AssetLib tab.

Howver, submodules managed with GitHub Desktop are a very convenient way to keep your project up-to-date with the main branch.

#### How-to

We need to add and remove submodules manually before opening them locally in the Github Desktop application.

We can add submodules by opening up the console and typing,

	- git submodule add --force https://github.com/sci-comp/ExampleSubmodule addons/ExampleSubmodule
	- git submodule init
	- git submodule update

We remove submodules by typing,

	- git submodule deinit -f addons/ExampleSubmodule
	- git rm --cached addons/ExampleSubmodule
	- rm -r addons/ExampleSubmodule

If you delete a submodule without first calling submodule deinit, which is an easy mistake to make, then we have to manully remove the submodule references in the following locations,

	- ./.git/config
	- ./.git/modules/

#### Recommended submodules

For new projects, I think the following submodules work well together.

- EditorToolbox  [link](https://github.com/sci-comp/EditorToolbox)
- StandardAssets  [link](todo)

## License

Most content is either MIT or cc0. Please see license.txt files in their respective folders for more information.

#### CC0 content
	
	FlynnCat: https://flynncat.itch.io/mrd-terrain
	Kenney: https://kenney.itch.io/

#### CC-BY content
	
The water shader is originally by Polyflare
	License: CC-BY 4.0
	URL: https://creativecommons.org/licenses/by/4.0/

#### MIT content

	https://github.com/selgesel/godot4-third-person-controller
