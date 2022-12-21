shader_type spatial;
render_mode world_vertex_coords;

#include "shaders/ashima_simplex.gdshaderinc"

const int ip = 104729;
const float fp = 104729.0;

float _hash(vec2 pos){
	int n1 = int(pos.x * 8196.0);
	int n2 = int(pos.y * 8196.0);
	int a = n1*287117 + 350377 + 224737 *( n2*n2*n1) % 7919;
	return float(a*a % ip) / fp;
}

float height_at(vec2 pos, vec2 camera) {
	//return 2.0;
	//return 5.0 * (sin(pos.x/5.1) + sin(pos.y/5.1)) + 1.0;
	float dist = distance(camera, pos);
	float n = 0.0;
	if (dist < 500.0) {
		n =  snoise(pos / 200.0) * 0.7
		+ snoise(pos / 50.0) * 0.15
		+ snoise(pos / 30.0) * 0.10
		+ snoise(pos / 10.0) * 0.05;
	} else {
		n = snoise(pos / 200.0);
	}
	return n * 20.0;
}

vec3 vec_at(vec2 pos, vec2 camera) {
	return vec3(pos.x, height_at(pos, camera), pos.y);
}

void vertex() {
	vec3 pos = VERTEX;
	vec2 camera = CAMERA_POSITION_WORLD.xy;
	pos.y = height_at(pos.xz, camera);
	VERTEX = pos;
	NORMAL = -cross(
		(pos - vec_at(pos.xz - vec2(0.1, 0), camera)),
		(pos - vec_at(pos.xz - vec2(0, 0.1), camera))
	);
}

void fragment() {
	ALBEDO = vec3(1, 0, 0);
}
