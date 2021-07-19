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
    vec3 v10 = vec3(dot(CB1[gl_InstanceID * 7 + 0].xyz, v3), dot(CB1[gl_InstanceID * 7 + 1].xyz, v3), dot(CB1[gl_InstanceID * 7 + 2].xyz, v3));
    vec2 v11 = vec2(0.0);
    v11.x = dot(CB1[gl_InstanceID * 7 + 5].xyz, v0[v2]);
    vec2 v12 = v11;
    v12.y = dot(CB1[gl_InstanceID * 7 + 5].xyz, v1[v2]);
    vec2 v13 = v12;
    v13.x = dot(CB1[gl_InstanceID * 7 + 3].xyz, v0[v2]);
    vec2 v14 = v13;
    v14.y = dot(CB1[gl_InstanceID * 7 + 3].xyz, v1[v2]);
    vec4 v15 = CB1[gl_InstanceID * 7 + 4] * mix(COLOR0 * 0.0039215688593685626983642578125, vec4(1.0), vec4(max(sign(CB1[gl_InstanceID * 7 + 3].w), 0.0)));
    vec3 v16 = CB0[7].xyz - v9;
    vec3 v17 = normalize(v16);
    vec3 v18 = v10 * ((dot(v10, v17) > 0.0) ? 1.0 : (-1.0));
    vec3 v19 = -CB0[11].xyz;
    float v20 = dot(v18, v19);
    vec4 v21 = vec4(v6, v7, v8, 1.0);
    vec4 v22 = v21 * mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    vec3 v23 = ((v9 + (v18 * 6.0)).yxz * CB0[16].xyz) + CB0[17].xyz;
    vec4 v24 = vec4(v23.x, v23.y, v23.z, vec4(0.0).w);
    v24.w = abs(CB1[gl_InstanceID * 7 + 3].w);
    vec4 v25 = vec4(v16, v22.w);
    float v26 = v15.w * 2.0;
    float v27 = clamp(v26 - 1.0, 0.0, 1.0);
    float v28 = (clamp(2.0 - (dot(v18, normalize(v25.xyz)) * 3.0), 0.0, 1.0) * 0.300000011920928955078125) * clamp(v26, 0.0, 1.0);
    vec4 v29 = v15;
    v29.w = mix(v27, 1.0, v28);
    vec4 v30 = vec4(dot(CB0[20], v21), dot(CB0[21], v21), dot(CB0[22], v21), 0.0);
    v30.w = mix(CB1[gl_InstanceID * 7 + 5].w * v27, 1.0, v28);
    float v31 = CB1[gl_InstanceID * 7 + 6].z * 0.50359570980072021484375;
    float v32 = clamp(v20, 0.0, 1.0);
    vec3 v33 = (CB0[10].xyz * v32) + (CB0[12].xyz * clamp(-v20, 0.0, 1.0));
    vec4 v34 = vec4(v33.x, v33.y, v33.z, vec4(0.0).w);
    v34.w = (v32 * CB0[23].w) * (CB1[gl_InstanceID * 7 + 6].z * exp2((v31 * dot(v18, normalize(v19 + v17))) - v31));
    gl_Position = v22;
    VARYING0 = (TEXCOORD0.xy * v12) + CB1[gl_InstanceID * 7 + 6].xy;
    VARYING1 = TEXCOORD0.zw * v14;
    VARYING2 = v29;
    VARYING3 = v24;
    VARYING4 = v25;
    VARYING5 = vec4(v18, CB1[gl_InstanceID * 7 + 6].w);
    VARYING6 = v34;
    VARYING7 = v30;
    VARYING8 = TEXCOORD2.w - 1.0;
}

