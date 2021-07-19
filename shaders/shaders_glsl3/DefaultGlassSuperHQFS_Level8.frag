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
uniform sampler2D SpecularMapTexture;
uniform sampler2D GBufferDepthTexture;
uniform sampler2D GBufferColorTexture;

in vec2 VARYING0;
in vec4 VARYING2;
in vec4 VARYING3;
in vec4 VARYING4;
in vec4 VARYING5;
in vec4 VARYING6;
in vec4 VARYING7;
out vec4 _entryPointOutput;

void main()
{
    float f0 = clamp(1.0 - (VARYING4.w * CB0[23].y), 0.0, 1.0);
    vec2 f1 = VARYING0 * CB2[0].x;
    vec4 f2 = texture(DiffuseMapTexture, f1);
    vec2 f3 = texture(NormalMapTexture, f1).wy * 2.0;
    vec2 f4 = f3 - vec2(1.0);
    float f5 = sqrt(clamp(1.0 + dot(vec2(1.0) - f3, f4), 0.0, 1.0));
    vec2 f6 = (vec3(f4, f5).xy + (vec3((texture(NormalDetailMapTexture, f1 * CB2[0].w).wy * 2.0) - vec2(1.0), 0.0).xy * CB2[1].x)).xy * f0;
    float f7 = f2.w;
    vec3 f8 = (mix(vec3(1.0), VARYING2.xyz, vec3(clamp(f7 + CB2[2].w, 0.0, 1.0))) * f2.xyz) * (1.0 + (f6.x * CB2[0].z));
    vec4 f9 = mix(texture(SpecularMapTexture, f1 * CB2[1].w), texture(SpecularMapTexture, f1), vec4(clamp((f0 * CB2[3].z) - (CB2[2].z * CB2[3].z), 0.0, 1.0)));
    float f10 = f9.y;
    float f11 = VARYING2.w * 2.0;
    float f12 = clamp((f11 - 1.0) + f7, 0.0, 1.0);
    float f13 = clamp(f11, 0.0, 1.0);
    float f14 = gl_FrontFacing ? 1.0 : (-1.0);
    vec3 f15 = VARYING6.xyz * f14;
    vec3 f16 = VARYING5.xyz * f14;
    vec3 f17 = normalize(((f15 * f6.x) + (cross(f16, f15) * f6.y)) + (f16 * (f5 * 10.0)));
    vec3 f18 = -CB0[11].xyz;
    float f19 = dot(f17, f18);
    vec3 f20 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f21 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f22 = VARYING3.yzx - (VARYING3.yzx * f21);
    vec4 f23 = vec4(clamp(f21, 0.0, 1.0));
    vec4 f24 = mix(texture(LightMapTexture, f22), vec4(0.0), f23);
    vec4 f25 = mix(texture(LightGridSkylightTexture, f22), vec4(1.0), f23);
    vec3 f26 = (f24.xyz * (f24.w * 120.0)).xyz;
    float f27 = f25.x;
    float f28 = f25.y;
    vec3 f29 = f20 - CB0[41].xyz;
    vec3 f30 = f20 - CB0[42].xyz;
    vec3 f31 = f20 - CB0[43].xyz;
    vec4 f32 = vec4(f20, 1.0) * mat4(CB8[((dot(f29, f29) < CB0[41].w) ? 0 : ((dot(f30, f30) < CB0[42].w) ? 1 : ((dot(f31, f31) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f29, f29) < CB0[41].w) ? 0 : ((dot(f30, f30) < CB0[42].w) ? 1 : ((dot(f31, f31) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f29, f29) < CB0[41].w) ? 0 : ((dot(f30, f30) < CB0[42].w) ? 1 : ((dot(f31, f31) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f29, f29) < CB0[41].w) ? 0 : ((dot(f30, f30) < CB0[42].w) ? 1 : ((dot(f31, f31) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f33 = textureLod(ShadowAtlasTexture, f32.xy, 0.0);
    vec2 f34 = vec2(0.0);
    f34.x = CB0[46].z;
    vec2 f35 = f34;
    f35.y = CB0[46].w;
    float f36 = (2.0 * f32.z) - 1.0;
    float f37 = exp(CB0[46].z * f36);
    float f38 = -exp((-CB0[46].w) * f36);
    vec2 f39 = (f35 * CB0[47].y) * vec2(f37, f38);
    vec2 f40 = f39 * f39;
    float f41 = f33.x;
    float f42 = max(f33.y - (f41 * f41), f40.x);
    float f43 = f37 - f41;
    float f44 = f33.z;
    float f45 = max(f33.w - (f44 * f44), f40.y);
    float f46 = f38 - f44;
    vec3 f47 = f8 * f8;
    float f48 = length(VARYING4.xyz);
    vec3 f49 = VARYING4.xyz / vec3(f48);
    vec3 f50 = f47 * f12;
    float f51 = CB0[26].w * f0;
    float f52 = max(9.9999997473787516355514526367188e-05, dot(f17, f49));
    vec3 f53 = reflect(-f49, f17);
    float f54 = f10 * 5.0;
    vec3 f55 = vec4(f53, f54).xyz;
    vec3 f56 = textureLod(PrefilteredEnvTexture, f55, f54).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f53.y * 1.58823525905609130859375, 0.0, 1.0)));
    vec4 f57 = texture(PrecomputedBRDFTexture, vec2(f10, f52));
    vec3 f58 = normalize(f18 + f49);
    float f59 = clamp(f19 * (((f19 * CB0[47].x) > 0.0) ? mix(min((f37 <= f41) ? 1.0 : clamp(((f42 / (f42 + (f43 * f43))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f38 <= f44) ? 1.0 : clamp(((f45 / (f45 + (f46 * f46))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f28, clamp((length(f20 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f28), 0.0, 1.0);
    float f60 = f10 * f10;
    float f61 = max(0.001000000047497451305389404296875, dot(f17, f58));
    float f62 = dot(f18, f58);
    float f63 = 1.0 - f62;
    float f64 = f63 * f63;
    float f65 = (f64 * f64) * f63;
    vec3 f66 = vec3(f65) + (vec3(0.039999999105930328369140625) * (1.0 - f65));
    float f67 = f60 * f60;
    float f68 = (((f61 * f67) - f61) * f61) + 1.0;
    vec3 f69 = vec3(f27);
    vec3 f70 = mix(f26, f56, f69) * mix(vec3(1.0), f47, vec3(0.5));
    float f71 = f57.x;
    float f72 = f57.y;
    vec3 f73 = ((vec3(0.039999999105930328369140625) * f71) + vec3(f72)) / vec3(f71 + f72);
    vec3 f74 = f73 * f51;
    vec3 f75 = f17 * f17;
    bvec3 f76 = lessThan(f17, vec3(0.0));
    vec3 f77 = vec3(f76.x ? f75.x : vec3(0.0).x, f76.y ? f75.y : vec3(0.0).y, f76.z ? f75.z : vec3(0.0).z);
    vec3 f78 = f75 - f77;
    float f79 = f78.x;
    float f80 = f78.y;
    float f81 = f78.z;
    float f82 = f77.x;
    float f83 = f77.y;
    float f84 = f77.z;
    vec3 f85 = (mix(textureLod(PrefilteredEnvIndoorTexture, f55, f54).xyz * f26, f56, f69) * f73) * f51;
    float f86 = 1.0 - f52;
    float f87 = 1.0 - VARYING2.w;
    float f88 = mix(0.660000026226043701171875, 1.0, f87 * f87);
    mat4 f89 = mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    vec4 f90 = vec4(CB0[7].xyz - VARYING4.xyz, 1.0) * f89;
    vec4 f91 = vec4(CB0[7].xyz - ((VARYING4.xyz * (1.0 + ((3.0 * f88) / max(dot(VARYING4.xyz, f17), 0.00999999977648258209228515625)))) + (f17 * (3.0 * (1.0 - f88)))), 1.0) * f89;
    float f92 = f90.w;
    vec2 f93 = ((f90.xy * 0.5) + vec2(0.5 * f92)).xy / vec2(f92);
    float f94 = f91.w;
    vec2 f95 = ((f91.xy * 0.5) + vec2(0.5 * f94)).xy / vec2(f94);
    vec2 f96 = f95 - vec2(0.5);
    vec2 f97 = (f95 - f93) * clamp(vec2(1.0) - ((f96 * f96) * 4.0), vec2(0.0), vec2(1.0));
    vec2 f98 = normalize(f97) * CB0[23].x;
    vec4 f99 = texture(GBufferColorTexture, f93 + (f97 * clamp(min(texture(GBufferDepthTexture, f95 + f98).x * 500.0, texture(GBufferDepthTexture, f95 - f98).x * 500.0) - f92, 0.0, 1.0)));
    vec3 f100 = f99.xyz;
    vec3 f101 = ((f100 * f100) * CB0[15].x).xyz;
    vec3 f102 = f101 * mix(vec3(1.0), VARYING2.xyz, vec3(f13));
    vec4 f103 = vec4(f102.x, f102.y, f102.z, vec4(0.0).w);
    f103.w = mix(1.0, f99.w, dot(f102.xyz, vec3(1.0)) / (dot(f101, vec3(1.0)) + 0.00999999977648258209228515625));
    vec4 f104 = mix(mix(f103, vec4(mix(((((((vec3(1.0) - (f66 * f51)) * CB0[10].xyz) * f59) + (((vec3(1.0) - f74) * (((((((CB0[35].xyz * f79) + (CB0[37].xyz * f80)) + (CB0[39].xyz * f81)) + (CB0[36].xyz * f82)) + (CB0[38].xyz * f83)) + (CB0[40].xyz * f84)) + (((((((CB0[29].xyz * f79) + (CB0[31].xyz * f80)) + (CB0[33].xyz * f81)) + (CB0[30].xyz * f82)) + (CB0[32].xyz * f83)) + (CB0[34].xyz * f84)) * f27))) * f12)) + (CB0[27].xyz + (CB0[28].xyz * f27))) * f50) + ((f26 * mix(f50, f85 * (1.0 / (max(max(f85.x, f85.y), f85.z) + 0.00999999977648258209228515625)), f74 * (f51 * (1.0 - f27)))) * f12), f70, vec3(VARYING7.w)), 1.0), vec4(f12)), vec4(f70, 1.0), vec4(((f86 * f86) * 0.800000011920928955078125) * f13)) + vec4(((f66 * (((f67 + (f67 * f67)) / (((f68 * f68) * ((f62 * 3.0) + 0.5)) * ((f61 * 0.75) + 0.25))) * f59)) * CB0[10].xyz) + (f85 * f12), 0.0);
    float f105 = clamp(exp2((CB0[13].z * f48) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f106 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f105) * 5.0).xyz;
    bvec3 f107 = bvec3(CB0[13].w != 0.0);
    vec3 f108 = mix(vec3(f107.x ? CB0[14].xyz.x : f106.x, f107.y ? CB0[14].xyz.y : f106.y, f107.z ? CB0[14].xyz.z : f106.z), f104.xyz, vec3(f105));
    vec4 f109 = vec4(f108.x, f108.y, f108.z, f104.w);
    f109.w = f105 * f104.w;
    vec3 f110 = sqrt(clamp(f109.xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    _entryPointOutput = vec4(f110.x, f110.y, f110.z, f109.w);
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
//$$SpecularMapTexture=s5
//$$GBufferDepthTexture=s10
//$$GBufferColorTexture=s9
