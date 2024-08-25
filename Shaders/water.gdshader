shader_type spatial;
render_mode specular_schlick_ggx, shadows_disabled;

uniform float refraction = 1.0;
uniform float ripple_speed = 1.0;
uniform float ripple_scale = 1.0;

uniform sampler2D refraction_texture : filter_nearest, repeat_disable;
uniform sampler2D depth_tex: hint_depth_texture, filter_nearest;

uniform sampler2D noise_map: hint_default_white, filter_nearest;
uniform sampler2D normal_map: hint_normal, filter_nearest;

uniform sampler2D water_color : filter_nearest, repeat_disable;

uniform bool use_refraction;

uniform bool use_dither;

#include "proximity-fade.gdshaderinc"
#include "dither.gdshaderinc"
USE_DEPTH_TEXTURE(1)

float remap(float value, float low1, float high1, float low2, float high2) {
    return low2 + (value - low1) * (high2 - low2) / (high1 - low1);
}
void vertex() {
	// Called for every vertex the material is visible on.
	float noise = texture(noise_map, UV * (ripple_scale) + (TIME * 0.25)).r;
	float noise2 = texture(noise_map, UV * (ripple_scale * 0.25) + (TIME * 0.125)).r * 2.0 - 1.0;
	VERTEX.y += (noise + noise2) * 0.5;
}

void fragment() {
	vec2 texel_size = 1.0 / VIEWPORT_SIZE;
	float i = 0.0;
	vec2 uv = (UV * ripple_scale) + TIME * ripple_speed;
	
	float noise = texture(noise_map, UV).r;
	vec3 normal = texture(normal_map, uv + vec2(noise, -noise) * 0.25).xyz;
	NORMAL_MAP = normal;
	float ref_str = refraction/VERTEX.z;
	vec2 ref_ofs = (NORMAL_MAP.xy * ref_str)-(ref_str * 0.5);
	
	float depth = texture(depth_tex, SCREEN_UV).r;
	//depth += VERTEX.z;
	vec2 distorted_uv = SCREEN_UV;
	
	//if(depth < 100.0f){
		//distorted_uv += ref_ofs;
	//}
	distorted_uv += ref_ofs;
	
	float depth_line = round(1.0 - PROXIMITY_FADE(0.15625));
	if (use_refraction)
	{
		vec3 refraction_color = texture(refraction_texture, distorted_uv).rgb;
		ALBEDO = refraction_color * 0.25;
	}
	else
	{
		vec3 screen_color = texture(refraction_texture, SCREEN_UV).rgb;
		ALBEDO = screen_color * 0.25;
	}
	
	float fade = round(PROXIMITY_FADE_UV(15.625, distorted_uv) * 8.0) / 8.0;
	float fade_dither = 1.0;
	if (use_dither)
	{
		fade_dither = DITHER(fade + 1e-7);
	}
	ALBEDO *= texture(water_color, vec2(fade * fade_dither, 0.5)).rgb;
	
	EMISSION = vec3(depth_line);
	
	ROUGHNESS = 0.5;
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
	DIFFUSE_LIGHT += NdotL * lightColor;
	
	// Specular light (Schlick-GGX).
	float ggxAlpha = ROUGHNESS * ROUGHNESS;
	float D = DistributionGGX(NdotH, ggxAlpha);
	float G = GeometryGGX(NdotL, NdotV, ggxAlpha);
	
	vec3 f0 = SchlickBaseReflectivity(METALLIC, SPECULAR_AMOUNT, ALBEDO);
	float LdotH5 = SchlickFresnel(LdotH);
	float f90 = clamp(50.0 * f0.g, 0.0, 1.0);
	vec3 F = f0 + (f90 - f0) * LdotH5;
	
	vec3 specularBRDF = round(smoothstep(0.0, 0.005, max(NdotL * D * G * F, 0.0)));
	SPECULAR_LIGHT += specularBRDF * lightColor * NdotL;
}
