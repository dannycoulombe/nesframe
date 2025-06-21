# NES 6502 Game Framework

A lightweight but powerful framework designed for building NES games using 6502 Assembly. This project provides a modular base for game development, complete with tools for map handling, actor management, collision detection, and advanced debugging with Mesen.

## Features

### Tile-Based Collision Detection

* Intelligent collision system that uses **surrounding tile influencers** to determine directional collisions.
* Designed to minimize CPU cycles while offering predictable and flexible behavior.

### Map Compression & NEXXT Integration

* Scripts to parse and compress **2x2 metatile maps** exported from [NEXXT](https://www.romhacking.net/utilities/1716/).
* Optimized for memory efficiency while maintaining tile clarity and organization.

### Actor Macros

* Easy-to-use macros to add and manage **actors** (player, enemies, NPCs) with minimal code.
* Supports positioning, state control, and update logic hooks.

### Metatile Animations

* Native support for **animated metatiles** with configurable frame sequences and timing.
* Suitable for water tiles, fire, glowing effects, etc.

### Mesen Debugging Toolkit

* Custom **Lua scripts for Mesen** to visualize and monitor:

    * Memory changes in real-time (hexdump, watchpoints)
    * State machine transitions
    * Tile-based collision zones
    * Event triggers and game logic flow

## Getting Started

1. Clone the repo and make sure you have `ca65`/`ld65` installed.
2. Build with the provided Makefile or script for your platform.
3. Use the included Lua scripts inside **Mesen** for advanced debugging.
4. Begin development using the example scene and actor macros.

## Tools & Dependencies

* [NEXXT](https://www.romhacking.net/utilities/1716/) (for tile editing)
* [Mesen](https://mesen.ca/) (for debugging)
* cc65 toolchain (ca65, ld65, etc.)

## Roadmap

* Scripting system for in-game events
* Sound driver integration
* Built-in sprite animation manager

## License

MIT — free to use and modify for any personal or commercial NES game projects.
