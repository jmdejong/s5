shader_type spatial;
render_mode world_vertex_coords;

uniform sampler2D noise;

varying vec3 normals;
varying float vert_height;

#include "shaders/ashima_simplex.gdshaderinc"


float height_at(vec2 pos) {
	//return 2.0;
	//return 5.0 * (sin(pos.x/5.1) + sin(pos.y/5.1)) + 1.0;
	float n =  snoise(pos / 200.0) * 0.7
		+ snoise(pos / 50.0) * 0.15
		+ snoise(pos / 30.0) * 0.10
		+ snoise(pos / 10.0) * 0.05;
	return n * 20.0;
}

float height_at_(vec2 position) {
  return (texture(noise, position ).x - 0.5) * 50.0;
}

vec3 vec_at(vec2 pos) {
	return vec3(pos.x, height_at(pos), pos.y);
}

void vertex() {
	vec2 pos = VERTEX.xz;
	float k = height_at(pos);
	VERTEX.y = k;
	vert_height = k;
	normals = normalize(-cross(
		vec3(-0.1, k - height_at(pos + vec2(-0.1, 0)), 0),
		vec3(0, k - height_at(pos + vec2(0, -0.1)), -0.1)
	));
	NORMAL = normals;
}

void fragment() {
	/*if (normals.y < 0.8) {
		ALBEDO = vec3(0.1, 0.1, 0.1);
	} else {
		ALBEDO = vec3(0, 0.5, 0);
	}*/
	if (vert_height < 0.0) {
		discard;
	}
	ALBEDO = mix(
		vec3(0.1, 0.1, 0.1),
		mix(
			vec3(0.6, 0.6, 0),
			vec3(0, 0.5, 0),
			clamp(vert_height*2.0-3.0, 0.0, 1.0)
		),
		clamp((normals.y - 0.7)* 20.0, 0, 1)
	);
}
