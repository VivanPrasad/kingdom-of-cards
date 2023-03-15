shader_type canvas_item;

uniform sampler2D noise : repeat_enable;
uniform float transparency;
uniform vec2 scroll = vec2(0.05,0.05);

void fragment() {
	vec4 noise_col = texture(noise, UV + scroll * TIME);
	COLOR = noise_col;
	COLOR.rgb = COLOR.rrr;
	COLOR.a = transparency;
}
