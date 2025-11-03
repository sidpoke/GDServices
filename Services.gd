class_name Services
extends RefCounted

## A globally unique service locator with a static API using [Script] as keys.
##
##[b]Example for registering a service[/b]
##[codeblock]
##	@export var settings_system : SimpleSettingsSystem
##
##func _exit_tree() -> void:
##	# register 'as-is' with Node's script type
##	Services.register(settings_system)
##	# Alternative: register as abstract class
##	Services.register_as(settings_system, SettingsSystem)
##
##func _exit_tree() -> void:
##	# Unregister 'as-is' with Node's script type
##	Services.unregister(settings_system) 
##	# Alternative: Unregister abstract class
##	Services.unregister_as(SettingsSystem) 
##[/codeblock][br]
##
##[b]Example for fetching a service[/b]
##[codeblock]
### Within a function, fetches only once (more performant!)
##func _ready -> void: 
##	var _main_menu = Services.get_service(MainMenuMode) as MainMenuMode 
##
### Fetches every time when referenced using getter field
##var _main_menu: MainMenu: 
##	get: return Services.get_service(MainMenuMode) as MainMenuMode
##[/codeblock]
##[br]
##[b]Remarks[/b][br]
## - Do not use get_service in a Node's _init function as it might not yet be initialized.[br]
## - It is advised to use _enter_tree to register nodes and _exit_tree to unregister.[br]
## - It is advised to register abstract base classes instead of direct implementations.[br]
## - It is advised to use Services.get_service only during or after _ready in the Node's lifecycle..[br]
##[br]
##[b][u]Metadata[/u][/b] [br]
##[b]Author:[/b] Jonas Walter aka. sidpoke [br]
##[b]Social:[/b] [url]https://bsky.app/profile/sidpoke.art[/url] [br]
##[b]Version:[/b] 1.0.0 [br]
##[b]Since:[/b]  2025-03-11 (3rd of November, 2025) [br]
##[b]Last_modified:[/b] 2025-03-11 (3rd of November, 2025) [br]
##[b]License:[/b] MIT [br]
##

## [i]Internal: Stores references to services using [Script] as the key and [Node] as the value[/i]
static var _registered_services: Dictionary[Script, Node] = {}

## Registers a service by using the [Node] instance's attached [Script][br]
## [param service] The [Node] instance to register[br]
## [color=cyan][b]ⓘ Hint: It is recommended to register Nodes in [method Node._enter_tree][/b][/color]
static func register(service: Node) -> void:
	var script: Script = service.get_script()
	
	if script == null:
		push_error("Cannot register service without a script.")
		return
	
	if _registered_services.has(script):
		push_error("Service of type '%s' is already registered." % script.resource_path)
		return
	
	_registered_services[script] = service
	print("Service of type '%s' registered." % script.resource_path.get_file())

## Registers a service with a [Node] instance and specific [Script] type[br]
## [param service] The [Node] instance to register[br]
## [param service_class] The [Script] type to refer to this registered [Node][br]
## [color=cyan][b]ⓘ Hint: It is recommended to register Nodes in [method Node._enter_tree][/b][/color]
static func register_as(service: Node, service_class: Script) -> void:
	if service_class == null:
		push_error("Cannot register service with null class.")
		return
	
	if _registered_services.has(service_class):
		push_error("Service of type '%s' is already registered." % service_class.resource_path)
		return
	
	_registered_services[service_class] = service
	print("Service of type '%s' registered." % service_class.resource_path.get_file())

## Unregisters a service by using the [Node] instance's attached [Script][br]
## [param service] The [Node] instance to unregister[br]
## [color=cyan][b]ⓘ Hint: It is recommended to unregister Nodes in [method Node._exit_tree][/b][/color]
static func unregister(service: Node) -> void:
	var script: Script = service.get_script()
	
	if script == null:
		push_error("Cannot unregister service without a script.")
		return
	
	if !_registered_services.has(script):
		push_error("Service of type '%s' is not registered." % script.resource_path)
		return
	
	_registered_services.erase(script)
	print("Service of type '%s' unregistered." % script.resource_path.get_file())

## Unregisters a service of a specific [Script] type[br]
## [param service_class] The [Script] type to unregister[br]
## [color=cyan][b]ⓘ Hint: It is recommended to unregister Nodes in [method Node._exit_tree][/b][/color]
static func unregister_as(service_class: Script) -> void:
	if !_registered_services.has(service_class):
		push_error("Service of type '%s' is not registered." % service_class.resource_path)
		return
	_registered_services.erase(service_class)
	print("Service of type '%s' unregistered." % service_class.resource_path.get_file())

## Retrieves a service by [Script] type[br]
## [param service_class] The [Script] type to fetch[br]
## [b]Returns:[/b] A [Node] of the requested [Script] type, or [code]null[/code] if not found.[br]
## [color=yellow][b]⚠Warning: To avoid missing references, only fetch services within or after [method Node._ready][/b][/color]
static func get_service(service_class: Script) -> Node:
	if _registered_services.has(service_class):
		return _registered_services[service_class]
	
	push_error("Service of type '%s' is not registered." % service_class.resource_path)
	return null
