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
    vec2 f4 = abs(vec2((VARYING0.x * CB3[0].x) + CB3[0].y, (VARYING0.y * CB3[0].z) + CB3[0].w)) - CB3[1].xy;
    float f5 = length(max(f4, vec2(0.0))) + min(max(f4.x, f4.y), 0.0);
    float f6 = (f3.w * clamp(CB3[1].z - f5, 0.0, 1.0)) * clamp(f5 - CB3[1].w, 0.0, 1.0);
    vec4 f7 = f3;
    f7.w = f6;
    vec4 f8 = f7;
    f8.w = f6;
    float f9 = clamp(dot(step(CB0[19].xyz, abs(VARYING3 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f10 = VARYING3.yzx - (VARYING3.yzx * f9);
    vec4 f11 = vec4(clamp(f9, 0.0, 1.0));
    vec4 f12 = mix(texture(LightMapTexture, f10), vec4(0.0), f11);
    vec4 f13 = mix(texture(LightGridSkylightTexture, f10), vec4(1.0), f11);
    float f14 = f13.y;
    vec3 f15 = VARYING4.xyz - CB0[41].xyz;
    vec3 f16 = VARYING4.xyz - CB0[42].xyz;
    vec3 f17 = VARYING4.xyz - CB0[43].xyz;
    vec4 f18 = vec4(VARYING4.xyz, 1.0) * mat4(CB8[((dot(f15, f15) < CB0[41].w) ? 0 : ((dot(f16, f16) < CB0[42].w) ? 1 : ((dot(f17, f17) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f15, f15) < CB0[41].w) ? 0 : ((dot(f16, f16) < CB0[42].w) ? 1 : ((dot(f17, f17) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f15, f15) < CB0[41].w) ? 0 : ((dot(f16, f16) < CB0[42].w) ? 1 : ((dot(f17, f17) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f15, f15) < CB0[41].w) ? 0 : ((dot(f16, f16) < CB0[42].w) ? 1 : ((dot(f17, f17) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f19 = textureLod(ShadowAtlasTexture, f18.xy, 0.0);
    vec2 f20 = vec2(0.0);
    f20.x = CB0[46].z;
    vec2 f21 = f20;
    f21.y = CB0[46].w;
    float f22 = (2.0 * f18.z) - 1.0;
    float f23 = exp(CB0[46].z * f22);
    float f24 = -exp((-CB0[46].w) * f22);
    vec2 f25 = (f21 * CB0[47].y) * vec2(f23, f24);
    vec2 f26 = f25 * f25;
    float f27 = f19.x;
    float f28 = max(f19.y - (f27 * f27), f26.x);
    float f29 = f23 - f27;
    float f30 = f19.z;
    float f31 = max(f19.w - (f30 * f30), f26.y);
    float f32 = f24 - f30;
    vec3 f33 = (f8.xyz * f8.xyz).xyz;
    float f34 = clamp(exp2((CB0[13].z * length(VARYING5)) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f35 = textureLod(PrefilteredEnvTexture, vec4(-VARYING5, 0.0).xyz, max(CB0[13].y, f34) * 5.0).xyz;
    bvec3 f36 = bvec3(CB0[13].w != 0.0);
    vec3 f37 = sqrt(clamp(mix(vec3(f36.x ? CB0[14].xyz.x : f35.x, f36.y ? CB0[14].xyz.y : f35.y, f36.z ? CB0[14].xyz.z : f35.z), mix(f33 * CB2[0].w, (min((f12.xyz * (f12.w * 120.0)).xyz + (CB0[8].xyz + (CB0[9].xyz * f13.x)), vec3(CB0[16].w)) + (VARYING2 * (((VARYING4.w * CB0[47].x) > 0.0) ? mix(min((f23 <= f27) ? 1.0 : clamp(((f28 / (f28 + (f29 * f29))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f24 <= f30) ? 1.0 : clamp(((f31 / (f31 + (f32 * f32))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f14, clamp((length(VARYING4.xyz - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f14))) * f33, vec3(CB2[0].z)).xyz, vec3(f34)).xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    _entryPointOutput = vec4(f37.x, f37.y, f37.z, f8.w);
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$DiffuseMapTexture=s0
