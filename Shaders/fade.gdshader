shader_type spatial;
render_mode depth_draw_never;

#include "dither.gdshaderinc"

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.

	vec4 node_pos = vec4(NODE_POSITION_WORLD, 1.0);
	node_pos = VIEW_MATRIX * node_pos;
	node_pos = PROJECTION_MATRIX * node_pos;

	vec2 ndc = node_pos.xy;

	vec2 frag = (SCREEN_UV * 2.0 - 1.0) * VIEWPORT_SIZE.xy;

	float dist = length(node_pos.xy);
	dist = clamp(smoothstep(0.3, 0.7, dist), 0.5, 1.0);
	if (DITHER(dist - 0.01) <= 0.0)
		discard;
	//if (dist < 256.0)
	//{
		//float d = dist / 256.0;
		//d = smoothstep(0.25, 0.75, d);
		//if (DITHER(d - 0.1) <= 0.0)
			//discard;
	//}
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
