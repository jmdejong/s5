shader_type spatial;
render_mode world_vertex_coords;


#include "shaders/ashima_simplex.gdshaderinc"

uniform sampler2D noise;
uniform vec3 area_min;
uniform vec3 area_size;
uniform sampler2D grass_texture;
uniform sampler2D sand_texture;
uniform sampler2D stone_texture;
uniform float texture_size;

varying vec3 normals;
// varying vec2 tex_uv;
varying vec3 p;

vec4 interpolate_sample(sampler2D tex, vec2 big_uv, int lod) {
	ivec2 size = textureSize(tex, lod);
	vec2 xy = big_uv * vec2(size);
	ivec2 ixy = ivec2(floor(xy));
	vec2 uv = fract(xy);
// 	return texelFetch(tex, ixy, lod);
	return mix(
			mix(
			texelFetch(tex, ixy, lod),
			texelFetch(tex, ixy + ivec2(1, 0), lod),
			uv.x
		),
		mix(
			texelFetch(tex, ixy + ivec2(0, 1), lod),
			texelFetch(tex, ixy + ivec2(1, 1), lod),
			uv.x
		),
		uv.y
	);
}


float height_at(vec2 position) {
	vec4 tex = texture(noise, (position - area_min.xz) / area_size.xz);
	return (tex.x + tex.y / 255.0 ) * area_size.y + area_min.y;
}


void vertex() {
	vec2 pos = clamp(VERTEX.xz, area_min.xz, area_size.xz + area_min.xz);
	float k = height_at(pos);
	VERTEX.y = k;
// 	vert_height = k;
	float delta = 1.0;
	normals = normalize(-cross(
		vec3(-delta, k - height_at(pos + vec2(-delta, 0)), 0),
		vec3(0, k - height_at(pos + vec2(0, -delta)), -delta)
	));
	NORMAL = normals;
	p = VERTEX;
}


void fragment() {
	vec2 tex_uv = fract(p.xz / texture_size);
// 	sampler2D tex = normals.y > 0.7 ? stone_texture : p.y < 2.0 ? sand_texture : grass_texture;
	vec4 t =
		mix(
			texture(stone_texture, tex_uv),
			mix(
				texture(sand_texture, tex_uv),
				texture(grass_texture, tex_uv),
				clamp((p.y + snoise(p.xz * 20.0) * 0.02 + snoise(p.xz * 1.0) * 0.1 + snoise(p.xz * 0.05) * 0.4 - 1.5) * 50.0, 0.0, 1.0)
			),
			clamp((normals.y - 0.7)* 100.0, 0, 1)
		);
	float sea_height = clamp(1.0 + p.y/4.0, 0.0, 1.0);
	vec3 blue = vec3(sea_height, sea_height, 1.0);
	ALBEDO = blue * t.xyz;
// 	ALBEDO = mix(
// 		texture(stone_texture, tex_uv).xyz,
// 		mix(
// 			texture(sand_texture, tex_uv).xyz,
// 			texture(grass_texture, tex_uv).xyz,
// 			clamp(vert_height*2.0-3.0, 0.0, 1.0)
// 		),
// 		clamp((normals.y - 0.7)* 20.0, 0, 1)
// 	);
// 	ALBEDO = mix(
// 		vec3(0.1, 0.1, 0.1),
// 		mix(
// 			vec3(0.6, 0.6, 0),
// 			vec3(0, 0.5, 0),
// 			clamp(vert_height*2.0-3.0, 0.0, 1.0)
// 		),
// 		clamp((normals.y - 0.7)* 20.0, 0, 1)
// 	);
}
