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
uniform sampler2D Texture0Texture;
uniform sampler2D Texture3Texture;

varying vec2 VARYING0;

void main()
{
    vec3 _237 = texture2D(Texture0Texture, VARYING0).xyz;
    vec3 _269 = ((_237 * _237) * 4.0) + texture2D(Texture3Texture, VARYING0).xyz;
    vec3 _301 = _269 * CB1[5].x;
    vec3 _319 = ((_269 * (_301 + vec3(CB1[5].y))) / ((_269 * (_301 + vec3(CB1[5].z))) + vec3(CB1[5].w))) * CB1[6].x;
    gl_FragData[0] = vec4(dot(_319, CB1[1].xyz) + CB1[1].w, dot(_319, CB1[2].xyz) + CB1[2].w, dot(_319, CB1[3].xyz) + CB1[3].w, 1.0);
}

//$$Texture0Texture=s0
//$$Texture3Texture=s3