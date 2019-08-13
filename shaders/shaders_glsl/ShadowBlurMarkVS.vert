#version 110

struct Params
{
    vec4 TextureSize;
    vec4 Params1;
    vec4 Params2;
    vec4 Params3;
    vec4 Params4;
    vec4 Params5;
    vec4 Params6;
    vec4 Bloom;
};

uniform vec4 CB1[8];
attribute vec4 POSITION;

void main()
{
    vec4 _110 = vec4(0.0);
    _110.x = dot(CB1[1], POSITION);
    vec4 _112 = _110;
    _112.y = dot(CB1[2], POSITION);
    vec4 _114 = _112;
    _114.z = 0.5;
    vec4 _116 = _114;
    _116.w = 1.0;
    gl_Position = _116;
}
