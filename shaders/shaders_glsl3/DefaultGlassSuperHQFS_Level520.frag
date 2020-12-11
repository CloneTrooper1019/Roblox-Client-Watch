#version 150

#extension GL_ARB_shading_language_include : require
#include <Globals.h>
#include <LightShadowGPUTransform.h>
#include <MaterialParams.h>
uniform vec4 CB0[53];
uniform vec4 CB8[24];
uniform vec4 CB2[4];
uniform sampler2D ShadowAtlasTexture;
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform samplerCube PrefilteredEnvTexture;
uniform samplerCube PrefilteredEnvIndoorTexture;
uniform sampler2D PrecomputedBRDFTexture;
uniform sampler2D DiffuseMapTexture;
uniform sampler2D NormalMapTexture;
uniform sampler2D NormalDetailMapTexture;
uniform sampler2D StudsMapTexture;
uniform sampler2D SpecularMapTexture;
uniform sampler2D GBufferDepthTexture;
uniform sampler2D GBufferColorTexture;

in vec2 VARYING0;
in vec2 VARYING1;
in vec4 VARYING2;
in vec4 VARYING3;
in vec4 VARYING4;
in vec4 VARYING5;
in vec4 VARYING6;
in vec4 VARYING7;
in float VARYING8;
out vec4 _entryPointOutput;

void main()
{
    vec2 f0 = VARYING1;
    f0.y = (fract(VARYING1.y) + VARYING8) * 0.25;
    float f1 = clamp(1.0 - (VARYING4.w * CB0[23].y), 0.0, 1.0);
    vec2 f2 = VARYING0 * CB2[0].x;
    vec4 f3 = texture(DiffuseMapTexture, f2);
    vec2 f4 = texture(NormalMapTexture, f2).wy * 2.0;
    vec2 f5 = f4 - vec2(1.0);
    float f6 = sqrt(clamp(1.0 + dot(vec2(1.0) - f4, f5), 0.0, 1.0));
    vec2 f7 = (vec3(f5, f6).xy + (vec3((texture(NormalDetailMapTexture, f2 * CB2[0].w).wy * 2.0) - vec2(1.0), 0.0).xy * CB2[1].x)).xy * f1;
    float f8 = f3.w;
    vec3 f9 = ((mix(vec3(1.0), VARYING2.xyz, vec3(clamp(f8 + CB2[2].w, 0.0, 1.0))) * f3.xyz) * (1.0 + (f7.x * CB2[0].z))) * (texture(StudsMapTexture, f0).x * 2.0);
    vec4 f10 = mix(texture(SpecularMapTexture, f2 * CB2[1].w), texture(SpecularMapTexture, f2), vec4(clamp((f1 * CB2[3].z) - (CB2[2].z * CB2[3].z), 0.0, 1.0)));
    float f11 = f10.y;
    float f12 = VARYING2.w * 2.0;
    float f13 = clamp((f12 - 1.0) + f8, 0.0, 1.0);
    float f14 = clamp(f12, 0.0, 1.0);
    vec3 f15 = normalize(((VARYING6.xyz * f7.x) + (cross(VARYING5.xyz, VARYING6.xyz) * f7.y)) + (VARYING5.xyz * (f6 * 10.0)));
    vec3 f16 = -CB0[11].xyz;
    float f17 = dot(f15, f16);
    vec3 f18 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f19 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f20 = VARYING3.yzx - (VARYING3.yzx * f19);
    vec4 f21 = vec4(clamp(f19, 0.0, 1.0));
    vec4 f22 = mix(texture(LightMapTexture, f20), vec4(0.0), f21);
    vec4 f23 = mix(texture(LightGridSkylightTexture, f20), vec4(1.0), f21);
    vec3 f24 = (f22.xyz * (f22.w * 120.0)).xyz;
    float f25 = f23.x;
    float f26 = f23.y;
    vec3 f27 = f18 - CB0[41].xyz;
    vec3 f28 = f18 - CB0[42].xyz;
    vec3 f29 = f18 - CB0[43].xyz;
    vec4 f30 = vec4(f18, 1.0) * mat4(CB8[((dot(f27, f27) < CB0[41].w) ? 0 : ((dot(f28, f28) < CB0[42].w) ? 1 : ((dot(f29, f29) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f27, f27) < CB0[41].w) ? 0 : ((dot(f28, f28) < CB0[42].w) ? 1 : ((dot(f29, f29) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f27, f27) < CB0[41].w) ? 0 : ((dot(f28, f28) < CB0[42].w) ? 1 : ((dot(f29, f29) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f27, f27) < CB0[41].w) ? 0 : ((dot(f28, f28) < CB0[42].w) ? 1 : ((dot(f29, f29) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f31 = textureLod(ShadowAtlasTexture, f30.xy, 0.0);
    vec2 f32 = vec2(0.0);
    f32.x = CB0[46].z;
    vec2 f33 = f32;
    f33.y = CB0[46].w;
    float f34 = (2.0 * f30.z) - 1.0;
    float f35 = exp(CB0[46].z * f34);
    float f36 = -exp((-CB0[46].w) * f34);
    vec2 f37 = (f33 * CB0[47].y) * vec2(f35, f36);
    vec2 f38 = f37 * f37;
    float f39 = f31.x;
    float f40 = max(f31.y - (f39 * f39), f38.x);
    float f41 = f35 - f39;
    float f42 = f31.z;
    float f43 = max(f31.w - (f42 * f42), f38.y);
    float f44 = f36 - f42;
    vec3 f45 = f9 * f9;
    float f46 = length(VARYING4.xyz);
    vec3 f47 = VARYING4.xyz / vec3(f46);
    vec3 f48 = f45 * f13;
    float f49 = CB0[26].w * f1;
    float f50 = max(9.9999997473787516355514526367188e-05, dot(f15, f47));
    vec3 f51 = reflect(-f47, f15);
    float f52 = f11 * 5.0;
    vec3 f53 = vec4(f51, f52).xyz;
    vec3 f54 = textureLod(PrefilteredEnvTexture, f53, f52).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f51.y * 1.58823525905609130859375, 0.0, 1.0)));
    vec4 f55 = texture(PrecomputedBRDFTexture, vec2(f11, f50));
    vec3 f56 = normalize(f16 + f47);
    float f57 = clamp(f17 * ((f17 > 0.0) ? mix(f26, mix(min((f35 <= f39) ? 1.0 : clamp(((f40 / (f40 + (f41 * f41))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f36 <= f42) ? 1.0 : clamp(((f43 / (f43 + (f44 * f44))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f26, clamp((length(f18 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)), CB0[47].x) : 0.0), 0.0, 1.0);
    float f58 = f11 * f11;
    float f59 = max(0.001000000047497451305389404296875, dot(f15, f56));
    float f60 = dot(f16, f56);
    float f61 = 1.0 - f60;
    float f62 = f61 * f61;
    float f63 = (f62 * f62) * f61;
    vec3 f64 = vec3(f63) + (vec3(0.039999999105930328369140625) * (1.0 - f63));
    float f65 = f58 * f58;
    float f66 = (((f59 * f65) - f59) * f59) + 1.0;
    vec3 f67 = vec3(f25);
    vec3 f68 = mix(f24, f54, f67) * mix(vec3(1.0), f45, vec3(0.5));
    float f69 = f55.x;
    float f70 = f55.y;
    vec3 f71 = ((vec3(0.039999999105930328369140625) * f69) + vec3(f70)) / vec3(f69 + f70);
    vec3 f72 = f71 * f49;
    vec3 f73 = f15 * f15;
    bvec3 f74 = lessThan(f15, vec3(0.0));
    vec3 f75 = vec3(f74.x ? f73.x : vec3(0.0).x, f74.y ? f73.y : vec3(0.0).y, f74.z ? f73.z : vec3(0.0).z);
    vec3 f76 = f73 - f75;
    float f77 = f76.x;
    float f78 = f76.y;
    float f79 = f76.z;
    float f80 = f75.x;
    float f81 = f75.y;
    float f82 = f75.z;
    vec3 f83 = ((((((CB0[35].xyz * f77) + (CB0[37].xyz * f78)) + (CB0[39].xyz * f79)) + (CB0[36].xyz * f80)) + (CB0[38].xyz * f81)) + (CB0[40].xyz * f82)) + (((((((CB0[29].xyz * f77) + (CB0[31].xyz * f78)) + (CB0[33].xyz * f79)) + (CB0[30].xyz * f80)) + (CB0[32].xyz * f81)) + (CB0[34].xyz * f82)) * f25);
    vec3 f84 = (mix(textureLod(PrefilteredEnvIndoorTexture, f53, f52).xyz, f54, f67) * f71) * f49;
    float f85 = 1.0 - f50;
    float f86 = 1.0 - VARYING2.w;
    float f87 = mix(0.660000026226043701171875, 1.0, f86 * f86);
    mat4 f88 = mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    vec4 f89 = vec4(CB0[7].xyz - VARYING4.xyz, 1.0) * f88;
    vec4 f90 = vec4(CB0[7].xyz - ((VARYING4.xyz * (1.0 + ((3.0 * f87) / max(dot(VARYING4.xyz, f15), 0.00999999977648258209228515625)))) + (f15 * (3.0 * (1.0 - f87)))), 1.0) * f88;
    float f91 = f89.w;
    vec2 f92 = ((f89.xy * 0.5) + vec2(0.5 * f91)).xy / vec2(f91);
    float f93 = f90.w;
    vec2 f94 = ((f90.xy * 0.5) + vec2(0.5 * f93)).xy / vec2(f93);
    vec2 f95 = f94 - vec2(0.5);
    vec2 f96 = (f94 - f92) * clamp(vec2(1.0) - ((f95 * f95) * 4.0), vec2(0.0), vec2(1.0));
    vec2 f97 = normalize(f96) * CB0[23].x;
    vec4 f98 = texture(GBufferColorTexture, f92 + (f96 * clamp(min(texture(GBufferDepthTexture, f94 + f97).x * 500.0, texture(GBufferDepthTexture, f94 - f97).x * 500.0) - f91, 0.0, 1.0)));
    vec3 f99 = f98.xyz;
    vec3 f100 = ((f99 * f99) * CB0[15].x).xyz;
    vec3 f101 = f100 * mix(vec3(1.0), VARYING2.xyz, vec3(f14));
    vec4 f102 = vec4(f101.x, f101.y, f101.z, vec4(0.0).w);
    f102.w = mix(1.0, f98.w, dot(f101.xyz, vec3(1.0)) / (dot(f100, vec3(1.0)) + 0.00999999977648258209228515625));
    vec4 f103 = mix(mix(f102, vec4(mix(((((((vec3(1.0) - (f64 * f49)) * CB0[10].xyz) * f57) + ((((vec3(1.0) - f72) * f83) * CB0[25].w) * f13)) + (CB0[27].xyz + (CB0[28].xyz * f25))) * f48) + ((f24 * mix(f48, f84 * (1.0 / (max(max(f83.x, f83.y), f83.z) + 0.00999999977648258209228515625)), f72 * (f49 * (1.0 - f25)))) * f13), f68, vec3(VARYING7.w)), 1.0), vec4(f13)), vec4(f68, 1.0), vec4(((f85 * f85) * 0.800000011920928955078125) * f14)) + vec4(((f64 * (((f65 + (f65 * f65)) / (((f66 * f66) * ((f60 * 3.0) + 0.5)) * ((f59 * 0.75) + 0.25))) * f57)) * CB0[10].xyz) + (f84 * f13), 0.0);
    float f104 = clamp(exp2((CB0[13].z * f46) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f105 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f104) * 5.0).xyz;
    bvec3 f106 = bvec3(CB0[13].w != 0.0);
    vec3 f107 = mix(vec3(f106.x ? CB0[14].xyz.x : f105.x, f106.y ? CB0[14].xyz.y : f105.y, f106.z ? CB0[14].xyz.z : f105.z), f103.xyz, vec3(f104));
    vec4 f108 = vec4(f107.x, f107.y, f107.z, f103.w);
    f108.w = f104 * f103.w;
    vec3 f109 = sqrt(clamp(f108.xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    _entryPointOutput = vec4(f109.x, f109.y, f109.z, f108.w);
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrecomputedBRDFTexture=s11
//$$DiffuseMapTexture=s3
//$$NormalMapTexture=s4
//$$NormalDetailMapTexture=s8
//$$StudsMapTexture=s0
//$$SpecularMapTexture=s5
//$$GBufferDepthTexture=s10
//$$GBufferColorTexture=s9
