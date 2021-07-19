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
    vec3 v13 = vec3(v10, v11, v12);
    vec2 v14 = vec2(0.0);
    v14.x = dot(CB1[gl_InstanceID * 7 + 5].xyz, v0[v2]);
    vec2 v15 = v14;
    v15.y = dot(CB1[gl_InstanceID * 7 + 5].xyz, v1[v2]);
    vec2 v16 = v15;
    v16.x = dot(CB1[gl_InstanceID * 7 + 3].xyz, v0[v2]);
    vec2 v17 = v16;
    v17.y = dot(CB1[gl_InstanceID * 7 + 3].xyz, v1[v2]);
    vec4 v18 = CB1[gl_InstanceID * 7 + 4] * mix(COLOR0 * 0.0039215688593685626983642578125, vec4(1.0), vec4(max(sign(CB1[gl_InstanceID * 7 + 3].w), 0.0)));
    vec3 v19 = CB0[7].xyz - v9;
    vec3 v20 = -CB0[11].xyz;
    float v21 = dot(v13, v20);
    vec4 v22 = vec4(v6, v7, v8, 1.0);
    vec4 v23 = v22 * mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    vec3 v24 = ((v9 + (v13 * 6.0)).yxz * CB0[16].xyz) + CB0[17].xyz;
    vec4 v25 = vec4(v24.x, v24.y, v24.z, vec4(0.0).w);
    v25.w = abs(CB1[gl_InstanceID * 7 + 3].w);
    vec4 v26 = vec4(v19, v23.w);
    float v27 = v18.w * 2.0;
    float v28 = clamp(v27 - 1.0, 0.0, 1.0);
    float v29 = (clamp(2.0 - (dot(v13, normalize(v26.xyz)) * 3.0), 0.0, 1.0) * 0.300000011920928955078125) * clamp(v27, 0.0, 1.0);
    vec4 v30 = v18;
    v30.w = mix(v28, 1.0, v29);
    vec4 v31 = vec4(dot(CB0[20], v22), dot(CB0[21], v22), dot(CB0[22], v22), 0.0);
    v31.w = mix(CB1[gl_InstanceID * 7 + 5].w * v28, 1.0, v29);
    float v32 = CB1[gl_InstanceID * 7 + 6].z * 0.50359570980072021484375;
    float v33 = clamp(v21, 0.0, 1.0);
    vec3 v34 = (CB0[10].xyz * v33) + (CB0[12].xyz * clamp(-v21, 0.0, 1.0));
    vec4 v35 = vec4(v34.x, v34.y, v34.z, vec4(0.0).w);
    v35.w = (v33 * CB0[23].w) * (CB1[gl_InstanceID * 7 + 6].z * exp2((v32 * dot(v13, normalize(v20 + normalize(v19)))) - v32));
    gl_Position = v23;
    VARYING0 = (TEXCOORD0.xy * v15) + CB1[gl_InstanceID * 7 + 6].xy;
    VARYING1 = TEXCOORD0.zw * v17;
    VARYING2 = v30;
    VARYING3 = v25;
    VARYING4 = v26;
    VARYING5 = vec4(v10, v11, v12, CB1[gl_InstanceID * 7 + 6].w);
    VARYING6 = v35;
    VARYING7 = v31;
    VARYING8 = TEXCOORD2.w - 1.0;
}

