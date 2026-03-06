shader_type canvas_item;

uniform bool enable_grayscale = false;

void fragment() {
    vec4 c = texture(TEXTURE, UV);

    if (enable_grayscale) {
        float gray = dot(c.rgb, vec3(0.299, 0.587, 0.114));
        COLOR = vec4(vec3(gray), c.a);
    } else {
        COLOR = c;
    }
}
