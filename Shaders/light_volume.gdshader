shader_type spatial;
render_mode unshaded, depth_draw_never;

#include "contact_shadows.gdshaderinc"

uniform sampler2D depth_tex : hint_depth_texture;
uniform sampler2D normal_tex : hint_normal_roughness_texture, filter_nearest_mipmap;

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

void vertex() {
	_MODEL_MATRIX = MODEL_MATRIX;
}

float get_omni_attenuation(float dist, float inv_range, float decay) {
	float nd  = dist * inv_range;
	nd *= nd;
	nd *= nd; // nd^4
	nd = max(1.0 - nd, 0.0);
	nd *= nd; // nd^2
	return nd * pow(max(dist, 0.0001), -decay);
}

void fragment() {
	float depth = 1.0 - texture(depth_tex, vec2(SCREEN_UV.x, SCREEN_UV.y)).r;

	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view_pos = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view_pos.xyz = view_pos.xyz / view_pos.w;
	vec4 world_pos = (INV_VIEW_MATRIX * view_pos);

	vec4 center = (_MODEL_MATRIX * vec4(vec3(0.0), 1.0));

	vec3 rayDirWS = -((world_pos - center).xyz);

	vec3 rayStartWS = world_pos.xyz;
	vec3 rayEndWS = rayStartWS + (rayDirWS);

	vec4 rayStartVS = VIEW_MATRIX * vec4(rayStartWS, 1.0);
	vec4 rayEndVS = VIEW_MATRIX * vec4(rayEndWS, 1.0);

	vec3 rayDirVS = rayEndVS.xyz - rayStartVS.xyz;

	vec3 rayStep = rayDirVS * float(g_sss_step_length);

	vec4 rayPos = rayStartVS;

	bool occ = false;

	uint j = uint(0);
	ALBEDO = vec3(0.0);
	for (uint i = uint(0); i < g_sss_max_steps; i++)
	{
		rayPos += vec4(rayStep, 0.0);
		vec4 rayPosCS = PROJECTION_MATRIX * rayPos;
		rayPosCS.xyz = rayPosCS.xyz / rayPosCS.w;
		vec2 rayUV = abs(rayPosCS.xy * 0.5 + 0.5);

		float depthSample = 1.0 - texture(depth_tex, rayUV).r;

		float depth_delta = (pow(rayPosCS.z, 1.0) - depthSample);
		//ALBEDO = vec3(depth_delta);

		if (depth_delta > 0.0)
		{
			occ = true;
			break;
		}
	}
	ALBEDO = vec3(float(!occ));
}