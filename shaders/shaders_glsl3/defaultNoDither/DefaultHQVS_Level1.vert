#version 150

#extension GL_ARB_shading_language_include : require
#include <Globals.h>
#include <Instance.h>
const vec3 v0[16] = vec3[](vec3(0.0, 0.0, 1.0), vec3(1.0, 0.0, 0.0), vec3(1.0, 0.0, 0.0), vec3(0.0, 0.0, 1.0), vec3(1.0, 0.0, 0.0), vec3(1.0, 0.0, 0.0), vec3(1.0, 0.0, 0.0), vec3(1.0, 0.0, 0.0), vec3(0.0, 0.0, 1.0), vec3(0.0), vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), vec3(0.0, 1.0, 0.0), vec3(1.0, 0.0, 0.0), vec3(0.0, 1.0, 0.0), vec3(0.0, 1.0, 0.0));
const vec3 v1[16] = vec3[](vec3(0.0, 1.0, 0.0), vec3(0.0, 0.0, 1.0), vec3(0.0, 1.0, 0.0), vec3(0.0, 1.0, 0.0), vec3(0.0, 0.0, 1.0), vec3(0.0, 1.0, 0.0), vec3(0.0, 0.699999988079071044921875, 0.699999988079071044921875), vec3(0.0, 0.699999988079071044921875, 0.699999988079071044921875), vec3(0.699999988079071044921875, 0.699999988079071044921875, 0.0), vec3(0.0), vec3(0.0, 0.0, 1.0), vec3(0.0, 0.0, 1.0), vec3(1.0, 0.0, 0.0), vec3(0.0, 0.0, 1.0), vec3(0.0, 0.0, -1.0), vec3(0.0, 0.0, 1.0));

uniform vec4 CB0[53];
uniform vec4 CB1[511];
in vec4 POSITION;
in vec4 NORMAL;
in vec4 TEXCOORD0;
in vec4 TEXCOORD2;
in vec4 COLOR0;
out vec2 VARYING0;
out vec2 VARYING1;
out vec4 VARYING2;
out vec4 VARYING3;
out vec4 VARYING4;
out vec4 VARYING5;
out vec4 VARYING6;
out float VARYING7;

void main()
{
    int v2 = int(NORMAL.w);
    vec3 v3 = normalize(((NORMAL.xyz * 0.0078740157186985015869140625) - vec3(1.0)) / (CB1[gl_InstanceID * 7 + 3].xyz + vec3(0.001000000047497451305389404296875)));
    vec3 v4 = POSITION.xyz * CB1[gl_InstanceID * 7 + 3].xyz;
    vec4 v5 = vec4(v4.x, v4.y, v4.z, POSITION.w);
    float v6 = dot(CB1[gl_InstanceID * 7 + 0], v5);
    float v7 = dot(CB1[gl_InstanceID * 7 + 1], v5);
    float v8 = dot(CB1[gl_InstanceID * 7 + 2], v5);
    vec3 v9 = vec3(v6, v7, v8);
    float v10 = dot(CB1[gl_InstanceID * 7 + 0].xyz, v3);
    float v11 = dot(CB1[gl_InstanceID * 7 + 1].xyz, v3);
    float v12 = dot(CB1[gl_InstanceID * 7 + 2].xyz, v3);
    vec2 v13 = vec2(0.0);
    v13.x = dot(CB1[gl_InstanceID * 7 + 5].xyz, v0[v2]);
    vec2 v14 = v13;
    v14.y = dot(CB1[gl_InstanceID * 7 + 5].xyz, v1[v2]);
    vec2 v15 = v14;
    v15.x = dot(CB1[gl_InstanceID * 7 + 3].xyz, v0[v2]);
    vec2 v16 = v15;
    v16.y = dot(CB1[gl_InstanceID * 7 + 3].xyz, v1[v2]);
    vec4 v17 = vec4(v6, v7, v8, 1.0);
    vec4 v18 = v17 * mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    vec3 v19 = ((v9 + (vec3(v10, v11, v12) * 6.0)).yxz * CB0[16].xyz) + CB0[17].xyz;
    vec4 v20 = vec4(v19.x, v19.y, v19.z, vec4(0.0).w);
    v20.w = abs(CB1[gl_InstanceID * 7 + 3].w);
    vec4 v21 = vec4(dot(CB0[20], v17), dot(CB0[21], v17), dot(CB0[22], v17), 0.0);
    v21.w = CB1[gl_InstanceID * 7 + 6].w;
    vec4 v22 = vec4(v10, v11, v12, 0.0);
    v22.w = inversesqrt(0.1745329201221466064453125 * CB1[gl_InstanceID * 7 + 6].z);
    gl_Position = v18;
    VARYING0 = (TEXCOORD0.xy * v14) + CB1[gl_InstanceID * 7 + 6].xy;
    VARYING1 = TEXCOORD0.zw * v16;
    VARYING2 = CB1[gl_InstanceID * 7 + 4] * mix(COLOR0 * 0.0039215688593685626983642578125, vec4(1.0), vec4(max(sign(CB1[gl_InstanceID * 7 + 3].w), 0.0)));
    VARYING3 = v20;
    VARYING4 = vec4(CB0[7].xyz - v9, v18.w);
    VARYING5 = v22;
    VARYING6 = v21;
    VARYING7 = TEXCOORD2.w - 1.0;
}

