class_name ListenToWebcamB
extends Node

signal on_webcam_texture_created(webcam: CameraTexture)

@export var debug_label: Label
@export var preview_rect: TextureRect
@export var look_for_webcams : Array[String]
@export var camera_index_if_not_found := 0

@export var look_for_format : Array[String] = ["1280x720 yuyv", "1280x720 mjpeg"]
@export var camera_format_index_if_not_found := 0

var feed: CameraFeed
var cam_tex: CameraTexture

var connected := false
var lost_frames_timer := 0.0
var last_reconnect_time := 0
var establishing_feed := false

const LOST_FRAME_TIMEOUT := 5.0
const RECONNECT_COOLDOWN := 10.0

# NEW FLAG — prevents multiple scans
var webcam_scanned := false
@onready var feed_display = $Sprite2D

func _ready() -> void:
	
	print("📷 Initializing camera system...\n")

	CameraServer.camera_feeds_updated.connect(_on_camera_feeds_updated)
	CameraServer.monitoring_feeds = true

	_log("🔍 Searching for available camera feeds...")
	#_on_camera_feeds_updated()
	

# --------------------------------------------------------------------
# FEED DISCOVERY (only runs once)
# --------------------------------------------------------------------
func _on_camera_feeds_updated() -> void:
	if webcam_scanned:
		return  # 🚫 Prevent rescan

	var feeds := CameraServer.feeds()

	if feeds.is_empty():
		_log("❌ No camera feeds detected.")
		return

	webcam_scanned = true  # ✅ Mark scan as done forever

	_log("📋 Available feeds:")
	for i in feeds.size():
		_log("   • [%d] %s" % [i, feeds[i].get_name()])
	feed = feeds[0]
	_select_format()
	_activate_feed()
	


# --------------------------------------------------------------------
# SELECT CAMERA
# --------------------------------------------------------------------
func _select_webcam(feeds: Array) -> void:
	feed = null

	if look_for_webcams.size() == 0:
		return

	for text in look_for_webcams:
		var search = text.to_lower()
		for webcam_feed in feeds:
			var feed_name = webcam_feed.get_name().to_lower()
			if feed_name.contains(search):
				feed = webcam_feed
				_log("🎯 Found matching webcam '%s' (%s)" %
					[text, webcam_feed.get_name()])
				break

	if feed == null:
		var idx = clamp(camera_index_if_not_found, 0, feeds.size() - 1)
		feed = feeds[idx]
		_log("🎯 Using fallback webcam index %d → %s" % [idx, feed.get_name()])

	_select_format()


# --------------------------------------------------------------------
# SELECT FORMAT
# --------------------------------------------------------------------
func _select_format() -> void:
	var formats := feed.get_formats()

	if formats.is_empty():
		_log("❌ No available formats.")
		return

	_log("📋 Available formats:")
	for i in formats.size():
		var f = formats[i]
		_log("   • [%d] %dx%d %s" % [
			i, f.get("width"), f.get("height"), f.get("format")
		])

	var target_index := -1
	var wanted := look_for_format.map(func(s): return s.to_lower())

	for i in formats.size():
		var f: Dictionary = formats[i]
		var pattern := "%dx%d %s" % [
			f["width"], f["height"], String(f["format"]).to_lower()
		]

		for w in wanted:
			if w in pattern:
				target_index = i
				_log("🎯 Found matching format '%s' → index %d" % [w, i])
				break

		if target_index != -1:
			break

	if target_index == -1:
		target_index = clamp(camera_format_index_if_not_found, 0, formats.size() - 1)
		_log("🎯 Using fallback format index %d" % target_index)

	var ok := feed.set_format(target_index, {})
	if ok:
		_log("✅ Format applied.")
	else:
		_log("⚠️ Driver fallback triggered (format may differ).")

	_activate_feed()


# --------------------------------------------------------------------
# ACTIVATE FEED
# --------------------------------------------------------------------
func _activate_feed() -> void:
	_log("⚡ Activating feed...")
	establishing_feed = true

	feed.set_active(true)

	await get_tree().process_frame
	await get_tree().process_frame

	establishing_feed = false

	if not feed.is_active():
		_log("❌ Feed failed to activate.")
		connected = false
		return

	_log("✅ Feed activated.")

	cam_tex = CameraTexture.new()
	cam_tex.camera_feed_id = feed.get_id()

	connected = true
	lost_frames_timer = 0

	if preview_rect:
		preview_rect.texture = cam_tex

	on_webcam_texture_created.emit(cam_tex)


func _on_active_changed(active: bool) -> void:
	establishing_feed = false

	if not active:
		_log("❌ Feed failed to activate.")
		connected = false
		return

	_log("✅ Feed active.")

	cam_tex = CameraTexture.new()
	cam_tex.camera_feed_id = feed.get_id()

	connected = true
	lost_frames_timer = 0.0

	if preview_rect:
		preview_rect.texture = cam_tex

	_log("🎥 CameraTexture created and bound to feed.")
	on_webcam_texture_created.emit(cam_tex)


# --------------------------------------------------------------------
# PROCESS LOOP
# --------------------------------------------------------------------
func _process(delta: float) -> void:
	if establishing_feed:
		print("⏳ Establishing feed...")
		return

	if connected and cam_tex:
		var w := cam_tex.get_width()
		var h := cam_tex.get_height()

		if w > 32 and h > 32:
			lost_frames_timer = 0.0
			print("✅ Receiving frames: %dx%d" % [w, h])
		else:
			lost_frames_timer += delta
			print("⏳ Waiting for frames... %.1fs" % lost_frames_timer)

			if lost_frames_timer > LOST_FRAME_TIMEOUT:
				if Time.get_ticks_msec() - last_reconnect_time > RECONNECT_COOLDOWN * 1000:
					last_reconnect_time = Time.get_ticks_msec()
					_log("⚠️ No frames detected — refreshing feed...")
					await _refresh_feed()


# --------------------------------------------------------------------
# REFRESH FEED
# --------------------------------------------------------------------
func _refresh_feed() -> void:
	if not feed:
		_log("⚠️ No feed — rescanning.")
		# BUT STILL DO NOT RESCAN webcams — user requested only one scan
		return

	_log("♻️ Refreshing feed...")
	establishing_feed = true

	feed.active_changed.connect(func(active):
		establishing_feed = false
		if active:
			_log("✅ Feed reactivated.")
		else:
			_log("❌ Feed reactivation failed.")
	, CONNECT_ONE_SHOT)

	feed.set_active(false)
	await get_tree().process_frame
	feed.set_active(true)
	feed_display.texture = CameraTexture

# --------------------------------------------------------------------
# LOGGING
# --------------------------------------------------------------------
func _log(msg: String) -> void:
	print(msg)
	if debug_label:
		debug_label.text += msg + "\n"
