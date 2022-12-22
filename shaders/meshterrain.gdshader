shader_type spatial;
render_mode world_vertex_coords;

uniform sampler2D noise;
uniform vec3 area_min;
uniform vec3 area_size;

varying vec3 normals;
varying float vert_height;

float height_at(vec2 position) {
	vec4 tex = texture(noise, (position - area_min.xz) / area_size.xz);
	return (tex.x + tex.y / 255.0 ) * area_size.y + area_min.y;
}


void vertex() {
	vec2 pos = clamp(VERTEX.xz, area_min.xz, area_size.xz + area_min.xz);
	float k = height_at(pos);
	VERTEX.y = k;
	vert_height = k;
	float delta = 1.0;
	normals = normalize(-cross(
		vec3(-delta, k - height_at(pos + vec2(-delta, 0)), 0),
		vec3(0, k - height_at(pos + vec2(0, -delta)), -delta)
	));
	NORMAL = normals;
}


void fragment() {
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
