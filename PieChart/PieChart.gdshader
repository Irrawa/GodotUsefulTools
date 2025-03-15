shader_type canvas_item;

uniform int using_share_num : hint_range(1, 32) = 3;
uniform vec4 colors[32] : source_color;
uniform float shares[32]; 
uniform float relative_size : hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float blur_strength : hint_range(0.0, 0.1, 0.005) = 0.01;

void fragment() {
    float angle = (atan(0.5 - UV.x, UV.y - 0.5) + PI) / (2.0 * PI);
    float r = length(UV - vec2(0.5));
    float last_shares = 0.0;
    float tot_shares = 0.0;

    if (r > relative_size) {
        COLOR.a = 0.0;
        discard;
    }

    COLOR = colors[using_share_num];

    for (int i = 0; i < using_share_num; i++) {
        last_shares = tot_shares;
        tot_shares += shares[i];
        if (angle < tot_shares && angle >= last_shares) {
            COLOR = colors[i];
            break;
        }
    }
}
