@header const m = @import("maths.zig")
@ctype mat4 m.Mat4

@vs vs
layout(binding=0) uniform vs_params {
    mat4 mvp;
};

in vec3 position;
in vec4 colour0;
in vec2 instance_pos;
in vec2 instance_texcoord;

out vec2 uv;

void main() {
    vec4 pos = vec4(position + vec3(instance_pos, 0.0), 1.0);
    
    gl_Position = transpose(mvp) * pos;
    
    uv = vec2((position.x + 62 * instance_texcoord.x)/806, (position.y + 86 * instance_texcoord.y)/430);
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