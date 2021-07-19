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
    vec3 v12 = vec3(dot(CB1[gl_InstanceID * 7 + 0].xyz, v5), dot(CB1[gl_InstanceID * 7 + 1].xyz, v5), dot(CB1[gl_InstanceID * 7 + 2].xyz, v5));
    vec2 v13 = vec2(0.0);
    v13.x = dot(CB1[gl_InstanceID * 7 + 5].xyz, v0[v2]);
    vec2 v14 = v13;
    v14.y = dot(CB1[gl_InstanceID * 7 + 5].xyz, v1[v2]);
    vec2 v15 = v14;
    v15.x = dot(CB1[gl_InstanceID * 7 + 3].xyz, v0[v2]);
    vec2 v16 = v15;
    v16.y = dot(CB1[gl_InstanceID * 7 + 3].xyz, v1[v2]);
    vec3 v17 = CB1[gl_InstanceID * 7 + 4].xyz * mix(v3.xyz, vec3(1.0), vec3(v4));
    vec4 v18 = vec4(v17.x, v17.y, v17.z, v3.w);
    v18.w = CB1[gl_InstanceID * 7 + 4].w;
    vec3 v19 = CB0[7].xyz - v11;
    vec3 v20 = normalize(v19);
    vec3 v21 = v12 * ((dot(v12, v20) > 0.0) ? 1.0 : (-1.0));
    vec3 v22 = -CB0[11].xyz;
    float v23 = dot(v21, v22);
    vec4 v24 = vec4(v8, v9, v10, 1.0);
    vec4 v25 = v24 * mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    vec2 v26 = TEXCOORD0.zw * v16;
    v26.x = max(0.0500000007450580596923828125, mix(1.0 - v3.w, 0.0, v4));
    vec3 v27 = ((v11 + (v21 * 6.0)).yxz * CB0[16].xyz) + CB0[17].xyz;
    vec4 v28 = vec4(v27.x, v27.y, v27.z, vec4(0.0).w);
    v28.w = abs(CB1[gl_InstanceID * 7 + 3].w);
    float v29 = CB1[gl_InstanceID * 7 + 6].z * 0.50359570980072021484375;
    float v30 = clamp(v23, 0.0, 1.0);
    vec3 v31 = (CB0[10].xyz * v30) + (CB0[12].xyz * clamp(-v23, 0.0, 1.0));
    vec4 v32 = vec4(v31.x, v31.y, v31.z, vec4(0.0).w);
    v32.w = (v30 * CB0[23].w) * (CB1[gl_InstanceID * 7 + 6].z * exp2((v29 * dot(v21, normalize(v22 + v20))) - v29));
    vec4 v33 = vec4(dot(CB0[20], v24), dot(CB0[21], v24), dot(CB0[22], v24), 0.0);
    v33.w = CB1[gl_InstanceID * 7 + 6].w;
    gl_Position = v25;
    VARYING0 = (TEXCOORD0.xy * v14) + CB1[gl_InstanceID * 7 + 6].xy;
    VARYING1 = v26;
    VARYING2 = v18;
    VARYING3 = v28;
    VARYING4 = vec4(v19, v25.w);
    VARYING5 = vec4(v21, CB1[gl_InstanceID * 7 + 6].w);
    VARYING6 = v32;
    VARYING7 = v33;
    VARYING8 = TEXCOORD2.w - 1.0;
}

