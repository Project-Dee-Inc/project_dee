// NOTE(david): this is the same as the other shader, but it reduces false positives for the convex
// edges. It's more expensive and only worth using if you want to color the edges differently than
// the outlines, like in the object showcase. If your lines are colored uniformly or based on light
// or whatever, this shader is of no use :)

shader_type spatial;
render_mode depth_prepass_alpha;

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform sampler2D normal_roughness_texture : hint_normal_roughness_texture, repeat_disable, filter_nearest;

group_uniforms color;
uniform vec4 albedo : source_color = vec4(0.75, 0.75, 0.75, 1.0);
uniform float roughness : hint_range(0.0, 1.0) = 1.0;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform vec4 outline_color : source_color = vec4(0, 0, 1, 1);
uniform vec4 edge_color : source_color = vec4(1, 0, 0, 1);

group_uniforms outline;
uniform float depth_threshold : hint_range(0.0, 1.0, 0.01) = 0.25;
uniform float depth_normal_threshold : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float depth_normal_threshold_scale = 2.0;

group_uniforms edge;
uniform float convex_threshold = 0.1;
uniform float concave_threshold = 0.01;
uniform float concave_depth_threshold = 0.5;

// a little function/macro to encapsulate getting the view position
vec3 _view_from_screen(vec2 _uv, float _depth, mat4 _inv_proj) {
	vec4 _upos = _inv_proj * vec4(_uv * 2.0 - 1.0, _depth, 1.0);
	return _upos.xyz / _upos.w;
}
#define view_from_screen(uv, depth_tex) _view_from_screen((uv), textureLod((depth_tex), (uv), 0.0).r, INV_PROJECTION_MATRIX)

float remap(float value, float low1, float high1, float low2, float high2) {
    return low2 + (value - low1) * (high2 - low2) / (high1 - low1);
}

void fragment() {
	ALBEDO = albedo.rgb;
	ROUGHNESS = roughness;
	METALLIC = metallic;
	
	vec2 texel_size = 1.0 / VIEWPORT_SIZE;
	
	vec3 pos[9];
	vec3 norm[9];
	float edge[9];
	
	// loop over 3x3 texel square
	for (int i = 0; i < 9; i++) {
		vec2 offset = vec2(ivec2(i%3 - 1, i/3 - 1));
		// fragment uv + neighbour offset
		vec2 uv = SCREEN_UV + offset * texel_size;
		// fragment position in view space
		pos[i] = view_from_screen(uv, depth_texture);
		// fragment normal in view space
		norm[i] = texture(normal_roughness_texture, uv).xyz * 2.0 - 1.0;
	}
	
	// TODO: get depth_thresh (and concave_thresh?) code from other shader
	// thresholding the view direction
	// NOTE(david): in orthogonal projections, normal.z is equivalent to dot(normal, -view_forward)
	float normal_diff = 1.0 - norm[4].z;
	float normal_threshold01 = clamp((normal_diff - depth_normal_threshold) / (1.0 - depth_normal_threshold), 0.0, 1.0);
	float normal_threshold = normal_threshold01 * depth_normal_threshold_scale + 1.0;
	// final depth threshold
	float depth_thresh = depth_threshold * normal_threshold;
	
	// ===== convexity/concavity ===== //
	// NOTE(david): there might a simpler way to do this, but hey it works.
	// slap the cross product into edge[i] and sum the concavity for later.
	float concave = 0.0;
	for (int i = 0; i < 9; i++) {
		vec2 offset = vec2(ivec2(i%3 - 1, i/3 - 1));
		// cross products get convexity/concavity (mostly)
		vec3 cp = cross(norm[4], norm[i]);
		edge[i] = dot(cp, vec3(offset.yx, 0));
		float conc_depth = pos[i].z - pos[4].z;
		concave += step(concave_threshold, -edge[i]) * step(conc_depth, concave_depth_threshold);
	}
	
	// ===== edge ===== //
	float is_edge = 0.0;
	// loop over direct cardinal neighbouring texels
	for (int i = 1; i <= 7; i+=2) {
		float norm_bias = i < 4 ? 1e-5 : 0.0;
		is_edge +=
			// is this below the depth threshold
			abs(pos[i].z - pos[4].z) < depth_thresh
			// is the normal more oblique; less aligned with the camera (up/left takes priority when even)
			&& norm[i].z + norm_bias > norm[4].z
			// is this a convex edge
			&& edge[i] > convex_threshold
			? 1.0 : 0.0;
	}
	
	// bias away from concavity
	is_edge = concave > 0.0 ? 0.0 : is_edge;
	
	vec4 normal_edge = is_edge > 0.0 ? edge_color : vec4(ALBEDO, 1.0);
	
	// ===== outline ===== //
	ALBEDO =
		pos[4].z - pos[1].z > depth_thresh ||
		pos[4].z - pos[3].z > depth_thresh ||
		pos[4].z - pos[5].z > depth_thresh ||
		pos[4].z - pos[7].z > depth_thresh
		? mix(ALBEDO, outline_color.rgb, outline_color.a) : mix(ALBEDO, normal_edge.rgb, normal_edge.a);
	
	// ===== DEBUGS ===== //
	float depth = texture(depth_texture, SCREEN_UV).r;
	// make it easier to see
	depth = remap(depth, 0.12, 1.0, 0.0, 1.0);
	//EMISSION = vec3(depth);
	//EMISSION = texture(normal_roughness_texture, SCREEN_UV).xyz * 2.0 - 1.0;
	
	//EMISSION = vec3(concave);
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
	
	float NdotL = max(dot(NORMAL, LIGHT), 0.0);
	float NdotV = max(dot(NORMAL, VIEW), 0.0);
	float NdotH = max(dot(NORMAL, half), 0.0);
	float LdotH = max(dot(LIGHT, half), 0.0);
	
	// Diffuse light (Lambert).
	DIFFUSE_LIGHT += (ceil(NdotL * 3.0) / 3.0) * ceil(ATTENUATION) * lightColor;
	
	// Specular light (Schlick-GGX).
	float ggxAlpha = ROUGHNESS * ROUGHNESS;
	float D = DistributionGGX(NdotH, ggxAlpha);
	float G = GeometryGGX(NdotL, NdotV, ggxAlpha);
	
	vec3 f0 = SchlickBaseReflectivity(METALLIC, SPECULAR_AMOUNT, ALBEDO);
	float LdotH5 = SchlickFresnel(LdotH);
	float f90 = clamp(50.0 * f0.g, 0.0, 1.0);
	vec3 F = f0 + (f90 - f0) * LdotH5;
	
	vec3 specularBRDF = round(max(NdotL * D * G * F, 0.0));
	SPECULAR_LIGHT += specularBRDF * LIGHT_COLOR * ATTENUATION;
}