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
out vec4 VARYING7;
out float VARYING8;

void main()
{
    vec3 v2 = (TEXCOORD2.xyz * 0.0078740157186985015869140625) - vec3(1.0);
    int v3 = int(NORMAL.w);
    vec3 v4 = normalize(((NORMAL.xyz * 0.0078740157186985015869140625) - vec3(1.0)) / (CB1[gl_InstanceID * 7 + 3].xyz + vec3(0.001000000047497451305389404296875)));
    vec3 v5 = POSITION.xyz * CB1[gl_InstanceID * 7 + 3].xyz;
    vec4 v6 = vec4(v5.x, v5.y, v5.z, POSITION.w);
    float v7 = dot(CB1[gl_InstanceID * 7 + 0], v6);
    float v8 = dot(CB1[gl_InstanceID * 7 + 1], v6);
    float v9 = dot(CB1[gl_InstanceID * 7 + 2], v6);
    vec3 v10 = vec3(v7, v8, v9);
    float v11 = dot(CB1[gl_InstanceID * 7 + 0].xyz, v4);
    float v12 = dot(CB1[gl_InstanceID * 7 + 1].xyz, v4);
    float v13 = dot(CB1[gl_InstanceID * 7 + 2].xyz, v4);
    vec3 v14 = vec3(dot(CB1[gl_InstanceID * 7 + 0].xyz, v2), dot(CB1[gl_InstanceID * 7 + 1].xyz, v2), dot(CB1[gl_InstanceID * 7 + 2].xyz, v2));
    vec2 v15 = vec2(0.0);
    v15.x = dot(CB1[gl_InstanceID * 7 + 5].xyz, v0[v3]);
    vec2 v16 = v15;
    v16.y = dot(CB1[gl_InstanceID * 7 + 5].xyz, v1[v3]);
    vec2 v17 = v16;
    v17.x = dot(CB1[gl_InstanceID * 7 + 3].xyz, v0[v3]);
    vec2 v18 = v17;
    v18.y = dot(CB1[gl_InstanceID * 7 + 3].xyz, v1[v3]);
    vec4 v19 = vec4(0.0);
    v19.w = sign(TEXCOORD2.w - 0.5);
    vec4 v20 = vec4(v7, v8, v9, 1.0) * mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    vec3 v21 = ((v10 + (vec3(v11, v12, v13) * 6.0)).yxz * CB0[16].xyz) + CB0[17].xyz;
    vec4 v22 = vec4(v21.x, v21.y, v21.z, vec4(0.0).w);
    v22.w = abs(CB1[gl_InstanceID * 7 + 3].w);
    vec4 v23 = vec4(v7, v8, v9, 0.0);
    v23.w = CB1[gl_InstanceID * 7 + 5].w;
    vec4 v24 = vec4(v11, v12, v13, 0.0);
    v24.w = 0.0;
    gl_Position = v20;
    VARYING0 = (TEXCOORD0.xy * v16) + CB1[gl_InstanceID * 7 + 6].xy;
    VARYING1 = TEXCOORD0.zw * v18;
    VARYING2 = CB1[gl_InstanceID * 7 + 4] * mix(COLOR0 * 0.0039215688593685626983642578125, vec4(1.0), vec4(max(sign(CB1[gl_InstanceID * 7 + 3].w), 0.0)));
    VARYING3 = v22;
    VARYING4 = vec4(CB0[7].xyz - v10, v20.w);
    VARYING5 = v24;
    VARYING6 = vec4(v14.x, v14.y, v14.z, v19.w);
    VARYING7 = v23;
    VARYING8 = TEXCOORD2.w - 1.0;
}

