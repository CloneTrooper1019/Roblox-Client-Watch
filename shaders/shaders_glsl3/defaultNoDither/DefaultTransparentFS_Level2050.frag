#version 150

#extension GL_ARB_shading_language_include : require
#include <Globals.h>
uniform vec4 CB0[53];
uniform sampler2D ShadowMapTexture;
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform samplerCube PrefilteredEnvTexture;
uniform sampler2D Tc2DiffuseMapTexture;
uniform sampler2D DiffuseMapTexture;

in vec2 VARYING0;
in vec2 VARYING1;
in vec4 VARYING2;
in vec4 VARYING3;
in vec4 VARYING4;
in vec4 VARYING5;
in vec4 VARYING6;
out vec4 _entryPointOutput;

void main()
{
    vec4 f0 = texture(Tc2DiffuseMapTexture, VARYING1);
    vec4 f1 = mix(texture(DiffuseMapTexture, VARYING0), f0, vec4(f0.w)) * VARYING2;
    vec3 f2 = f1.xyz;
    vec3 f3 = VARYING6.xyz - (CB0[11].xyz * VARYING3.w);
    float f4 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f5 = VARYING3.yzx - (VARYING3.yzx * f4);
    vec4 f6 = vec4(clamp(f4, 0.0, 1.0));
    vec4 f7 = mix(texture(LightMapTexture, f5), vec4(0.0), f6);
    vec4 f8 = mix(texture(LightGridSkylightTexture, f5), vec4(1.0), f6);
    vec4 f9 = texture(ShadowMapTexture, f3.xy);
    float f10 = f3.z;
    float f11 = (1.0 - ((step(f9.x, f10) * clamp(CB0[24].z + (CB0[24].w * abs(f10 - 0.5)), 0.0, 1.0)) * f9.y)) * f8.y;
    vec3 f12 = (f2 * f2).xyz;
    vec3 f13 = (((VARYING5.xyz * f11) + min((f7.xyz * (f7.w * 120.0)).xyz + (CB0[27].xyz + (CB0[28].xyz * f8.x)), vec3(CB0[16].w))) * f12) + ((CB0[10].xyz * mix(vec3(0.100000001490116119384765625), f12, vec3(VARYING6.w * CB0[26].w))) * (VARYING5.w * f11));
    vec4 f14 = vec4(f13.x, f13.y, f13.z, vec4(0.0).w);
    f14.w = f1.w;
    float f15 = clamp(exp2((CB0[13].z * length(VARYING4.xyz)) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f16 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f15) * 5.0).xyz;
    bvec3 f17 = bvec3(CB0[13].w != 0.0);
    vec3 f18 = max(vec3(0.0), mix(vec3(f17.x ? CB0[14].xyz.x : f16.x, f17.y ? CB0[14].xyz.y : f16.y, f17.z ? CB0[14].xyz.z : f16.z), f14.xyz, vec3(f15)).xyz);
    _entryPointOutput = vec4(f18.x, f18.y, f18.z, f14.w);
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$Tc2DiffuseMapTexture=s0
//$$DiffuseMapTexture=s3
