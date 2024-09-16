const uint  g_sss_max_steps                     = uint(32);
const float g_sss_ray_max_distance              = 1.0;
const highp float g_sss_step_length             = g_sss_ray_max_distance / float(g_sss_max_steps);

#define CONTACT_SHADOW(depth, model, frag_coord) (compute_contact_shadows(depth, SCREEN_UV, frag_coord, model, VIEW_MATRIX, INV_VIEW_MATRIX, PROJECTION_MATRIX, INV_PROJECTION_MATRIX))

float compute_contact_shadows(sampler2D depth_texture, vec2 screen_uv, vec4 frag_coord, mat4 model, mat4 view, mat4 inv_view, mat4 proj, mat4 inv_proj)
{
	float depth = texture(depth_texture, screen_uv).r;
	vec4 ndc = vec4(screen_uv * 2.0 - 1.0, depth, 1.0);
	vec4 view_pos = inv_proj * ndc;
	view_pos.xyz /= view_pos.w;
	vec4 world_pos = (inv_view * view_pos);

	vec4 center = (model * vec4(vec3(0.0), 1.0));

	vec3 rayDirWS = (center.xyz - world_pos.xyz);

	vec3 rayStartWS = world_pos.xyz;
	vec3 rayEndWS = rayStartWS + (rayDirWS);

	vec4 rayStartVS = view * vec4(rayStartWS, 1.0);
	vec4 rayEndVS = view * vec4(rayEndWS, 1.0);

	vec3 rayDirVS = rayEndVS.xyz - rayStartVS.xyz;

	vec4 rayStartCS = proj * rayStartVS;
	rayStartCS.xyz = rayStartCS.xyz / rayStartCS.w;
	vec4 rayEndCS = proj * rayEndVS;
	rayEndCS.xyz = rayEndCS.xyz / rayEndCS.w;

	vec4 rayOrthoViewSpace = rayStartCS + vec4(proj[0][2], proj[1][2], proj[2][2], proj[3][2]);
	rayOrthoViewSpace.xyz = rayOrthoViewSpace.xyz / rayOrthoViewSpace.w;

	vec3 rayDirCS = rayEndCS.xyz - rayStartCS.xyz;
	float steps = float(g_sss_step_length);
	float compareThreshold = abs(rayOrthoViewSpace.z - rayStartCS.z) * steps;

	float occluded = 1.0;

	vec2 startUV = rayStartCS.xy * 0.5 + 0.5;
	vec3 rayStart = vec3(startUV, rayStartCS.z);
	vec3 rayDir = vec3(rayDirCS.x * 0.5, rayDirCS.y * 0.5, rayDirCS.z);

	float t = steps + steps;

	for (uint i = uint(0); i < g_sss_max_steps; i++)
	{
		vec3 sampleAlongRay = rayStart + (t * rayDir);

		if (sampleAlongRay.x < 0.0 || sampleAlongRay.x > 1.0 || sampleAlongRay.y < 0.0 || sampleAlongRay.y > 1.0)
			break;

		float sampleDepth = texture(depth_texture, sampleAlongRay.xy).r;

		float depthDiff = sampleDepth - sampleAlongRay.z;

		if (depthDiff > 0.0 && depthDiff < compareThreshold && sampleAlongRay.z > 0.0)
		{
			occluded = 0.0;
			break;
		}

		t += steps;
	}

	return occluded;
}