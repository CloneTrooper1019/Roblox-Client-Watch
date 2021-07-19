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
uniform samplerCube PrefilteredEnvBlendTargetTexture;
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
    vec4 f3 = texture(NormalMapTexture, f1);
    vec2 f4 = f3.wy * 2.0;
    vec2 f5 = f4 - vec2(1.0);
    float f6 = sqrt(clamp(1.0 + dot(vec2(1.0) - f4, f5), 0.0, 1.0));
    vec4 f7 = texture(NormalDetailMapTexture, f1 * CB2[0].w);
    vec2 f8 = (vec3(f5, f6).xy + (vec3((f7.wy * 2.0) - vec2(1.0), 0.0).xy * CB2[1].x)).xy * f0;
    float f9 = f2.w;
    vec3 f10 = (mix(vec3(1.0), VARYING2.xyz, vec3(clamp(f9 + CB2[2].w, 0.0, 1.0))) * f2.xyz) * (1.0 + (f8.x * CB2[0].z));
    vec4 f11 = texture(SpecularMapTexture, f1 * CB2[1].w);
    vec4 f12 = texture(SpecularMapTexture, f1);
    vec4 f13 = mix(f11, f12, vec4(clamp((f0 * CB2[3].z) - (CB2[2].z * CB2[3].z), 0.0, 1.0)));
    float f14 = f13.y;
    float f15 = VARYING2.w * 2.0;
    float f16 = clamp((f15 - 1.0) + f9, 0.0, 1.0);
    float f17 = clamp(f15, 0.0, 1.0);
    float f18 = gl_FrontFacing ? 1.0 : (-1.0);
    vec3 f19 = VARYING6.xyz * f18;
    vec3 f20 = VARYING5.xyz * f18;
    vec3 f21 = normalize(((f19 * f8.x) + (cross(f20, f19) * f8.y)) + (f20 * (f6 * 10.0)));
    vec3 f22 = -CB0[11].xyz;
    float f23 = dot(f21, f22);
    vec3 f24 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f25 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f26 = VARYING3.yzx - (VARYING3.yzx * f25);
    vec4 f27 = texture(LightMapTexture, f26);
    vec4 f28 = texture(LightGridSkylightTexture, f26);
    vec4 f29 = vec4(clamp(f25, 0.0, 1.0));
    vec4 f30 = mix(f27, vec4(0.0), f29);
    vec4 f31 = mix(f28, vec4(1.0), f29);
    vec3 f32 = (f30.xyz * (f30.w * 120.0)).xyz;
    float f33 = f31.x;
    float f34 = f31.y;
    vec3 f35 = f24 - CB0[41].xyz;
    vec3 f36 = f24 - CB0[42].xyz;
    vec3 f37 = f24 - CB0[43].xyz;
    vec4 f38 = vec4(f24, 1.0) * mat4(CB8[((dot(f35, f35) < CB0[41].w) ? 0 : ((dot(f36, f36) < CB0[42].w) ? 1 : ((dot(f37, f37) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f35, f35) < CB0[41].w) ? 0 : ((dot(f36, f36) < CB0[42].w) ? 1 : ((dot(f37, f37) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f35, f35) < CB0[41].w) ? 0 : ((dot(f36, f36) < CB0[42].w) ? 1 : ((dot(f37, f37) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f35, f35) < CB0[41].w) ? 0 : ((dot(f36, f36) < CB0[42].w) ? 1 : ((dot(f37, f37) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f39 = textureLod(ShadowAtlasTexture, f38.xy, 0.0);
    vec2 f40 = vec2(0.0);
    f40.x = CB0[46].z;
    vec2 f41 = f40;
    f41.y = CB0[46].w;
    float f42 = (2.0 * f38.z) - 1.0;
    float f43 = exp(CB0[46].z * f42);
    float f44 = -exp((-CB0[46].w) * f42);
    vec2 f45 = (f41 * CB0[47].y) * vec2(f43, f44);
    vec2 f46 = f45 * f45;
    float f47 = f39.x;
    float f48 = max(f39.y - (f47 * f47), f46.x);
    float f49 = f43 - f47;
    float f50 = f39.z;
    float f51 = max(f39.w - (f50 * f50), f46.y);
    float f52 = f44 - f50;
    vec3 f53 = f10 * f10;
    float f54 = length(VARYING4.xyz);
    vec3 f55 = VARYING4.xyz / vec3(f54);
    float f56 = CB0[26].w * f0;
    float f57 = max(9.9999997473787516355514526367188e-05, dot(f21, f55));
    vec3 f58 = reflect(-f55, f21);
    float f59 = f14 * 5.0;
    vec3 f60 = vec4(f58, f59).xyz;
    vec3 f61 = textureLod(PrefilteredEnvTexture, f60, f59).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f58.y * 1.58823525905609130859375, 0.0, 1.0)));
    vec3 f62 = textureLod(PrefilteredEnvIndoorTexture, f60, f59).xyz;
    vec3 f63;
    if (CB0[27].w == 0.0)
    {
        f63 = f62;
    }
    else
    {
        f63 = mix(f62, textureLod(PrefilteredEnvBlendTargetTexture, f60, f59).xyz, vec3(CB0[27].w));
    }
    vec4 f64 = texture(PrecomputedBRDFTexture, vec2(f14, f57));
    vec3 f65 = normalize(f22 + f55);
    float f66 = clamp(f23 * (((f23 * CB0[47].x) > 0.0) ? mix(min((f43 <= f47) ? 1.0 : clamp(((f48 / (f48 + (f49 * f49))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f44 <= f50) ? 1.0 : clamp(((f51 / (f51 + (f52 * f52))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f34, clamp((length(f24 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f34), 0.0, 1.0);
    float f67 = f14 * f14;
    float f68 = max(0.001000000047497451305389404296875, dot(f21, f65));
    float f69 = dot(f22, f65);
    float f70 = 1.0 - f69;
    float f71 = f70 * f70;
    float f72 = (f71 * f71) * f70;
    vec3 f73 = vec3(f72) + (vec3(0.039999999105930328369140625) * (1.0 - f72));
    float f74 = f67 * f67;
    float f75 = (((f68 * f74) - f68) * f68) + 1.0;
    vec3 f76 = vec3(f33);
    vec3 f77 = mix(f32, f61, f76) * mix(vec3(1.0), f53, vec3(0.5));
    float f78 = f64.x;
    float f79 = f64.y;
    vec3 f80 = ((vec3(0.039999999105930328369140625) * f78) + vec3(f79)) / vec3(f78 + f79);
    vec3 f81 = f21 * f21;
    bvec3 f82 = lessThan(f21, vec3(0.0));
    vec3 f83 = vec3(f82.x ? f81.x : vec3(0.0).x, f82.y ? f81.y : vec3(0.0).y, f82.z ? f81.z : vec3(0.0).z);
    vec3 f84 = f81 - f83;
    float f85 = f84.x;
    float f86 = f84.y;
    float f87 = f84.z;
    float f88 = f83.x;
    float f89 = f83.y;
    float f90 = f83.z;
    float f91 = 1.0 - f57;
    float f92 = 1.0 - VARYING2.w;
    float f93 = mix(0.660000026226043701171875, 1.0, f92 * f92);
    mat4 f94 = mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    vec4 f95 = vec4(CB0[7].xyz - VARYING4.xyz, 1.0) * f94;
    vec4 f96 = vec4(CB0[7].xyz - ((VARYING4.xyz * (1.0 + ((3.0 * f93) / max(dot(VARYING4.xyz, f21), 0.00999999977648258209228515625)))) + (f21 * (3.0 * (1.0 - f93)))), 1.0) * f94;
    float f97 = f95.w;
    vec2 f98 = ((f95.xy * 0.5) + vec2(0.5 * f97)).xy / vec2(f97);
    float f99 = f96.w;
    vec2 f100 = ((f96.xy * 0.5) + vec2(0.5 * f99)).xy / vec2(f99);
    vec2 f101 = f100 - vec2(0.5);
    vec2 f102 = (f100 - f98) * clamp(vec2(1.0) - ((f101 * f101) * 4.0), vec2(0.0), vec2(1.0));
    vec2 f103 = normalize(f102) * CB0[23].x;
    vec4 f104 = texture(GBufferColorTexture, f98 + (f102 * clamp(min(texture(GBufferDepthTexture, f100 + f103).x * 500.0, texture(GBufferDepthTexture, f100 - f103).x * 500.0) - f97, 0.0, 1.0)));
    vec3 f105 = f104.xyz;
    vec3 f106 = ((f105 * f105) * CB0[15].x).xyz;
    vec3 f107 = f106 * mix(vec3(1.0), VARYING2.xyz, vec3(f17));
    vec4 f108 = vec4(f107.x, f107.y, f107.z, vec4(0.0).w);
    f108.w = mix(1.0, f104.w, dot(f107.xyz, vec3(1.0)) / (dot(f106, vec3(1.0)) + 0.00999999977648258209228515625));
    vec4 f109 = mix(mix(f108, vec4(mix(((((((vec3(1.0) - (f73 * f56)) * CB0[10].xyz) * f66) + (f32 * f16)) + (((vec3(1.0) - (f80 * f56)) * (((((((CB0[35].xyz * f85) + (CB0[37].xyz * f86)) + (CB0[39].xyz * f87)) + (CB0[36].xyz * f88)) + (CB0[38].xyz * f89)) + (CB0[40].xyz * f90)) + (((((((CB0[29].xyz * f85) + (CB0[31].xyz * f86)) + (CB0[33].xyz * f87)) + (CB0[30].xyz * f88)) + (CB0[32].xyz * f89)) + (CB0[34].xyz * f90)) * f33))) * f16)) + (CB0[27].xyz + (CB0[28].xyz * f33))) * (f53 * f16), f77, vec3(VARYING7.w)), 1.0), vec4(f16)), vec4(f77, 1.0), vec4(((f91 * f91) * 0.800000011920928955078125) * f17)) + vec4(((f73 * (((f74 + (f74 * f74)) / (((f75 * f75) * ((f69 * 3.0) + 0.5)) * ((f68 * 0.75) + 0.25))) * f66)) * CB0[10].xyz) + (((mix(f63, f61, f76) * f80) * f56) * f16), 0.0);
    float f110 = clamp(exp2((CB0[13].z * f54) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f111 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f110) * 5.0).xyz;
    bvec3 f112 = bvec3(CB0[13].w != 0.0);
    vec3 f113 = mix(vec3(f112.x ? CB0[14].xyz.x : f111.x, f112.y ? CB0[14].xyz.y : f111.y, f112.z ? CB0[14].xyz.z : f111.z), f109.xyz, vec3(f110));
    vec4 f114 = vec4(f113.x, f113.y, f113.z, f109.w);
    f114.w = f110 * f109.w;
    vec3 f115 = sqrt(clamp(f114.xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    _entryPointOutput = vec4(f115.x, f115.y, f115.z, f114.w);
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrefilteredEnvBlendTargetTexture=s2
//$$PrecomputedBRDFTexture=s11
//$$DiffuseMapTexture=s3
//$$NormalMapTexture=s4
//$$NormalDetailMapTexture=s8
//$$SpecularMapTexture=s5
//$$GBufferDepthTexture=s10
//$$GBufferColorTexture=s9
