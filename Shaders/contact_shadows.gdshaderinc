const uint  g_sss_max_steps                     = uint(64); 
const float g_sss_ray_max_distance              = 1.0;
const float g_sss_thickness        				= 0.02f;  // Depth testing thickness.
const highp float g_sss_step_length             = g_sss_ray_max_distance / float(g_sss_max_steps);

#define CONTACT_SHADOW(depth, model) (compute_contact_shadows(depth, SCREEN_UV, model, VIEW_MATRIX, INV_VIEW_MATRIX, PROJECTION_MATRIX, INV_PROJECTION_MATRIX)) 

float compute_contact_shadows(sampler2D depth_texture, vec2 screen_uv, mat4 model, mat4 view, mat4 inv_view, mat4 proj, mat4 inv_proj)
{
	float depth = 1.0 - texture(depth_texture, screen_uv).r;
	
	vec4 ndc = vec4(screen_uv * 2.0 - 1.0, depth, 1.0);
	vec4 view_pos = inv_proj * ndc;
	view_pos.xyz /= view_pos.w;
	vec4 world_pos = (inv_view * view_pos);
	
	vec4 center = (model * vec4(vec3(0.0), 1.0));
	
	
	vec3 rayStartWS = world_pos.xyz;
	vec3 rayEndWS = rayStartWS + (rayDirWS);
	
	vec4 rayStartVS = view * vec4(rayStartWS, 1.0);
	vec4 rayEndVS = view * vec4(rayEndWS, 1.0);
	
	vec3 rayDirVS = rayEndVS.xyz - rayStartVS.xyz;
	
	vec3 rayStep = rayDirVS * float(g_sss_step_length);
	
	vec4 rayPos = rayStartVS + vec4(rayStep, 0.0);
	
	bool occ = false;
	
	for (uint i = uint(0); i < g_sss_max_steps; i++)
	{
		rayPos += vec4(rayStep, 0.0);
		vec4 rayPosCS = proj * rayPos;
		rayPosCS.xyz /= rayPosCS.w;
		vec2 rayUV = rayPosCS.xy * 0.5 + 0.5;
		
		float depthSample = 1.0 - texture(depth_texture, rayUV).r;
		
		if (depthSample < rayPosCS.z)
		{
			occ = true;
			return 0.0;
		}
	}
	
	return 1.0;
}