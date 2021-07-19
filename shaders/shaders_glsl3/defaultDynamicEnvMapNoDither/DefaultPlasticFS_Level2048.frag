#version 150

#extension GL_ARB_shading_language_include : require
#include <Globals.h>
uniform vec4 CB0[53];
uniform sampler2D ShadowMapTexture;
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform samplerCube PrefilteredEnvTexture;
uniform sampler2D StudsMapTexture;

in vec2 VARYING1;
in vec4 VARYING2;
in vec4 VARYING3;
in vec4 VARYING4;
in vec4 VARYING5;
in vec4 VARYING6;
in float VARYING7;
out vec4 _entryPointOutput;

void main()
{
    vec2 f0 = VARYING1;
    f0.y = (fract(VARYING1.y) + VARYING7) * 0.25;
    vec3 f1 = vec4((VARYING2.xyz * texture(StudsMapTexture, f0).x) * 2.0, VARYING2.w).xyz;
    vec3 f2 = VARYING6.xyz - (CB0[11].xyz * VARYING3.w);
    float f3 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f4 = VARYING3.yzx - (VARYING3.yzx * f3);
    vec4 f5 = vec4(clamp(f3, 0.0, 1.0));
    vec4 f6 = mix(texture(LightMapTexture, f4), vec4(0.0), f5);
    vec4 f7 = mix(texture(LightGridSkylightTexture, f4), vec4(1.0), f5);
    vec4 f8 = texture(ShadowMapTexture, f2.xy);
    float f9 = f2.z;
    float f10 = (1.0 - ((step(f8.x, f9) * clamp(CB0[24].z + (CB0[24].w * abs(f9 - 0.5)), 0.0, 1.0)) * f8.y)) * f7.y;
    vec3 f11 = (f1 * f1).xyz;
    vec3 f12 = (((VARYING5.xyz * f10) + min((f6.xyz * (f6.w * 120.0)).xyz + (CB0[27].xyz + (CB0[28].xyz * f7.x)), vec3(CB0[16].w))) * f11) + ((CB0[10].xyz * mix(vec3(0.100000001490116119384765625), f11, vec3(VARYING6.w * CB0[26].w))) * (VARYING5.w * f10));
    vec4 f13 = vec4(f12.x, f12.y, f12.z, vec4(0.0).w);
    f13.w = VARYING2.w;
    float f14 = clamp(exp2((CB0[13].z * length(VARYING4.xyz)) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f15 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f14) * 5.0).xyz;
    bvec3 f16 = bvec3(CB0[13].w != 0.0);
    vec3 f17 = max(vec3(0.0), mix(vec3(f16.x ? CB0[14].xyz.x : f15.x, f16.y ? CB0[14].xyz.y : f15.y, f16.z ? CB0[14].xyz.z : f15.z), f13.xyz, vec3(f14)).xyz);
    _entryPointOutput = vec4(f17.x, f17.y, f17.z, f13.w);
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$StudsMapTexture=s0
