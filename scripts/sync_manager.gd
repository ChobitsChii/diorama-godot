class_name SyncManager
extends Node

## Communicates asynchronously via HTTPRequest with the Modulon Diorama Sandbox API.

signal sync_started(action: String)
signal sync_finished(action: String, success: bool, message: String)
signal cloud_data_received(scene_data: Dictionary)

@export var server_url: String = "http://127.0.0.1"

var _http_save: HTTPRequest
var _http_load: HTTPRequest

func _init() -> void:
	_http_save = HTTPRequest.new()
	_http_save.name = "HttpSave"
	_http_save.timeout = 5.0
	_http_save.request_completed.connect(_on_save_request_completed)
	
	_http_load = HTTPRequest.new()
	_http_load.name = "HttpLoad"
	_http_load.timeout = 5.0
	_http_load.request_completed.connect(_on_load_request_completed)

func _enter_tree() -> void:
	if not _http_save.is_inside_tree():
		add_child(_http_save)
	if not _http_load.is_inside_tree():
		add_child(_http_load)

func sync_to_cloud(grid_mgr: GridManager, scene_name: String = "default") -> void:
	if not grid_mgr:
		return
	
	sync_started.emit("save")
	var serialized_data = DioramaSerializer.serialize(grid_mgr)
	var payload = {
		"scene_name": scene_name,
		"scene_data": serialized_data,
	}
	var json_str = JSON.stringify(payload)
	
	var headers = [
		"Content-Type: application/json",
		"Accept: application/json"
	]
	
	var url = "%s/diorama-sandbox/api/save" % server_url.trim_suffix("/")
	var err = _http_save.request(url, headers, HTTPClient.METHOD_POST, json_str)
	if err != OK:
		sync_finished.emit("save", false, "Konnte HTTP-Anfrage nicht senden (Code %d)" % err)

func fetch_from_cloud(scene_name: String = "default") -> void:
	sync_started.emit("load")
	var headers = ["Accept: application/json"]
	var url = "%s/diorama-sandbox/api/load?scene_name=%s" % [server_url.trim_suffix("/"), scene_name.uri_encode()]
	var err = _http_load.request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		sync_finished.emit("load", false, "Konnte Cloud-Szene nicht laden (Code %d)" % err)

func _on_save_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		sync_finished.emit("save", false, "Server nicht erreichbar (Offline-Modus)")
		return
	
	if response_code >= 200 and response_code < 300:
		sync_finished.emit("save", true, "Erfolgreich mit Cloud synchronisiert ✓")
	else:
		sync_finished.emit("save", false, "HTTP Fehler %d" % response_code)

func _on_load_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		sync_finished.emit("load", false, "Server nicht erreichbar")
		return
	
	if response_code != 200:
		sync_finished.emit("load", false, "HTTP Fehler %d" % response_code)
		return
	
	var body_str = body.get_string_from_utf8()
	var json = JSON.new()
	if json.parse(body_str) == OK and json.data is Dictionary:
		var resp: Dictionary = json.data
		if resp.get("ok", false) and resp.has("scene_data"):
			var scene_data = resp["scene_data"]
			if scene_data is String:
				var inner_json = JSON.new()
				if inner_json.parse(scene_data) == OK and inner_json.data is Dictionary:
					cloud_data_received.emit(inner_json.data)
					sync_finished.emit("load", true, "Cloud-Szene erfolgreich geladen ✓")
					return
			elif scene_data is Dictionary:
				cloud_data_received.emit(scene_data)
				sync_finished.emit("load", true, "Cloud-Szene erfolgreich geladen ✓")
				return
	
	sync_finished.emit("load", false, "Ungültige Antwort von Cloud-API")
