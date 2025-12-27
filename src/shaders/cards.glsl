@header const m = @import("maths.zig")
@ctype mat4 m.Mat4

@vs vs
layout(binding=0) uniform vs_params {
    mat4 mvp;
};

// Vertex data
in vec2 position;
in vec4 colour0;

// Instance data
in vec2 instance_pos;
in float instance_angle;
in vec2 instance_texcoord;

out vec2 uv;

mat2 rotation(float angle) {
    return mat2(
        cos(angle), -sin(angle),
        sin(angle), cos(angle)
    );
}

void main() {
    float pi = 3.14159;
    float width_card = 62;
    float height_card = 86;
    float width_half_card = width_card/2;
    float height_half_card = height_card/2;
    mat2 rotm = rotation((pi/180) * instance_angle);
    vec2 shifter = vec2(width_half_card, height_half_card); // Shifts vertex data for rotation

    // Calculate 0..1 UV coordinates
    uv = vec2((position.x + width_card * instance_texcoord.x)/806, (position.y + height_card * instance_texcoord.y)/430);

    // Shift card back to origin for rotation
    vec2 centered_position = position - shifter;

    // Rotate and shift back
    vec2 rotated_position = shifter + rotm * centered_position;

    // Move to actual location on screen
    vec2 pos = instance_pos + rotated_position;
    
    // Finalise position through projection matrix
    gl_Position = transpose(mvp) * vec4(pos.xy, 0.0, 1.0);
}
@end

@fs fs
layout(binding=0) uniform texture2D tex;
layout(binding=0) uniform sampler samp;

in vec2 uv;
out vec4 frag_colour;

void main() {
    frag_colour = texture(sampler2D(tex, samp), uv);
}
@end

@program cards vs fs