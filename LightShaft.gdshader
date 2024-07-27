shader_type spatial;

uniform sampler2D depth_texture : hint_depth_texture;

float getDepth(vec2 screen_uv, float raw_depth, mat4 inv_projection_matrix){
//	Credit: https://godotshaders.com/shader/depth-modulated-pixel-outline-in-screen-space/
	vec3 normalized_device_coordinates = vec3(screen_uv * 2.0 - 1.0, raw_depth);
    vec4 view_space = inv_projection_matrix * vec4(normalized_device_coordinates, 1.0);	
	view_space.xyz /= view_space.w;	
	return -view_space.z;
}

void fragment() {
	float base_depth = getDepth(SCREEN_UV, FRAGCOORD.z, INV_PROJECTION_MATRIX);
	float surface_depth = getDepth(SCREEN_UV, texture(depth_texture, SCREEN_UV).x, INV_PROJECTION_MATRIX);
	float diff = surface_depth - base_depth;
	
	ALPHA = clamp(diff, 0.0, 1.0) * 0.1;
}

void light()
{
	DIFFUSE_LIGHT = clamp(LIGHT_COLOR * ceil(ATTENUATION), 0.0, 1.0);
}