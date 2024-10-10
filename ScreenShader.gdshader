shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : source_color, hint_depth_texture;
uniform sampler2D EXISTING_SCREEN_TEXTURE : hint_screen_texture;

uniform float depth_range : hint_range(0.1, 100.0, 0.1);
uniform float waving_frequency : hint_range(5.0, 100.0, 0.1);
uniform float fisheye_intensity : hint_range(1.0, 100.0, 0.1);

vec3 wavingEffect(vec2 uv, vec3 screen_color) {
	//Basic waving distortion effect.
	uv.x += sin(uv.y * waving_frequency + TIME) * 0.005;
	vec3 cool = texture(EXISTING_SCREEN_TEXTURE, uv, 0.0).rgb;
	return screen_color + cool.rgb;
}

vec3 vignetteEffect(vec2 uv, vec3 screen_color) {
	float vignette = (16.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y));
	return screen_color *= vec3(pow(vignette, 0.7));
}

vec3 filmGrainEffect(vec2 uv, vec3 screen_color) {
	float noise = (fract(sin(dot(uv, vec2(6.9898, 4.233) * TIME)) * 43758.5453) - 0.7) * 0.5;
	screen_color -= noise * 0.05;
	return clamp(screen_color, 0.0, 1.0);
}

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	//This code below creates textures like depth, normal and the regular screen veiw.
	vec2 uv = SCREEN_UV;

	vec3 screen_color = texture(SCREEN_TEXTURE, uv).rgb;
	vec3 normal = texture(NORMAL_TEXTURE, uv).rgb;
	float roughness =  texture(NORMAL_TEXTURE, uv).w;

	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z / depth_range;

	//Actual fun code, where I should add effects like distortion etc.
	//ALBEDO = wavingEffect(uv, screen_color);
	vec3 filmGrain = filmGrainEffect(uv, screen_color);
	ALBEDO = vignetteEffect(uv, filmGrain);
	//ALBEDO = screen_color;


	//Basic dithering effect.
	//ALBEDO = screen_color;
	if (int(FRAGCOORD.x + FRAGCOORD.y) % 2 == 0) {
		ALBEDO = vignetteEffect(uv, filmGrain) * 0.5;
	}


	// example outputs for cool views.
	//ALBEDO = vec3(linear_depth); 	// showing depth texture
	//ALBEDO = normal; 				// showing normal texture
	//ALBEDO = vec3(roughness); 	// showing roughness texture
	//ALBEDO = screen_color;		// showing screen texture
}