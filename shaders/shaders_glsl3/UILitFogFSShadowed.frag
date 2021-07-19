#version 150

#extension GL_ARB_shading_language_include : require
#include <Globals.h>
#include <LightShadowGPUTransform.h>
#include <AdvancedUIShadingParams.h>
uniform vec4 CB0[53];
uniform vec4 CB8[24];
uniform vec4 CB2[1];
uniform vec4 CB3[2];
uniform sampler2D ShadowAtlasTexture;
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform samplerCube PrefilteredEnvTexture;
uniform sampler2D DiffuseMapTexture;

in vec2 VARYING0;
in vec4 VARYING1;
in vec3 VARYING2;
in vec3 VARYING3;
in vec4 VARYING4;
in vec3 VARYING5;
out vec4 _entryPointOutput;

void main()
{
    vec4 f0 = texture(DiffuseMapTexture, VARYING0);
    vec4 f1 = vec4(1.0, 1.0, 1.0, f0.x);
    bvec4 f2 = bvec4(CB2[0].y > 0.5);
    vec4 f3 = VARYING1 * vec4(f2.x ? f1.x : f0.x, f2.y ? f1.y : f0.y, f2.z ? f1.z : f0.z, f2.w ? f1.w : f0.w);
    vec2 f4 = abs(vec2((VARYING0.x * CB3[0].x) - CB3[0].y, (VARYING0.y * CB3[0].z) - CB3[0].w)) - CB3[1].xy;
    float f5 = f3.w * clamp((CB3[1].z - (length(max(f4, vec2(0.0))) + min(max(f4.x, f4.y), 0.0))) + 0.5, 0.0, 1.0);
    vec4 f6 = f3;
    f6.w = f5;
    vec4 f7 = f6;
    f7.w = f5;
    float f8 = clamp(dot(step(CB0[19].xyz, abs(VARYING3 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f9 = VARYING3.yzx - (VARYING3.yzx * f8);
    vec4 f10 = vec4(clamp(f8, 0.0, 1.0));
    vec4 f11 = mix(texture(LightMapTexture, f9), vec4(0.0), f10);
    vec4 f12 = mix(texture(LightGridSkylightTexture, f9), vec4(1.0), f10);
    float f13 = f12.y;
    vec3 f14 = VARYING4.xyz - CB0[41].xyz;
    vec3 f15 = VARYING4.xyz - CB0[42].xyz;
    vec3 f16 = VARYING4.xyz - CB0[43].xyz;
    vec4 f17 = vec4(VARYING4.xyz, 1.0) * mat4(CB8[((dot(f14, f14) < CB0[41].w) ? 0 : ((dot(f15, f15) < CB0[42].w) ? 1 : ((dot(f16, f16) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f14, f14) < CB0[41].w) ? 0 : ((dot(f15, f15) < CB0[42].w) ? 1 : ((dot(f16, f16) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f14, f14) < CB0[41].w) ? 0 : ((dot(f15, f15) < CB0[42].w) ? 1 : ((dot(f16, f16) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f14, f14) < CB0[41].w) ? 0 : ((dot(f15, f15) < CB0[42].w) ? 1 : ((dot(f16, f16) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f18 = textureLod(ShadowAtlasTexture, f17.xy, 0.0);
    vec2 f19 = vec2(0.0);
    f19.x = CB0[46].z;
    vec2 f20 = f19;
    f20.y = CB0[46].w;
    float f21 = (2.0 * f17.z) - 1.0;
    float f22 = exp(CB0[46].z * f21);
    float f23 = -exp((-CB0[46].w) * f21);
    vec2 f24 = (f20 * CB0[47].y) * vec2(f22, f23);
    vec2 f25 = f24 * f24;
    float f26 = f18.x;
    float f27 = max(f18.y - (f26 * f26), f25.x);
    float f28 = f22 - f26;
    float f29 = f18.z;
    float f30 = max(f18.w - (f29 * f29), f25.y);
    float f31 = f23 - f29;
    vec3 f32 = (f7.xyz * f7.xyz).xyz;
    float f33 = clamp(exp2((CB0[13].z * length(VARYING5)) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f34 = textureLod(PrefilteredEnvTexture, vec4(-VARYING5, 0.0).xyz, max(CB0[13].y, f33) * 5.0).xyz;
    bvec3 f35 = bvec3(CB0[13].w != 0.0);
    vec3 f36 = sqrt(clamp(mix(vec3(f35.x ? CB0[14].xyz.x : f34.x, f35.y ? CB0[14].xyz.y : f34.y, f35.z ? CB0[14].xyz.z : f34.z), mix(f32 * CB2[0].w, (min((f11.xyz * (f11.w * 120.0)).xyz + (CB0[8].xyz + (CB0[9].xyz * f12.x)), vec3(CB0[16].w)) + (VARYING2 * (((VARYING4.w * CB0[47].x) > 0.0) ? mix(min((f22 <= f26) ? 1.0 : clamp(((f27 / (f27 + (f28 * f28))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f23 <= f29) ? 1.0 : clamp(((f30 / (f30 + (f31 * f31))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f13, clamp((length(VARYING4.xyz - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f13))) * f32, vec3(CB2[0].z)).xyz, vec3(f33)).xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    _entryPointOutput = vec4(f36.x, f36.y, f36.z, f7.w);
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$DiffuseMapTexture=s0
