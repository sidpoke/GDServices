# GDServices - Dynamic Godot Globals

A globally unique service locator with a static API using `[Script]` as keys.\
Untangle your dependencies. Create purposeful, scoped globals.\
(Example scripts folder will follow, for now there's only this readme)

## Benefits & Reasons
If you’ve ever tried managing autoload singletons across scenes, menus, gameplay, and tools,
you’ve probably seen how quickly dependencies get messy.

```GDScript
# MainMenu.gd
extends Node

func _ready():
	# Why can I even access this here?
	GameManager.player_profile.name = "Fox"
	GameManager.sound_system.play_music("menu_theme")
```
>The main menu doesn’t need any of those systems, yet it can freely mutate the entire game state.

With GDServices, dependency management becomes a little easier, and is pretty lightweight compared to a full DI-Container solution.\
Services can be dynamically and uniquely loaded and unloaded within a Global-, Scene-, or Node-Lifecycle.\
This is **similar** to how Autoloads work in Godot, however doesn't support adding or removing Autoloads during runtime. GDServices does.\
You can register `@abstract` base classes for true inversion of control, decoupling your code from specific implementations.

```GDScript
# GameLifecycle.gd
extends Node
@export var game_manager : GameManager

func _exit_tree() -> void:
  Services.register(game_manager)

func _exit_tree() -> void:
  Services.unregister(game_manager)

# ....Somewhere in a different scene, where the main game is not loaded....
# MainMenu.gd
extends Node

func _ready() -> void:
  var game_manager = Services.get_service(GameManager)
  # Runtime Error -> Service was not found in the scene because it was not registered.
```
>We can create scene-scoped globals, this way you guard your classes from unwanted mutation.

## Setup
Simply download [Services.gd](/Services.gd) and place it anywhere into your project, no Autoload needed.\
Full documentation is provided with the Script.

## Usage
Using the service locator is incredibly easy.

### Example for registering a service
```GDScript
@export var settings_system : SimpleSettingsSystem

func _exit_tree() -> void:
  # Register 'as-is' with Node's script type
  Services.register(settings_system)
  # Alternative: register as abstract class
  Services.register_as(settings_system, SettingsSystem)
  # Unrecommended, but possible (this causes hard-coupling again)
  Services.register(self)

func _exit_tree() -> void:
  # Unregister 'as-is' with Node's script type
  Services.unregister(settings_system) 
  # Alternative: Unregister abstract class
  Services.unregister_as(SettingsSystem) 
```

### Example for fetching a service**
```GDScript
#Within a function, fetches only once (more performant!)
func _ready -> void: 
  var _main_menu = Services.get_service(MainMenuMode) as MainMenuMode 

#Fetches every time when referenced using getter field
var _main_menu: MainMenu: 
  get: return Services.get_service(MainMenuMode) as MainMenuMode
```

### Remarks
- Do not use `Services.get_service` in a Node's `_init` function as it might not yet be initialized.
- It is advised to use `_enter_tree` to register nodes and `_exit_tree` to unregister.
- It is advised to register abstract base classes instead of direct implementations.
- It is advised to use `Services.get_service` only during or after `_ready` in the Node's lifecycle.

## Risks
Register Nodes sparingly, a Service Locator hides dependencies actively (as do Singletons) and they can cause setup overhead when writing unit tests.\
Dependency injection is a more scalable choice than the service locator, but a big improvement over Singletons, as they allow IoC.\
Service Locators are accused of breaking the Interface-Segregation Principle, you should inform yourself what you're getting into when choosing this.\
Overall i would personally recommend this for small to medium sized projects. For me, i use this in almost all my games.

