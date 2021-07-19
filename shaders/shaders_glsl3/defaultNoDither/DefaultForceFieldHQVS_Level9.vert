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
    vec4 v3 = COLOR0 * 0.0039215688593685626983642578125;
    float v4 = max(sign(CB1[gl_InstanceID * 7 + 3].w), 0.0);
    vec3 v5 = normalize(((NORMAL.xyz * 0.0078740157186985015869140625) - vec3(1.0)) / (CB1[gl_InstanceID * 7 + 3].xyz + vec3(0.001000000047497451305389404296875)));
    vec3 v6 = POSITION.xyz * CB1[gl_InstanceID * 7 + 3].xyz;
    vec4 v7 = vec4(v6.x, v6.y, v6.z, POSITION.w);
    float v8 = dot(CB1[gl_InstanceID * 7 + 0], v7);
    float v9 = dot(CB1[gl_InstanceID * 7 + 1], v7);
    float v10 = dot(CB1[gl_InstanceID * 7 + 2], v7);
    vec3 v11 = vec3(v8, v9, v10);
    float v12 = dot(CB1[gl_InstanceID * 7 + 0].xyz, v5);
    float v13 = dot(CB1[gl_InstanceID * 7 + 1].xyz, v5);
    float v14 = dot(CB1[gl_InstanceID * 7 + 2].xyz, v5);
    vec2 v15 = vec2(0.0);
    v15.x = dot(CB1[gl_InstanceID * 7 + 5].xyz, v0[v2]);
    vec2 v16 = v15;
    v16.y = dot(CB1[gl_InstanceID * 7 + 5].xyz, v1[v2]);
    vec2 v17 = v16;
    v17.x = dot(CB1[gl_InstanceID * 7 + 3].xyz, v0[v2]);
    vec2 v18 = v17;
    v18.y = dot(CB1[gl_InstanceID * 7 + 3].xyz, v1[v2]);
    vec3 v19 = CB1[gl_InstanceID * 7 + 4].xyz * mix(v3.xyz, vec3(1.0), vec3(v4));
    vec4 v20 = vec4(v19.x, v19.y, v19.z, v3.w);
    v20.w = CB1[gl_InstanceID * 7 + 4].w;
    vec4 v21 = vec4(v8, v9, v10, 1.0) * mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    vec2 v22 = TEXCOORD0.zw * v18;
    v22.x = max(0.0500000007450580596923828125, mix(1.0 - v3.w, 0.0, v4));
    vec3 v23 = ((v11 + (vec3(v12, v13, v14) * 6.0)).yxz * CB0[16].xyz) + CB0[17].xyz;
    vec4 v24 = vec4(v23.x, v23.y, v23.z, vec4(0.0).w);
    v24.w = abs(CB1[gl_InstanceID * 7 + 3].w);
    vec4 v25 = vec4(v8, v9, v10, 0.0);
    v25.w = CB1[gl_InstanceID * 7 + 6].w;
    vec4 v26 = vec4(v12, v13, v14, 0.0);
    v26.w = inversesqrt(0.1745329201221466064453125 * CB1[gl_InstanceID * 7 + 6].z);
    gl_Position = v21;
    VARYING0 = (TEXCOORD0.xy * v16) + CB1[gl_InstanceID * 7 + 6].xy;
    VARYING1 = v22;
    VARYING2 = v20;
    VARYING3 = v24;
    VARYING4 = vec4(CB0[7].xyz - v11, v21.w);
    VARYING5 = v26;
    VARYING6 = v25;
    VARYING7 = TEXCOORD2.w - 1.0;
}

