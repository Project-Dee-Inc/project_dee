shader_type spatial;

uniform float bands = 3.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
}

void light() {
	 //Called for every pixel for every light affecting the CanvasItem.
	 //Uncomment to replace the default light processing function with this one.
	vec3 lightColor = LIGHT_COLOR / PI;
	
	vec3 half = normalize(VIEW + LIGHT);
	
	float NdotL = max(dot(NORMAL, LIGHT), 0.0);
	float NdotV = max(dot(NORMAL, VIEW), 0.0);
	float NdotH = max(dot(NORMAL, half), 0.0);
	float LdotH = max(dot(LIGHT, half), 0.0);
	
	// Diffuse light (Lambert).
	DIFFUSE_LIGHT += (ceil(NdotL * bands) / bands) * ceil(ATTENUATION) * lightColor;
}
