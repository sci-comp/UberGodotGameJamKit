shader_type spatial;
render_mode depth_draw_opaque, specular_schlick_ggx, depth_prepass_alpha;

uniform vec4 TopColor : source_color = vec4(0.24, 0.47, 0.27, 1.0);
uniform vec4 BottomColor : source_color = vec4(0.13, 0.33, 0.25, 1.0);
uniform sampler2D Alpha;
uniform vec4 FresnelColor : source_color = vec4(0.58, 0.65, 0.33, 1.0);

uniform float WindScale : hint_range(1.0, 20.0) = 1.0;
uniform float WindStrength : hint_range(1.0, 20.0) = 5.0;
uniform float WindDensity : hint_range(1.0, 20.0) = 5.0;
uniform float ClampTop : hint_range(0.0, 1.0) = 1.0;
uniform float ClampBtm : hint_range(-1.0, 0.0) = 0.0;
uniform float MeshScale : hint_range(-5.0, 5.0) = -0.333;
uniform float ColorRamp : hint_range(0.05, 5.0) = 0.3;

uniform float FaceRoationVariation : hint_range(-3.0, 3.0) = 1.0;

uniform float FresnelStrength : hint_range(-2.0, 2.0) = 0.5;
uniform float FresnelBlend : hint_range(-1.0, 1.0) = 1.0;
uniform bool DeactivateGlobalVariation;

uniform sampler2D WiggleNoise : hint_default_black;
uniform float WiggleFrequency = 3.0;
uniform float WiggleStrength = 0.1;
uniform float WiggleSpeed = 1.0;
uniform float WiggleScale = 3.0;

uniform float DistanceScale : hint_range(0.0, 5.0) = 0.5;
uniform float DistanceStart = 0;
uniform float DistanceScaleRange = 70;

varying vec3 obj_vertex;

vec2 rotateUV(vec2 uv, float rotation, vec2 mid)
{
	float cosAngle = cos(rotation);
	float sinAngle = sin(rotation);
	return vec2(
		cosAngle * (uv.x - mid.x) + sinAngle * (uv.y - mid.y) + mid.x,
		cosAngle * (uv.y - mid.y) - sinAngle * (uv.x - mid.x) + mid.y
	);
}

void vertex() {
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vec3 camera_pos = (INV_VIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
    vec3 distance_vector = world_pos - camera_pos;
    float square_distance = dot(distance_vector, distance_vector);
    float square_end = pow(DistanceScaleRange + DistanceStart, 2.0);
    float square_start = pow(DistanceStart, 2.0);
    float square_range = square_end - square_start;
    float distance_influence = clamp((square_distance - square_start) / square_range, 0.0, 1.0);

    vec3 orient_2d = vec3(1.0 - UV.x, 1.0 - UV.y, 0.0) * 2.0 - 1.0;
    orient_2d *= -MeshScale * (1.0 + distance_influence * DistanceScale);

    float angle = 6.248 * UV2.x * FaceRoationVariation;
    mat3 rotation = mat3(vec3(cos(angle), -sin(angle), 0.0), vec3(sin(angle), cos(angle), 0.0), vec3(0.0, 0.0, 0.0));
    orient_2d *= rotation;

    vec3 oriented_offset = reflect((INV_VIEW_MATRIX * vec4(orient_2d, 0.0)).xyz, INV_VIEW_MATRIX[0].xyz);
    vec3 obj_oriented_offset = (vec4(oriented_offset, 0.0) * MODEL_MATRIX).xyz;

    float contribution = 1.0 - float(DeactivateGlobalVariation);
    vec3 world_pos_eff = world_pos * contribution;
    float positional_influence = VERTEX.x - VERTEX.z + world_pos_eff.x - world_pos_eff.z;
    float offset = fract(positional_influence / WindScale + TIME * WindScale / 1000.0);
    offset = 2.0 * min(1.0 - offset, offset);

    float t = TIME + sin(TIME + offset + cos(TIME + offset * WindStrength * 2.0) * WindStrength);
    float mask = clamp(VERTEX.y * WindDensity, 0.0, 1.0) * (ClampTop - ClampBtm) + ClampBtm;

    vec3 wind_offset = vec3(VERTEX.x, VERTEX.y, VERTEX.z) * sin(t) / 20.0 * WindStrength * offset * mask;

    float col = VERTEX.y * ColorRamp;
    COLOR = vec4(col, positional_influence, distance_influence, 1.0);
    VERTEX += obj_oriented_offset + wind_offset;
    obj_vertex = VERTEX;
}

void fragment()
{
	float rate_col = clamp(COLOR.r, 0.0, 1.0);
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	
	vec3 albedo = mix(BottomColor.rgb, TopColor.rgb, rate_col);
	vec3 fres_col = mix(albedo, FresnelColor.rgb, FresnelStrength);
	fres_col *= fresnel * rate_col * FresnelBlend;

	vec2 wiggle_uv = normalize(obj_vertex.xz) / WiggleScale;
	float wiggle = texture(WiggleNoise, wiggle_uv + TIME * WiggleSpeed).r;
	wiggle *= clamp(sin(TIME * WiggleFrequency + COLOR.g * 0.2), 0.0, 1.0) * WiggleStrength;

	vec2 uv = rotateUV(UV, wiggle, vec2(0.5));
	vec3 tex = texture(Alpha, uv).rgb;
	float alpha = clamp(mix(tex.r, tex.g * 10.0, COLOR.b), 0.0, 1.0);
	
	ALBEDO = albedo;
	ALPHA = alpha;
	EMISSION = fres_col;
}
