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
    
    vec4 albedo1;
    vec4 albedo2;
    vec3 normal1;
    vec3 normal2;
    float mix_factor = 0.0;

    // Triplanar mapping
    vec3 norm = abs(normalize(NORMAL));
    vec3 triplanarWeights = abs(norm);
    triplanarWeights /= dot(triplanarWeights, vec3(1.0));

    vec2 uvX = worldPos.zy * tex_scale;
    vec2 uvY = worldPos.xz * tex_scale;
    vec2 uvZ = worldPos.xy * tex_scale;

    albedo1 = texture(tex_1_albedo, uvX) * triplanarWeights.x + 
              texture(tex_1_albedo, uvY) * triplanarWeights.y + 
              texture(tex_1_albedo, uvZ) * triplanarWeights.z;

    albedo2 = texture(tex_2_albedo, uvX) * triplanarWeights.x + 
              texture(tex_2_albedo, uvY) * triplanarWeights.y + 
              texture(tex_2_albedo, uvZ) * triplanarWeights.z;

    normal1 = texture(tex_1_normal, uvX).rgb * triplanarWeights.x + 
              texture(tex_1_normal, uvY).rgb * triplanarWeights.y + 
              texture(tex_1_normal, uvZ).rgb * triplanarWeights.z;

    normal2 = texture(tex_2_normal, uvX).rgb * triplanarWeights.x + 
              texture(tex_2_normal, uvY).rgb * triplanarWeights.y + 
              texture(tex_2_normal, uvZ).rgb * triplanarWeights.z;

    if (use_world_direction)
    {
        vec3 unpacked_normal = normal1 * 2.0 - vec3(1.0);
        unpacked_normal.z = sqrt(max(0.0, 1.0 - dot(unpacked_normal.xy, unpacked_normal.xy)));

        vec3 world_tangent = (VIEW_MATRIX * vec4(TANGENT, 0.0)).xyz;
        vec3 world_binormal = (VIEW_MATRIX * vec4(BINORMAL, 0.0)).xyz;
        vec3 world_normal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;

        vec3 normalmap_normal = normalize(unpacked_normal.y * world_tangent + unpacked_normal.x * world_binormal + world_normal * unpacked_normal.z);

        mix_factor += clamp(dot(normalmap_normal, world_direction), 0.0, 1.0);
    }

    mix_factor = smoothstep(0.0, blend_smoothness, mix_factor - threshold);

    NORMAL = mix(normal1, normal2, mix_factor);
    ALBEDO = clamp(mix(albedo1, albedo2, mix_factor).rgb, vec3(0.0), vec3(1.0));
}
