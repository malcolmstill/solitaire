@header const m = @import("maths.zig")
@ctype mat4 m.Mat4

@vs vs
layout(binding=0) uniform vs_params {
    mat4 mvp;
};

in vec3 position;
in vec4 colour0;
in vec3 instance_pos;

out vec4 colour;

void main() {
    vec4 pos = vec4(position + instance_pos, 1.0);
    gl_Position = transpose(mvp) * pos;
    colour = colour0;
}
@end

@fs fs
in vec4 colour;
out vec4 frag_colour;

void main() {
    frag_colour = colour;
}
@end

@program cards vs fs