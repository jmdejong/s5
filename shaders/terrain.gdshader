shader_type spatial;

uniform sampler2D noise;

float height(vec2 position) {
  return (texture(noise, position ).x - 0.5) * 50.0 / 64.0;
}


void vertex() {
	vec2 pos = VERTEX.xz;
	float k = height(pos);
	vec3 shere = vec3(0, k, 0);
	vec3 sx = vec3(0.1, height(pos + vec2(0.1, 0.0))-k, 0);
	vec3 sz = vec3(0, height(pos + vec2(0.1, 0.1))-k, 0.1);
	vec3 n1 = -normalize(cross(sx, sz));
	NORMAL=n1;
	//NORMAL = normalize(vec3(k - height(pos + vec2(0.1, 0.0)), 0.1, k - height(pos + vec2(0.0, 0.1)))).xyz;
	VERTEX.y += k;
}

void fragment() {
	// Place fragment code here.
	ALBEDO = vec3(0.5, 0.0, 0.0);
}
