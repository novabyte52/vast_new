class_name World extends Node3D

# Constants
const CHUNK_SIZE = Vector3(8, 8, 8) # Size of a single chunk
const VOXEL_SIZE = Vector3(1, 1, 1) # Size of a single voxel
const RENDER_RADIUS = 3  # Radius of chunks to render around the player

# Paths
const CHUNK_SCRIPT = preload("res://chunk.gd")

# Player reference (assign in the editor or via script)
@export var player: Node3D

# Active chunks
var active_chunks = {}

func _ready():
		update_chunks()

func _process(delta):
		# Continuously check if chunks need to be updated based on player movement
		update_chunks()

func update_chunks():
		if not player:
				return  # No player assigned, skip updating

		# Get the player's chunk coordinate
		var player_chunk_coord = world_to_chunk(player.global_transform.origin)

		# Determine chunks to keep
		var chunks_to_keep = {}
		for x in range(-RENDER_RADIUS, RENDER_RADIUS + 1):
				for y in range(-RENDER_RADIUS, RENDER_RADIUS + 1):
						for z in range(-RENDER_RADIUS, RENDER_RADIUS + 1):
								var chunk_coord = player_chunk_coord + Vector3(x, y, z)
								chunks_to_keep[chunk_coord] = true

								# If the chunk isn't already active, create and add it
								if not active_chunks.has(chunk_coord):
										var chunk = CHUNK_SCRIPT.new(CHUNK_SIZE, VOXEL_SIZE)
										chunk.translate(chunk_coord * CHUNK_SIZE)  # Position the chunk in world space
										add_child(chunk)
										active_chunks[chunk_coord] = chunk

		# Unload chunks that are no longer needed
		for chunk_coord in active_chunks.keys():
				if not chunks_to_keep.has(chunk_coord):
						active_chunks[chunk_coord].queue_free()
						active_chunks.erase(chunk_coord)

func world_to_chunk(world_pos: Vector3) -> Vector3:
		# Convert a world position to chunk coordinates
		return Vector3(
				floor(world_pos.x / CHUNK_SIZE.x),
				floor(world_pos.y / CHUNK_SIZE.y),
				floor(world_pos.z / CHUNK_SIZE.z)
		)
