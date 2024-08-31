shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	vec4 node_pos = vec4(NODE_POSITION_WORLD, 1.0);
	node_pos = VIEW_MATRIX * node_pos;
	node_pos = PROJECTION_MATRIX * node_pos;
	
	vec2 ndc = node_pos.xy * 0.5 + 0.5;
	
	float dist = length(ndc);
	//ALBEDO = vec3(0.0, ndc.y, 0.0);
	ALPHA = clamp(dist, 0.0, 1.0);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
