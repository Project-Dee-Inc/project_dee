const uint  g_sss_max_steps                     = uint(64); 
const float g_sss_ray_max_distance              = 1.0;
const highp float g_sss_step_length             = g_sss_ray_max_distance / float(g_sss_max_steps);

#define CONTACT_SHADOW(depth, model) (compute_contact_shadows(depth, SCREEN_UV, model, VIEW_MATRIX, INV_VIEW_MATRIX, PROJECTION_MATRIX, INV_PROJECTION_MATRIX)) 

float compute_contact_shadows(sampler2D depth_texture, vec2 screen_uv, mat4 model, mat4 view, mat4 inv_view, mat4 proj, mat4 inv_proj)
{
	float depth = texture(depth_texture, screen_uv).r;
	
	vec3 ndc = vec3(screen_uv * 2.0 - 1.0, depth);
	vec4 world = inv_proj * vec4(ndc, 1.0);
	vec4 world_pos = (inv_view * world);
	
	vec4 center = (model * vec4(vec3(0.0), 1.0));
	
	vec3 rayDirWS = -(world_pos.xyz - center.xyz);
	
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
		
		if (rayUV.x < 0.0 || rayUV.x > 1.0 || rayUV.y < 0.0 || rayUV.y > 1.0)
			return 1.0;
		
		float depthSample = texture(depth_texture, rayUV).r;
		
		if (depthSample < rayPosCS.z)
		{
			occ = true;
			return 0.0;
		}
	}
	
	return 1.0;
}