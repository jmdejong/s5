shader_type spatial;

varying vec3 normals;
varying float height;

void vertex() {
	normals = NORMAL;
	height = VERTEX.y;
}

void fragment() {
	/*if (normals.y < 0.8) {
		ALBEDO = vec3(0.1, 0.1, 0.1);
	} else {
		ALBEDO = vec3(0, 0.5, 0);
	}*/
	ALBEDO = mix(
		vec3(0.1, 0.1, 0.1),
		mix(
			vec3(0.6, 0.6, 0),
			vec3(0, 0.5, 0),
			clamp(height*5.0-3.0, 0.0, 1.0)
		),
		clamp((normals.y - 0.7)* 20.0, 0, 1)
	);
}
