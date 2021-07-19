#version 150

#extension GL_ARB_shading_language_include : require
#include <Globals.h>
#include <LightShadowGPUTransform.h>
#include <Params.h>
uniform vec4 CB0[53];
uniform vec4 CB8[24];
uniform vec4 CB3[3];
uniform sampler2D ShadowAtlasTexture;
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform samplerCube PrefilteredEnvTexture;
uniform sampler2D NormalMap1Texture;
uniform sampler2D NormalMap2Texture;
uniform sampler2D GBufferDepthTexture;
uniform sampler2D GBufferColorTexture;

in vec4 VARYING0;
in vec3 VARYING1;
in vec2 VARYING2;
in vec2 VARYING3;
in vec2 VARYING4;
in vec3 VARYING5;
in vec4 VARYING6;
in vec4 VARYING7;
in vec4 VARYING8;
out vec4 _entryPointOutput;

void main()
{
    vec3 f0 = CB0[7].xyz - VARYING7.xyz;
    vec3 f1 = -CB0[11].xyz;
    float f2 = clamp(dot(step(CB0[19].xyz, abs(VARYING5 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f3 = VARYING5.yzx - (VARYING5.yzx * f2);
    vec4 f4 = vec4(clamp(f2, 0.0, 1.0));
    vec4 f5 = mix(texture(LightMapTexture, f3), vec4(0.0), f4);
    vec4 f6 = mix(texture(LightGridSkylightTexture, f3), vec4(1.0), f4);
    vec3 f7 = (f5.xyz * (f5.w * 120.0)).xyz;
    float f8 = f6.x;
    float f9 = f6.y;
    vec3 f10 = f0 - CB0[41].xyz;
    vec3 f11 = f0 - CB0[42].xyz;
    vec3 f12 = f0 - CB0[43].xyz;
    vec4 f13 = vec4(f0, 1.0) * mat4(CB8[((dot(f10, f10) < CB0[41].w) ? 0 : ((dot(f11, f11) < CB0[42].w) ? 1 : ((dot(f12, f12) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f10, f10) < CB0[41].w) ? 0 : ((dot(f11, f11) < CB0[42].w) ? 1 : ((dot(f12, f12) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f10, f10) < CB0[41].w) ? 0 : ((dot(f11, f11) < CB0[42].w) ? 1 : ((dot(f12, f12) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f10, f10) < CB0[41].w) ? 0 : ((dot(f11, f11) < CB0[42].w) ? 1 : ((dot(f12, f12) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f14 = textureLod(ShadowAtlasTexture, f13.xy, 0.0);
    vec2 f15 = vec2(0.0);
    f15.x = CB0[46].z;
    vec2 f16 = f15;
    f16.y = CB0[46].w;
    float f17 = (2.0 * f13.z) - 1.0;
    float f18 = exp(CB0[46].z * f17);
    float f19 = -exp((-CB0[46].w) * f17);
    vec2 f20 = (f16 * CB0[47].y) * vec2(f18, f19);
    vec2 f21 = f20 * f20;
    float f22 = f14.x;
    float f23 = max(f14.y - (f22 * f22), f21.x);
    float f24 = f18 - f22;
    float f25 = f14.z;
    float f26 = max(f14.w - (f25 * f25), f21.y);
    float f27 = f19 - f25;
    float f28 = ((dot(VARYING6.xyz, f1) * CB0[47].x) > 0.0) ? mix(min((f18 <= f22) ? 1.0 : clamp(((f23 / (f23 + (f24 * f24))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f19 <= f25) ? 1.0 : clamp(((f26 / (f26 + (f27 * f27))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f9, clamp((length(f0 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f9;
    vec4 f29 = vec4(CB3[0].w);
    float f30 = -VARYING6.x;
    vec4 f31 = ((mix(texture(NormalMap1Texture, VARYING2), texture(NormalMap2Texture, VARYING2), f29) * VARYING0.x) + (mix(texture(NormalMap1Texture, VARYING3), texture(NormalMap2Texture, VARYING3), f29) * VARYING0.y)) + (mix(texture(NormalMap1Texture, VARYING4), texture(NormalMap2Texture, VARYING4), f29) * VARYING0.z);
    vec2 f32 = f31.wy * 2.0;
    vec2 f33 = f32 - vec2(1.0);
    float f34 = f31.x;
    vec3 f35 = vec3(dot(VARYING1, VARYING0.xyz));
    vec4 f36 = vec4(normalize(((mix(vec3(VARYING6.z, 0.0, f30), vec3(VARYING6.y, f30, 0.0), f35) * f33.x) + (mix(vec3(0.0, 1.0, 0.0), vec3(0.0, VARYING6.z, -VARYING6.y), f35) * f33.y)) + (VARYING6.xyz * sqrt(clamp(1.0 + dot(vec2(1.0) - f32, f33), 0.0, 1.0)))), f34);
    vec3 f37 = f36.xyz;
    vec3 f38 = mix(VARYING6.xyz, f37, vec3(0.25));
    vec3 f39 = normalize(VARYING7.xyz);
    vec3 f40 = f37 * f37;
    bvec3 f41 = lessThan(f37, vec3(0.0));
    vec3 f42 = vec3(f41.x ? f40.x : vec3(0.0).x, f41.y ? f40.y : vec3(0.0).y, f41.z ? f40.z : vec3(0.0).z);
    vec3 f43 = f40 - f42;
    float f44 = f43.x;
    float f45 = f43.y;
    float f46 = f43.z;
    float f47 = f42.x;
    float f48 = f42.y;
    float f49 = f42.z;
    vec2 f50 = VARYING8.xy / vec2(VARYING8.w);
    vec2 f51 = f50 + (f36.xz * 0.0500000007450580596923828125);
    vec4 f52 = texture(GBufferColorTexture, f50);
    f52.w = texture(GBufferDepthTexture, f50).x * 500.0;
    float f53 = texture(GBufferDepthTexture, f51).x * 500.0;
    vec4 f54 = texture(GBufferColorTexture, f51);
    f54.w = f53;
    vec4 f55 = mix(f52, f54, vec4(clamp(f53 - VARYING8.w, 0.0, 1.0)));
    vec3 f56 = f55.xyz;
    vec3 f57 = -f39;
    vec3 f58 = reflect(f57, f38);
    float f59 = VARYING8.w * 0.20000000298023223876953125;
    vec4 f60 = vec4(f58, 0.0);
    vec4 f61 = f60 * mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    vec2 f62 = (f61.xy * 0.5) + vec2(0.5 * f61.w);
    vec4 f63 = vec4(f62.x, f62.y, f61.z, f61.w);
    float f64 = VARYING8.w * (-0.20000000298023223876953125);
    float f65 = 1.0 + clamp(0.0, f64, f59);
    vec4 f66 = VARYING8 + (f63 * f65);
    float f67 = f66.w;
    float f68 = f65 + clamp((texture(GBufferDepthTexture, f66.xy / vec2(f67)).x * 500.0) - f67, f64, f59);
    vec4 f69 = VARYING8 + (f63 * f68);
    float f70 = f69.w;
    float f71 = f68 + clamp((texture(GBufferDepthTexture, f69.xy / vec2(f70)).x * 500.0) - f70, f64, f59);
    vec4 f72 = VARYING8 + (f63 * f71);
    float f73 = f72.w;
    float f74 = f71 + clamp((texture(GBufferDepthTexture, f72.xy / vec2(f73)).x * 500.0) - f73, f64, f59);
    vec4 f75 = VARYING8 + (f63 * f74);
    float f76 = f75.w;
    float f77 = f74 + clamp((texture(GBufferDepthTexture, f75.xy / vec2(f76)).x * 500.0) - f76, f64, f59);
    vec4 f78 = VARYING8 + (f63 * f77);
    float f79 = f78.w;
    float f80 = f77 + clamp((texture(GBufferDepthTexture, f78.xy / vec2(f79)).x * 500.0) - f79, f64, f59);
    vec4 f81 = VARYING8 + (f63 * f80);
    float f82 = f81.w;
    float f83 = f80 + clamp((texture(GBufferDepthTexture, f81.xy / vec2(f82)).x * 500.0) - f82, f64, f59);
    vec4 f84 = VARYING8 + (f63 * f83);
    float f85 = f84.w;
    vec4 f86 = VARYING8 + (f63 * (f83 + clamp((texture(GBufferDepthTexture, f84.xy / vec2(f85)).x * 500.0) - f85, f64, f59)));
    float f87 = f86.w;
    vec2 f88 = f86.xy / vec2(f87);
    vec3 f89 = texture(GBufferColorTexture, f88).xyz;
    vec3 f90 = normalize(f1 + f39);
    float f91 = f34 * f34;
    float f92 = max(0.001000000047497451305389404296875, dot(f37, f90));
    float f93 = dot(f1, f90);
    float f94 = 1.0 - f93;
    float f95 = f94 * f94;
    float f96 = (f95 * f95) * f94;
    float f97 = f91 * f91;
    float f98 = (((f92 * f97) - f92) * f92) + 1.0;
    vec3 f99 = mix(mix(((f56 * f56) * CB0[15].x).xyz, ((min(f7 + (CB0[27].xyz + (CB0[28].xyz * f8)), vec3(CB0[16].w)) + (((((((CB0[35].xyz * f44) + (CB0[37].xyz * f45)) + (CB0[39].xyz * f46)) + (CB0[36].xyz * f47)) + (CB0[38].xyz * f48)) + (CB0[40].xyz * f49)) + (((((((CB0[29].xyz * f44) + (CB0[31].xyz * f45)) + (CB0[33].xyz * f46)) + (CB0[30].xyz * f47)) + (CB0[32].xyz * f48)) + (CB0[34].xyz * f49)) * f8))) + (CB0[10].xyz * f28)) * CB3[1].xyz, vec3(clamp(clamp(((f55.w - VARYING8.w) * CB3[2].x) + CB3[2].y, 0.0, 1.0) + clamp((VARYING8.w * 0.0040000001899898052215576171875) - 1.0, 0.0, 1.0), 0.0, 1.0))), mix((textureLod(PrefilteredEnvTexture, f60.xyz, 0.0).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f58.y * 1.58823525905609130859375, 0.0, 1.0)))) * f8, (f89 * f89) * CB0[15].x, vec3((((float(abs(f88.x - 0.5) < 0.550000011920928955078125) * float(abs(f88.y - 0.5) < 0.5)) * clamp(3.900000095367431640625 - (max(VARYING8.w, f87) * 0.008000000379979610443115234375), 0.0, 1.0)) * float(abs((texture(GBufferDepthTexture, f88).x * 500.0) - f87) < 10.0)) * float(f61.w > 0.0))) + (f7 * 0.100000001490116119384765625), vec3(((clamp(0.7799999713897705078125 - (2.5 * abs(dot(f38, f39))), 0.0, 1.0) + 0.300000011920928955078125) * VARYING0.w) * CB3[2].z)) + ((((vec3(f96) + (vec3(0.0199999995529651641845703125) * (1.0 - f96))) * (((f97 + (f97 * f97)) / (((f98 * f98) * ((f93 * 3.0) + 0.5)) * ((f92 * 0.75) + 0.25))) * clamp(dot(f37, f1) * f28, 0.0, 1.0))) * CB0[10].xyz) * clamp(1.0 - (VARYING7.w * CB0[23].y), 0.0, 1.0));
    vec4 f100 = vec4(f99.x, f99.y, f99.z, vec4(0.0).w);
    f100.w = 1.0;
    vec3 f101 = textureLod(PrefilteredEnvTexture, vec4(f57, 0.0).xyz, max(CB0[13].y, VARYING6.w) * 5.0).xyz;
    bvec3 f102 = bvec3(CB0[13].w != 0.0);
    vec3 f103 = sqrt(clamp(mix(vec3(f102.x ? CB0[14].xyz.x : f101.x, f102.y ? CB0[14].xyz.y : f101.y, f102.z ? CB0[14].xyz.z : f101.z), f100.xyz, vec3(VARYING6.w)).xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    _entryPointOutput = vec4(f103.x, f103.y, f103.z, f100.w);
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$NormalMap1Texture=s0
//$$NormalMap2Texture=s2
//$$GBufferDepthTexture=s5
//$$GBufferColorTexture=s4
