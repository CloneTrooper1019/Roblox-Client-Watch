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
    float f13 = gl_FrontFacing ? 1.0 : (-1.0);
    vec3 f14 = VARYING6.xyz * f13;
    vec3 f15 = VARYING5.xyz * f13;
    vec3 f16 = normalize(((f14 * f6.x) + (cross(f15, f14) * f6.y)) + (f15 * (f5 * 10.0)));
    vec3 f17 = -CB0[11].xyz;
    float f18 = dot(f16, f17);
    vec3 f19 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f20 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f21 = VARYING3.yzx - (VARYING3.yzx * f20);
    vec4 f22 = vec4(clamp(f20, 0.0, 1.0));
    vec4 f23 = mix(texture(LightMapTexture, f21), vec4(0.0), f22);
    vec4 f24 = mix(texture(LightGridSkylightTexture, f21), vec4(1.0), f22);
    vec3 f25 = (f23.xyz * (f23.w * 120.0)).xyz;
    float f26 = f24.x;
    float f27 = f24.y;
    vec3 f28 = f19 - CB0[41].xyz;
    vec3 f29 = f19 - CB0[42].xyz;
    vec3 f30 = f19 - CB0[43].xyz;
    vec4 f31 = vec4(f19, 1.0) * mat4(CB8[((dot(f28, f28) < CB0[41].w) ? 0 : ((dot(f29, f29) < CB0[42].w) ? 1 : ((dot(f30, f30) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f28, f28) < CB0[41].w) ? 0 : ((dot(f29, f29) < CB0[42].w) ? 1 : ((dot(f30, f30) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f28, f28) < CB0[41].w) ? 0 : ((dot(f29, f29) < CB0[42].w) ? 1 : ((dot(f30, f30) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f28, f28) < CB0[41].w) ? 0 : ((dot(f29, f29) < CB0[42].w) ? 1 : ((dot(f30, f30) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f32 = textureLod(ShadowAtlasTexture, f31.xy, 0.0);
    vec2 f33 = vec2(0.0);
    f33.x = CB0[46].z;
    vec2 f34 = f33;
    f34.y = CB0[46].w;
    float f35 = (2.0 * f31.z) - 1.0;
    float f36 = exp(CB0[46].z * f35);
    float f37 = -exp((-CB0[46].w) * f35);
    vec2 f38 = (f34 * CB0[47].y) * vec2(f36, f37);
    vec2 f39 = f38 * f38;
    float f40 = f32.x;
    float f41 = max(f32.y - (f40 * f40), f39.x);
    float f42 = f36 - f40;
    float f43 = f32.z;
    float f44 = max(f32.w - (f43 * f43), f39.y);
    float f45 = f37 - f43;
    vec3 f46 = f8 * f8;
    float f47 = length(VARYING4.xyz);
    vec3 f48 = VARYING4.xyz / vec3(f47);
    vec3 f49 = f46 * f12;
    float f50 = CB0[26].w * f0;
    float f51 = max(9.9999997473787516355514526367188e-05, dot(f16, f48));
    vec3 f52 = reflect(-f48, f16);
    float f53 = f10 * 5.0;
    vec3 f54 = vec4(f52, f53).xyz;
    vec3 f55 = textureLod(PrefilteredEnvTexture, f54, f53).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f52.y * 1.58823525905609130859375, 0.0, 1.0)));
    vec4 f56 = texture(PrecomputedBRDFTexture, vec2(f10, f51));
    vec3 f57 = normalize(f17 + f48);
    float f58 = clamp(f18 * (((f18 * CB0[47].x) > 0.0) ? mix(min((f36 <= f40) ? 1.0 : clamp(((f41 / (f41 + (f42 * f42))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f37 <= f43) ? 1.0 : clamp(((f44 / (f44 + (f45 * f45))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f27, clamp((length(f19 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f27), 0.0, 1.0);
    float f59 = f10 * f10;
    float f60 = max(0.001000000047497451305389404296875, dot(f16, f57));
    float f61 = dot(f17, f57);
    float f62 = 1.0 - f61;
    float f63 = f62 * f62;
    float f64 = (f63 * f63) * f62;
    vec3 f65 = vec3(f64) + (vec3(0.039999999105930328369140625) * (1.0 - f64));
    float f66 = f59 * f59;
    float f67 = (((f60 * f66) - f60) * f60) + 1.0;
    vec3 f68 = vec3(f26);
    vec3 f69 = mix(f25, f55, f68) * mix(vec3(1.0), f46, vec3(0.5));
    float f70 = f56.x;
    float f71 = f56.y;
    vec3 f72 = ((vec3(0.039999999105930328369140625) * f70) + vec3(f71)) / vec3(f70 + f71);
    vec3 f73 = f72 * f50;
    vec3 f74 = f16 * f16;
    bvec3 f75 = lessThan(f16, vec3(0.0));
    vec3 f76 = vec3(f75.x ? f74.x : vec3(0.0).x, f75.y ? f74.y : vec3(0.0).y, f75.z ? f74.z : vec3(0.0).z);
    vec3 f77 = f74 - f76;
    float f78 = f77.x;
    float f79 = f77.y;
    float f80 = f77.z;
    float f81 = f76.x;
    float f82 = f76.y;
    float f83 = f76.z;
    vec3 f84 = (mix(textureLod(PrefilteredEnvIndoorTexture, f54, f53).xyz * f25, f55, f68) * f72) * f50;
    float f85 = 1.0 - f51;
    vec4 f86 = mix(vec4(mix(((((((vec3(1.0) - (f65 * f50)) * CB0[10].xyz) * f58) + (((vec3(1.0) - f73) * (((((((CB0[35].xyz * f78) + (CB0[37].xyz * f79)) + (CB0[39].xyz * f80)) + (CB0[36].xyz * f81)) + (CB0[38].xyz * f82)) + (CB0[40].xyz * f83)) + (((((((CB0[29].xyz * f78) + (CB0[31].xyz * f79)) + (CB0[33].xyz * f80)) + (CB0[30].xyz * f81)) + (CB0[32].xyz * f82)) + (CB0[34].xyz * f83)) * f26))) * f12)) + (CB0[27].xyz + (CB0[28].xyz * f26))) * f49) + ((f25 * mix(f49, f84 * (1.0 / (max(max(f84.x, f84.y), f84.z) + 0.00999999977648258209228515625)), f73 * (f50 * (1.0 - f26)))) * f12), f69, vec3(VARYING7.w)) * f12, f12), vec4(f69, 1.0), vec4(((f85 * f85) * 0.800000011920928955078125) * clamp(f11, 0.0, 1.0))) + vec4(((f65 * (((f66 + (f66 * f66)) / (((f67 * f67) * ((f61 * 3.0) + 0.5)) * ((f60 * 0.75) + 0.25))) * f58)) * CB0[10].xyz) + (f84 * f12), 0.0);
    float f87 = clamp(exp2((CB0[13].z * f47) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f88 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f87) * 5.0).xyz;
    bvec3 f89 = bvec3(CB0[13].w != 0.0);
    vec3 f90 = mix(vec3(f89.x ? CB0[14].xyz.x : f88.x, f89.y ? CB0[14].xyz.y : f88.y, f89.z ? CB0[14].xyz.z : f88.z), f86.xyz, vec3(f87));
    vec4 f91 = vec4(f90.x, f90.y, f90.z, f86.w);
    f91.w = 1.0 - ((1.0 - f86.w) * f87);
    vec3 f92 = sqrt(clamp(f91.xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    _entryPointOutput = vec4(f92.x, f92.y, f92.z, f91.w);
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
