shader_type spatial;
render_mode specular_schlick_ggx, shadows_disabled;

uniform float refraction = 1.0;
uniform float ripple_speed = 1.0;
uniform float ripple_scale = 1.0;

uniform sampler2D refraction_texture : filter_nearest, repeat_disable;
uniform sampler2D depth_tex: hint_depth_texture, filter_nearest;

uniform sampler2D noise_map: hint_default_white, filter_nearest;
uniform sampler2D normal_map: hint_normal, filter_nearest;

#include "proximity-fade.gdshaderinc"

uniform bool use_refraction;

USE_DEPTH_TEXTURE(1)

float remap(float value, float low1, float high1, float low2, float high2) {
    return low2 + (value - low1) * (high2 - low2) / (high1 - low1);
}

vec3 _view_from_screen(vec2 _uv, float _depth, mat4 _inv_proj) {
	vec4 _upos = _inv_proj * vec4(_uv * 2.0 - 1.0, _depth, 1.0);
	return _upos.xyz / _upos.w;
}
#define view_from_screen(uv, depth_tex) _view_from_screen((uv), textureLod((depth_tex), (uv), 0.0).r, INV_PROJECTION_MATRIX)

void vertex() {
	// Called for every vertex the material is visible on.
	float noise = texture(noise_map, UV * (ripple_scale * 2.0) + (TIME * 0.25)).r * 1.5 - 1.0;
	VERTEX.y += noise;
}

float getDepth(vec2 screen_uv, float raw_depth, mat4 inv_projection_matrix){
//	Credit: https://godotshaders.com/shader/depth-modulated-pixel-outline-in-screen-space/
	vec3 normalized_device_coordinates = vec3(screen_uv * 2.0 - 1.0, raw_depth);
    vec4 view_space = inv_projection_matrix * vec4(normalized_device_coordinates, 1.0);	
	view_space.xyz /= view_space.w;	
	return -view_space.z;
}

float linear_depth(in sampler2D _depth_texture, vec2 screen_uv, in mat4 inv_projection_matrix) {
	// get raw depth, this is not a linear value in godot 4.0 vulkan rendering
	float raw_depth = texture(_depth_texture, screen_uv).r;
    
	vec3 normalized_device_coordinates = vec3(screen_uv * 2.0 - 1.0, raw_depth);
	
	//convert NDC to view space via the inverse projection matrix
    vec4 view_space = inv_projection_matrix * vec4(normalized_device_coordinates, 1.0);
    
	//linearize the depth
	view_space.xyz /= view_space.w;
	
	// camera view points in the negative Z direction, so all depths are negative
	// we invert the sign here to get positive depth values
	return -view_space.z;
}

void fragment() {
	vec2 texel_size = 1.0 / VIEWPORT_SIZE;
	float i = 0.0;
	vec2 uv = (UV * ripple_scale) + TIME * ripple_speed;
	
	float noise = texture(noise_map, UV).r;
	NORMAL_MAP = texture(normal_map, uv + vec2(noise, -noise) * 0.25).xyz;
	float ref_str = refraction/VERTEX.z;
	vec2 ref_ofs = (NORMAL_MAP.xy * ref_str)-(ref_str * 0.5);
	
	float depth = linear_depth(depth_tex, SCREEN_UV, INV_PROJECTION_MATRIX);
	depth += VERTEX.z;
	vec2 distorted_uv = SCREEN_UV;
	
	if(depth < 2.5f){
		distorted_uv += ref_ofs;
	}distorted_uv += ref_ofs;
	
	float depth_fade = round(1.0 - PROXIMITY_FADE(0.25));
	if (use_refraction)
	{
		vec3 refraction_color = texture(refraction_texture, distorted_uv).rgb;
		ALBEDO = refraction_color * 0.25 + depth_fade;
	}
	else
	{
		vec3 screen_color = texture(refraction_texture, SCREEN_UV).rgb;
		ALBEDO = screen_color * 0.25 + depth_fade;
	}
	
	ROUGHNESS = 0.25;
	SPECULAR = 0.75;
}

float DistributionGGX(float cos_theta_m, float alpha)
{
	float alpha2 = alpha * alpha;
	float d = 1.0 + (alpha2 - 1.0) * cos_theta_m * cos_theta_m;
	return alpha2 / (PI * d * d);
}

float GeometryGGX(float NdotL, float NdotV, float alpha)
{
	return 0.5 / mix(2.0 * NdotL * NdotV, NdotL + NdotV, alpha);
}

vec3 SchlickBaseReflectivity(float met, float spec, vec3 alb)
{
	float dielectric = 0.04 * spec * spec;
	return mix(vec3(dielectric), alb, vec3(met));
}
	
float SchlickFresnel(float u)
{
	float m = 1.0 - u;
	float m2 = m * m;
	return m2 * m2 * m;
}

void light()
{
	// Calculate some vectors.
	vec3 lightColor = LIGHT_COLOR / PI;
	
	vec3 half = normalize(VIEW + LIGHT);
	
	float NdotL = LIGHT_IS_DIRECTIONAL ? max(dot(NORMAL, LIGHT), 0.0) : 0.0;
	float NdotV = max(dot(NORMAL, VIEW), 0.0);
	float NdotH = max(dot(NORMAL, half), 0.0);
	float LdotH = max(dot(LIGHT, half), 0.0);
	
	// Diffuse light (Lambert).
	DIFFUSE_LIGHT += (ceil(NdotL * 3.0) / 3.0);
	
	// Specular light (Schlick-GGX).
	float ggxAlpha = ROUGHNESS * ROUGHNESS;
	float D = DistributionGGX(NdotH, ggxAlpha);
	float G = GeometryGGX(NdotL, NdotV, ggxAlpha);
	
	vec3 f0 = SchlickBaseReflectivity(METALLIC, SPECULAR_AMOUNT, ALBEDO);
	float LdotH5 = SchlickFresnel(LdotH);
	float f90 = clamp(50.0 * f0.g, 0.0, 1.0);
	vec3 F = f0 + (f90 - f0) * LdotH5;
	
	vec3 specularBRDF = round(smoothstep(0.0, 0.01, max(NdotL * D * G * F, 0.0)));
	SPECULAR_LIGHT += specularBRDF * LIGHT_COLOR * NdotL;
}
