#version 150

#extension GL_ARB_shading_language_include : require
#include <Globals.h>
#include <LightShadowGPUTransform.h>
uniform vec4 CB0[53];
uniform vec4 CB8[24];
uniform vec4 CB4[36];
uniform vec4 CB5[74];
uniform sampler2D ShadowAtlasTexture;
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform samplerCube PrefilteredEnvTexture;
uniform samplerCube PrefilteredEnvIndoorTexture;
uniform samplerCube PrefilteredEnvBlendTargetTexture;
uniform sampler2D PrecomputedBRDFTexture;
uniform sampler2DArray SpecularMapTexture;
uniform sampler2DArray AlbedoMapTexture;
uniform sampler2DArray NormalMapTexture;

in vec4 VARYING0;
in vec4 VARYING1;
in vec4 VARYING2;
in vec4 VARYING3;
in vec3 VARYING4;
in vec4 VARYING5;
in vec3 VARYING6;
in vec3 VARYING7;
in vec4 VARYING8;
in vec4 VARYING9;
out vec4 _entryPointOutput;

void main()
{
    vec3 f0 = vec3(VARYING1.xy, VARYING2.x);
    vec4 f1 = texture(SpecularMapTexture, f0);
    vec3 f2 = vec3(VARYING1.zw, VARYING2.z);
    vec4 f3 = texture(SpecularMapTexture, f2);
    vec4 f4 = texture(SpecularMapTexture, VARYING3.xyz);
    vec3 f5;
    if (VARYING8.w < 1.0)
    {
        ivec3 f6 = ivec3(VARYING8.xyz + vec3(0.5));
        int f7 = f6.x;
        int f8 = f6.y;
        int f9 = f6.z;
        float f10 = dot(VARYING0.xyz, vec3(CB5[f7 * 1 + 0].z, CB5[f8 * 1 + 0].z, CB5[f9 * 1 + 0].z));
        float f11 = f1.w;
        float f12 = f3.w;
        float f13 = f4.w;
        vec3 f14 = vec3(f11, f12, f13);
        f14.x = clamp((f11 * CB5[f7 * 1 + 0].x) + CB5[f7 * 1 + 0].y, 0.0, 1.0);
        vec3 f15 = f14;
        f15.y = clamp((f12 * CB5[f8 * 1 + 0].x) + CB5[f8 * 1 + 0].y, 0.0, 1.0);
        vec3 f16 = f15;
        f16.z = clamp((f13 * CB5[f9 * 1 + 0].x) + CB5[f9 * 1 + 0].y, 0.0, 1.0);
        vec3 f17 = VARYING0.xyz * f16;
        float f18 = 1.0 / f10;
        float f19 = 0.5 * f10;
        float f20 = f17.x;
        float f21 = f17.y;
        float f22 = f17.z;
        float f23 = clamp(((f20 - max(f21, f22)) + f19) * f18, 0.0, 1.0);
        float f24 = clamp(((f21 - max(f20, f22)) + f19) * f18, 0.0, 1.0);
        float f25 = clamp(((f22 - max(f20, f21)) + f19) * f18, 0.0, 1.0);
        vec2 f26 = dFdx(VARYING1.xy);
        vec2 f27 = dFdy(VARYING1.xy);
        f5 = mix(vec3(f23, f24, f25) / vec3((f23 + f24) + f25), VARYING0.xyz, vec3(clamp((sqrt(max(dot(f26, f26), dot(f27, f27))) * 7.0) + clamp(VARYING8.w, 0.0, 1.0), 0.0, 1.0)));
    }
    else
    {
        f5 = VARYING0.xyz;
    }
    vec4 f28 = ((f1 * f5.x) + (f3 * f5.y)) + (f4 * f5.z);
    vec4 f29 = texture(AlbedoMapTexture, f0);
    vec4 f30 = texture(AlbedoMapTexture, f2);
    vec4 f31 = texture(AlbedoMapTexture, VARYING3.xyz);
    int f32 = int(VARYING9.x + 0.5);
    int f33 = int(VARYING9.y + 0.5);
    int f34 = int(VARYING9.z + 0.5);
    vec2 f35 = f29.xz - vec2(0.5);
    vec2 f36 = f30.xz - vec2(0.5);
    vec2 f37 = f31.xz - vec2(0.5);
    vec3 f38 = vec3(0.0);
    f38.x = CB4[f32 * 1 + 0].x * f29.y;
    float f39 = f35.x;
    float f40 = f35.y;
    vec3 f41 = f38;
    f41.y = (CB4[f32 * 1 + 0].y * f39) - (CB4[f32 * 1 + 0].z * f40);
    vec3 f42 = f41;
    f42.z = (CB4[f32 * 1 + 0].z * f39) + (CB4[f32 * 1 + 0].y * f40);
    vec3 f43 = vec3(0.0);
    f43.x = CB4[f33 * 1 + 0].x * f30.y;
    float f44 = f36.x;
    float f45 = f36.y;
    vec3 f46 = f43;
    f46.y = (CB4[f33 * 1 + 0].y * f44) - (CB4[f33 * 1 + 0].z * f45);
    vec3 f47 = f46;
    f47.z = (CB4[f33 * 1 + 0].z * f44) + (CB4[f33 * 1 + 0].y * f45);
    vec3 f48 = vec3(0.0);
    f48.x = CB4[f34 * 1 + 0].x * f31.y;
    float f49 = f37.x;
    float f50 = f37.y;
    vec3 f51 = f48;
    f51.y = (CB4[f34 * 1 + 0].y * f49) - (CB4[f34 * 1 + 0].z * f50);
    vec3 f52 = f51;
    f52.z = (CB4[f34 * 1 + 0].z * f49) + (CB4[f34 * 1 + 0].y * f50);
    vec4 f53 = ((vec4(f42.x, f42.y, f42.z, f29.w) * f5.x) + (vec4(f47.x, f47.y, f47.z, f30.w) * f5.y)) + (vec4(f52.x, f52.y, f52.z, f31.w) * f5.z);
    float f54 = f53.x;
    float f55 = f54 - f53.z;
    vec3 f56 = vec4(vec3(f55, f54, f55) + (vec3(f53.yzy) * vec3(1.0, 1.0, -1.0)), 0.0).xyz;
    vec3 f57 = CB0[7].xyz - VARYING5.xyz;
    float f58 = clamp(1.0 - (VARYING5.w * CB0[23].y), 0.0, 1.0);
    vec4 f59 = texture(NormalMapTexture, f0);
    vec4 f60 = texture(NormalMapTexture, f2);
    vec4 f61 = texture(NormalMapTexture, VARYING3.xyz);
    float f62 = -VARYING6.x;
    vec2 f63 = (((f59 * f5.x) + (f60 * f5.y)) + (f61 * f5.z)).wy * 2.0;
    vec2 f64 = f63 - vec2(1.0);
    vec3 f65 = normalize(((vec3(f64, sqrt(clamp(1.0 + dot(vec2(1.0) - f63, f64), 0.0, 1.0))) - vec3(0.0, 0.0, 1.0)) * inversesqrt(dot(f5, f5))) + vec3(0.0, 0.0, 1.0));
    vec3 f66 = vec3(dot(VARYING7, f5));
    vec3 f67 = vec4(normalize(((mix(vec3(VARYING6.z, 0.0, f62), vec3(VARYING6.y, f62, 0.0), f66) * f65.x) + (mix(vec3(0.0, 1.0, 0.0), vec3(0.0, VARYING6.z, -VARYING6.y), f66) * f65.y)) + (VARYING6 * f65.z)), 0.0).xyz;
    vec3 f68 = -CB0[11].xyz;
    float f69 = dot(f67, f68);
    vec3 f70 = VARYING5.xyz - (CB0[11].xyz * 0.001000000047497451305389404296875);
    float f71 = clamp(dot(step(CB0[19].xyz, abs(VARYING4 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f72 = VARYING4.yzx - (VARYING4.yzx * f71);
    vec4 f73 = texture(LightMapTexture, f72);
    vec4 f74 = texture(LightGridSkylightTexture, f72);
    vec4 f75 = vec4(clamp(f71, 0.0, 1.0));
    vec4 f76 = mix(f73, vec4(0.0), f75);
    vec4 f77 = mix(f74, vec4(1.0), f75);
    float f78 = f77.x;
    float f79 = f77.y;
    vec3 f80 = f70 - CB0[41].xyz;
    vec3 f81 = f70 - CB0[42].xyz;
    vec3 f82 = f70 - CB0[43].xyz;
    vec4 f83 = vec4(f70, 1.0) * mat4(CB8[((dot(f80, f80) < CB0[41].w) ? 0 : ((dot(f81, f81) < CB0[42].w) ? 1 : ((dot(f82, f82) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f80, f80) < CB0[41].w) ? 0 : ((dot(f81, f81) < CB0[42].w) ? 1 : ((dot(f82, f82) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f80, f80) < CB0[41].w) ? 0 : ((dot(f81, f81) < CB0[42].w) ? 1 : ((dot(f82, f82) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f80, f80) < CB0[41].w) ? 0 : ((dot(f81, f81) < CB0[42].w) ? 1 : ((dot(f82, f82) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f84 = textureLod(ShadowAtlasTexture, f83.xy, 0.0);
    vec2 f85 = vec2(0.0);
    f85.x = CB0[46].z;
    vec2 f86 = f85;
    f86.y = CB0[46].w;
    float f87 = (2.0 * f83.z) - 1.0;
    float f88 = exp(CB0[46].z * f87);
    float f89 = -exp((-CB0[46].w) * f87);
    vec2 f90 = (f86 * CB0[47].y) * vec2(f88, f89);
    vec2 f91 = f90 * f90;
    float f92 = f84.x;
    float f93 = max(f84.y - (f92 * f92), f91.x);
    float f94 = f88 - f92;
    float f95 = f84.z;
    float f96 = max(f84.w - (f95 * f95), f91.y);
    float f97 = f89 - f95;
    vec3 f98 = normalize(f57);
    float f99 = f28.y;
    float f100 = CB0[26].w * f58;
    vec3 f101 = reflect(-f98, f67);
    vec3 f102 = normalize(f68 + f98);
    float f103 = clamp(f69 * (((f69 * CB0[47].x) > 0.0) ? mix(min((f88 <= f92) ? 1.0 : clamp(((f93 / (f93 + (f94 * f94))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f89 <= f95) ? 1.0 : clamp(((f96 / (f96 + (f97 * f97))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f79, clamp((length(f70 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f79), 0.0, 1.0);
    float f104 = f99 * f99;
    float f105 = max(0.001000000047497451305389404296875, dot(f67, f102));
    float f106 = dot(f68, f102);
    float f107 = 1.0 - f106;
    float f108 = f107 * f107;
    float f109 = (f108 * f108) * f107;
    vec3 f110 = vec3(f109) + (vec3(0.039999999105930328369140625) * (1.0 - f109));
    float f111 = f104 * f104;
    float f112 = (((f105 * f111) - f105) * f105) + 1.0;
    float f113 = f99 * 5.0;
    vec3 f114 = vec4(f101, f113).xyz;
    vec3 f115 = textureLod(PrefilteredEnvIndoorTexture, f114, f113).xyz;
    vec3 f116;
    if (CB0[27].w == 0.0)
    {
        f116 = f115;
    }
    else
    {
        f116 = mix(f115, textureLod(PrefilteredEnvBlendTargetTexture, f114, f113).xyz, vec3(CB0[27].w));
    }
    vec4 f117 = texture(PrecomputedBRDFTexture, vec2(f99, max(9.9999997473787516355514526367188e-05, dot(f67, f98))));
    float f118 = f117.x;
    float f119 = f117.y;
    vec3 f120 = ((vec3(0.039999999105930328369140625) * f118) + vec3(f119)) / vec3(f118 + f119);
    vec3 f121 = f67 * f67;
    bvec3 f122 = lessThan(f67, vec3(0.0));
    vec3 f123 = vec3(f122.x ? f121.x : vec3(0.0).x, f122.y ? f121.y : vec3(0.0).y, f122.z ? f121.z : vec3(0.0).z);
    vec3 f124 = f121 - f123;
    float f125 = f124.x;
    float f126 = f124.y;
    float f127 = f124.z;
    float f128 = f123.x;
    float f129 = f123.y;
    float f130 = f123.z;
    vec3 f131 = ((((((((vec3(1.0) - (f110 * f100)) * CB0[10].xyz) * f103) + ((f76.xyz * (f76.w * 120.0)).xyz * 1.0)) + ((vec3(1.0) - (f120 * f100)) * (((((((CB0[35].xyz * f125) + (CB0[37].xyz * f126)) + (CB0[39].xyz * f127)) + (CB0[36].xyz * f128)) + (CB0[38].xyz * f129)) + (CB0[40].xyz * f130)) + (((((((CB0[29].xyz * f125) + (CB0[31].xyz * f126)) + (CB0[33].xyz * f127)) + (CB0[30].xyz * f128)) + (CB0[32].xyz * f129)) + (CB0[34].xyz * f130)) * f78)))) + (CB0[27].xyz + (CB0[28].xyz * f78))) + vec3((f28.z * 2.0) * f58)) * (f56 * f56).xyz) + (((((f110 * (((f111 + (f111 * f111)) / (((f112 * f112) * ((f106 * 3.0) + 0.5)) * ((f105 * 0.75) + 0.25))) * f103)) * CB0[10].xyz) * f58) * VARYING0.w) + ((mix(f116, textureLod(PrefilteredEnvTexture, f114, f113).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f101.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f78)) * f120) * f100));
    vec4 f132 = vec4(f131.x, f131.y, f131.z, vec4(0.0).w);
    f132.w = 1.0;
    float f133 = clamp(exp2((CB0[13].z * VARYING5.w) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f134 = textureLod(PrefilteredEnvTexture, vec4(-f57, 0.0).xyz, max(CB0[13].y, f133) * 5.0).xyz;
    bvec3 f135 = bvec3(CB0[13].w != 0.0);
    vec3 f136 = sqrt(clamp(mix(vec3(f135.x ? CB0[14].xyz.x : f134.x, f135.y ? CB0[14].xyz.y : f134.y, f135.z ? CB0[14].xyz.z : f134.z), f132.xyz, vec3(f133)).xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    _entryPointOutput = vec4(f136.x, f136.y, f136.z, f132.w);
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrefilteredEnvBlendTargetTexture=s2
//$$PrecomputedBRDFTexture=s11
//$$SpecularMapTexture=s3
//$$AlbedoMapTexture=s0
//$$NormalMapTexture=s4
