class_name Voxel extends Node3D

func _ready():
		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = generate_cube_mesh(Vector3(1, 1, 1), {
				"front": true,
				"back": true,
				"left": true,
				"right": true,
				"top": true,
				"bottom": true
		})
		add_child(mesh_instance)

func generate_cube_mesh(size: Vector3, faces: Dictionary) -> Dictionary:
		var vertices = []
		var indices = []
		var normals = []
		var uv = []
		var index_offset = 0

		# Define face data
		var face_data = {
				"front": { "normal": Vector3(0, 0, -1), "verts": [Vector3(-1, -1, -1), Vector3(1, -1, -1), Vector3(1, 1, -1), Vector3(-1, 1, -1)] },
				"back": { "normal": Vector3(0, 0, 1), "verts": [Vector3(1, -1, 1), Vector3(-1, -1, 1), Vector3(-1, 1, 1), Vector3(1, 1, 1)] },
				"left": { "normal": Vector3(-1, 0, 0), "verts": [Vector3(-1, -1, 1), Vector3(-1, -1, -1), Vector3(-1, 1, -1), Vector3(-1, 1, 1)] },
				"right": { "normal": Vector3(1, 0, 0), "verts": [Vector3(1, -1, -1), Vector3(1, -1, 1), Vector3(1, 1, 1), Vector3(1, 1, -1)] },
				"top": { "normal": Vector3(0, 1, 0), "verts": [Vector3(-1, 1, -1), Vector3(1, 1, -1), Vector3(1, 1, 1), Vector3(-1, 1, 1)] },
				"bottom": { "normal": Vector3(0, -1, 0), "verts": [Vector3(-1, -1, 1), Vector3(1, -1, 1), Vector3(1, -1, -1), Vector3(-1, -1, -1)] }
		}

		# Generate mesh data per face
		for face_name in faces.keys():
				if faces[face_name]:  # Only add face if it should render
						var data = face_data[face_name]
						var face_verts = data["verts"]
						var normal = data["normal"]
						
						# Scale vertices by size
						for vert in face_verts:
								vertices.append(vert * size * 0.5)  # Cube vertices centered at origin
						
						# Add indices
						indices.append(index_offset + 0)
						indices.append(index_offset + 1)
						indices.append(index_offset + 2)
						indices.append(index_offset + 0)
						indices.append(index_offset + 2)
						indices.append(index_offset + 3)
						
						# Add normals
						normals.append(normal)
						normals.append(normal)
						normals.append(normal)
						normals.append(normal)
						
						# Add UVs (simple planar mapping)
						uv.append(Vector2(0, 1))
						uv.append(Vector2(1, 1))
						uv.append(Vector2(1, 0))
						uv.append(Vector2(0, 0))
						
						index_offset += 4

		# Convert arrays to PackedArrays
		var vertex_array = PackedVector3Array(vertices)
		var normal_array = PackedVector3Array(normals)
		var uv_array = PackedVector2Array(uv)
		var index_array = PackedInt32Array(indices)

		return {
			"vertices": vertex_array,
			"normals": normal_array,
			"uv": uv_array,
			"indices": index_array
		}
