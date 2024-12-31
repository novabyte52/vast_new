class_name Chunk extends Node3D

# Path to the voxel script
const VOXEL_SCRIPT = preload("res://voxel.gd")

# Chunk dimensions
var chunk_size = Vector3(10, 10, 10)
var voxel_size = Vector3(1, 1, 1)

func _init(c_size: Vector3, v_size: Vector3) -> void:
		chunk_size = c_size
		voxel_size = v_size

func _ready():
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = generate_chunk()
		add_child(mesh_instance)

func generate_chunk() -> ArrayMesh:
		var vertices = []
		var indices = []
		var normals = []
		var uv = []
		var index_offset = 0

		# Iterate through the chunk grid
		for x in range(chunk_size.x):
				for y in range(chunk_size.y):
						for z in range(chunk_size.z):
								var voxel_pos = Vector3(x, y, z)

								# Determine visible faces based on neighbors
								var visible_faces = {
										"front": not is_voxel_present(voxel_pos + Vector3(0, 0, -1)),
										"back": not is_voxel_present(voxel_pos + Vector3(0, 0, 1)),
										"left": not is_voxel_present(voxel_pos + Vector3(-1, 0, 0)),
										"right": not is_voxel_present(voxel_pos + Vector3(1, 0, 0)),
										"top": not is_voxel_present(voxel_pos + Vector3(0, 1, 0)),
										"bottom": not is_voxel_present(voxel_pos + Vector3(0, -1, 0))
								}

								# Use the voxel API to generate the mesh for this voxel
								var voxel = VOXEL_SCRIPT.new()
								var mesh_data = voxel.generate_cube_mesh(voxel_pos * voxel_size, visible_faces)

								# Append the voxel's mesh data to the chunk mesh
								vertices.append_array(mesh_data["vertices"])
								normals.append_array(mesh_data["normals"])
								uv.append_array(mesh_data["uv"])

								for i in mesh_data["indices"]:
										indices.append(i + index_offset)

								index_offset += mesh_data["vertices"].size()

		# Convert arrays to PackedArrays
		var vertex_array = PackedVector3Array(vertices)
		var normal_array = PackedVector3Array(normals)
		var uv_array = PackedVector2Array(uv)
		var index_array = PackedInt32Array(indices)

		# Create and return the ArrayMesh
		var array_mesh = ArrayMesh.new()
		var arrays = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = vertex_array
		arrays[Mesh.ARRAY_NORMAL] = normal_array
		arrays[Mesh.ARRAY_TEX_UV] = uv_array
		arrays[Mesh.ARRAY_INDEX] = index_array
		
		array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		return array_mesh

func is_voxel_present(voxel_pos: Vector3) -> bool:
		# Default logic: A full chunk where all voxels are present
		return voxel_pos.x >= 0 and voxel_pos.x < chunk_size.x and voxel_pos.y >= 0 and voxel_pos.y < chunk_size.y and voxel_pos.z >= 0 and voxel_pos.z < chunk_size.z
