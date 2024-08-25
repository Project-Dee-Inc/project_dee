shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

uniform sampler2D sprite : source_color, filter_nearest, repeat_disable;
uniform sampler2D normal_map : hint_normal, filter_nearest, repeat_disable;

const float angle = 1.0 / cos(radians(30.0));

void vertex() {
	// Called for every vertex the material is visible on.
	// Stretch based on camera angle
	VERTEX.y *= angle;
	VERTEX.y += angle;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 color = texture(sprite, UV);
	vec4 normal = texture(normal_map, UV);
	
	ALBEDO = color.rgb;
	ALPHA = color.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	
	NORMAL_MAP = normal.rgb;
}