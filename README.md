# arena-fps

A first-person arena shooter prototype built with Godot 4.5, focused on high-mobility movement and physics-driven combat.

## Project Structure

This project uses a responsibility-based organization where **actors**, **environment**, and **levels** have clearly defined roles.

### `/scenes`
Composable scene definitions.

- `actors/`
  - All gameplay entities that have behavior and can be spawned, destroyed, or reused
  - Includes the player, enemies, projectiles, and other interactive entities

- `environment/`
  - Static or semi-static world context
  - World geometry, lighting, sky, fog, and post-processing
  - Defines the visual and physical stage actors exist within

- `ui/`
  - HUD elements and screen overlays

### `/levels`
Complete gameplay compositions.

A level represents a single playable scenario and is responsible for:
- instantiating an environment
- placing or spawning actors
- defining spawn points, objectives, and match rules

Levels compose actors and environment but do not define actor behavior.

### `/scripts`
All GDScript source code.

- `actors/`
  - Logic for all actor types, including player, enemies, and projectiles
- `ui/`
  - HUD and UI logic

Scripts are organized to mirror scene ownership where possible.

### `/resources`
Godot resources (`.tres`, `.res`) and their supporting scripts.

Used for:
- gameplay data (e.g. projectile definitions)
- configuration and tunable parameters

### `/assets`
Authored binary assets.

- `art/` -  textures, graphics
- `audio/` - sound effects, music
- `models/`, `shaders/`, etc.

### `/addons`
Third-party Godot plugins.

## Running the Project

1. Open Godot 4.5
2. Open this repository folder
3. Press Play
