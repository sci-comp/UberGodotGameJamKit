shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform sampler2D tex_1_albedo: source_color;
uniform sampler2D tex_1_normal : hint_normal;
uniform sampler2D tex_2_albedo: source_color;
uniform sampler2D tex_2_normal : hint_normal;
uniform float blend_smoothness : hint_range(0.1, 1.0, 0.01) = 0.2;
uniform float threshold : hint_range(0.1, 1.0, 0.01) = 0.0;
uniform bool use_world_direction = false;
uniform vec3 world_direction = vec3(0.0, 1.0, 0.0);

uniform vec2 tex_scale = vec2(1.0, 1.0);

void fragment()
{
	vec4 worldPos = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
	vec2 world_uv = worldPos.xz * tex_scale;
	
    vec4 albedo1 = texture(tex_1_albedo, world_uv);
    vec4 albedo2 = texture(tex_2_albedo, world_uv);
    vec3 normal1 = texture(tex_1_normal, world_uv).rgb;
    vec3 normal2 = texture(tex_2_normal, world_uv).rgb;
    float mix_factor = 0.0;
    float addends = 0.0;

    if (use_world_direction)
    {
        // Transforming the normal texture values to a range of [-1, 1].
        vec3 unpacked_normal = normal1 * 2.0 - vec3(1.0);
        unpacked_normal.z = sqrt(max(0.0, 1.0 - dot(unpacked_normal.xy, unpacked_normal.xy)));
        
        // Transforming the 2D normal map into 3D space.
        vec3 world_tangent = (VIEW_MATRIX * vec4(TANGENT, 0.0)).xyz;
        vec3 world_binormal = (VIEW_MATRIX * vec4(BINORMAL, 0.0)).xyz;
        vec3 world_normal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
        
        // Mixing normals based on Godot's Vulkan spatial shader.
        vec3 normalmap_normal = normalize(unpacked_normal.y * world_tangent + unpacked_normal.x * world_binormal + world_normal * unpacked_normal.z);
        
        // Weight of second texture is determined by how aligned the world-space normal is with world_direction.
        mix_factor += clamp(dot(normalmap_normal, world_direction), 0.0, 1.0);
        addends += 1.0;
    }
    
    mix_factor = smoothstep(0.0, blend_smoothness, mix_factor - threshold);

    NORMAL = mix(normal1, normal2, mix_factor);
    ALBEDO = clamp(mix(albedo1, albedo2, mix_factor).rgb, vec3(0.0), vec3(1.0));
}
