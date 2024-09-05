shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never;

#include "contact_shadows.gdshaderinc"

uniform sampler2D depth_tex : hint_depth_texture, filter_nearest;
uniform sampler2D normal_tex : hint_normal_roughness_texture, filter_nearest;

group_uniforms light;
uniform vec3 light_color : source_color = vec3(1.0);
uniform int light_bands = 3;
uniform float light_range = 5.0;
uniform bool use_vertex_color = true;

group_uniforms halo;
uniform float halo_size = 10.0;
uniform int halo_bands = 3;

group_uniforms shadow;
uniform bool use_contact_shadow = true;

varying mat4 _MODEL_MATRIX;

void vertex()
{
	_MODEL_MATRIX = MODEL_MATRIX;
}

float get_omni_attenuation(float dist, float inv_range, float decay)
{
	float nd  = dist * inv_range;
	nd *= nd;
	nd *= nd; // nd^4
	nd = max(1.0 - nd, 0.0);
	nd *= nd; // nd^2
	return nd * pow(max(dist, 0.0001), -decay);
}

void fragment()
{
	float depth = texture(depth_tex, SCREEN_UV).r;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 world = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	vec3 behind_pos = (INV_VIEW_MATRIX * world).rgb;
	//behind_pos = world.xyz / world.w;

	vec4 world_pos = _MODEL_MATRIX * vec4(VERTEX, 1.0);
	vec4 center = _MODEL_MATRIX * vec4(vec3(0.0), 1.0);

	vec3 light_rel_vec = behind_pos - center.xyz;
	float dist = distance(behind_pos, center.rgb);
	float inv_dist = 1.0 / dist;
	float light_length = length(light_rel_vec);
	vec3 light_dir = normalize(light_rel_vec);
	float radius = max(0.001, light_range);
	float omni_atten = get_omni_attenuation(light_length, 1.0 / radius, 0.0);

	vec3 normal = texture(normal_tex, SCREEN_UV).xyz;
	float NdotL = max(0.0, dot(-light_dir, normal));

	ALBEDO = vec3(ceil(omni_atten * float(light_bands)) / float(light_bands));
	ALBEDO *= (use_vertex_color ? COLOR.rgb : light_color) / PI;

	center = _MODEL_MATRIX *  vec4(vec3(0.0), 1.0);
	center = VIEW_MATRIX * center;
	center = PROJECTION_MATRIX * center;

	vec2 ndc_center = center.xy / center.w;
	ndc_center = ndc_center * 0.5 + 0.5;
	ndc_center *= VIEWPORT_SIZE;

	float frag_dist = distance(ndc_center, FRAGCOORD.xy);
	if (frag_dist < halo_size)
	{
		float d = frag_dist / halo_size;
		float inv_d = 1.0 - d;
		inv_d = round(inv_d * float(halo_bands)) / float(halo_bands);
		ALBEDO += ((use_vertex_color ? COLOR.rgb : light_color) / PI * inv_d);
	}

	if (use_contact_shadow)
	{
		float omni_shadow = CONTACT_SHADOW(depth_tex, _MODEL_MATRIX, FRAGCOORD);
		if (omni_shadow <= 0.0)
			discard;
	}

  	ALPHA = 1.0 * COLOR.a;
}