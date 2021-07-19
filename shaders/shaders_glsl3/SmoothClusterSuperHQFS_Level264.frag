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
    float f59 = -VARYING6.x;
    vec2 f60 = (((texture(NormalMapTexture, f0) * f5.x) + (texture(NormalMapTexture, f2) * f5.y)) + (texture(NormalMapTexture, VARYING3.xyz) * f5.z)).wy * 2.0;
    vec2 f61 = f60 - vec2(1.0);
    vec3 f62 = normalize(((vec3(f61, sqrt(clamp(1.0 + dot(vec2(1.0) - f60, f61), 0.0, 1.0))) - vec3(0.0, 0.0, 1.0)) * inversesqrt(dot(f5, f5))) + vec3(0.0, 0.0, 1.0));
    vec3 f63 = vec3(dot(VARYING7, f5));
    vec3 f64 = vec4(normalize(((mix(vec3(VARYING6.z, 0.0, f59), vec3(VARYING6.y, f59, 0.0), f63) * f62.x) + (mix(vec3(0.0, 1.0, 0.0), vec3(0.0, VARYING6.z, -VARYING6.y), f63) * f62.y)) + (VARYING6 * f62.z)), 0.0).xyz;
    vec3 f65 = -CB0[11].xyz;
    float f66 = dot(f64, f65);
    vec3 f67 = VARYING5.xyz - (CB0[11].xyz * 0.001000000047497451305389404296875);
    float f68 = clamp(dot(step(CB0[19].xyz, abs(VARYING4 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f69 = VARYING4.yzx - (VARYING4.yzx * f68);
    vec4 f70 = vec4(clamp(f68, 0.0, 1.0));
    vec4 f71 = mix(texture(LightMapTexture, f69), vec4(0.0), f70);
    vec4 f72 = mix(texture(LightGridSkylightTexture, f69), vec4(1.0), f70);
    vec3 f73 = (f71.xyz * (f71.w * 120.0)).xyz;
    float f74 = f72.x;
    float f75 = f72.y;
    vec3 f76 = f67 - CB0[41].xyz;
    vec3 f77 = f67 - CB0[42].xyz;
    vec3 f78 = f67 - CB0[43].xyz;
    vec4 f79 = vec4(f67, 1.0) * mat4(CB8[((dot(f76, f76) < CB0[41].w) ? 0 : ((dot(f77, f77) < CB0[42].w) ? 1 : ((dot(f78, f78) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f76, f76) < CB0[41].w) ? 0 : ((dot(f77, f77) < CB0[42].w) ? 1 : ((dot(f78, f78) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f76, f76) < CB0[41].w) ? 0 : ((dot(f77, f77) < CB0[42].w) ? 1 : ((dot(f78, f78) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f76, f76) < CB0[41].w) ? 0 : ((dot(f77, f77) < CB0[42].w) ? 1 : ((dot(f78, f78) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f80 = textureLod(ShadowAtlasTexture, f79.xy, 0.0);
    vec2 f81 = vec2(0.0);
    f81.x = CB0[46].z;
    vec2 f82 = f81;
    f82.y = CB0[46].w;
    float f83 = (2.0 * f79.z) - 1.0;
    float f84 = exp(CB0[46].z * f83);
    float f85 = -exp((-CB0[46].w) * f83);
    vec2 f86 = (f82 * CB0[47].y) * vec2(f84, f85);
    vec2 f87 = f86 * f86;
    float f88 = f80.x;
    float f89 = max(f80.y - (f88 * f88), f87.x);
    float f90 = f84 - f88;
    float f91 = f80.z;
    float f92 = max(f80.w - (f91 * f91), f87.y);
    float f93 = f85 - f91;
    vec3 f94 = normalize(f57);
    vec3 f95 = (f56 * f56).xyz;
    float f96 = f28.y;
    float f97 = CB0[26].w * f58;
    vec3 f98 = reflect(-f94, f64);
    vec3 f99 = normalize(f65 + f94);
    float f100 = clamp(f66 * (((f66 * CB0[47].x) > 0.0) ? mix(min((f84 <= f88) ? 1.0 : clamp(((f89 / (f89 + (f90 * f90))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f85 <= f91) ? 1.0 : clamp(((f92 / (f92 + (f93 * f93))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f75, clamp((length(f67 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f75), 0.0, 1.0);
    float f101 = f96 * f96;
    float f102 = max(0.001000000047497451305389404296875, dot(f64, f99));
    float f103 = dot(f65, f99);
    float f104 = 1.0 - f103;
    float f105 = f104 * f104;
    float f106 = (f105 * f105) * f104;
    vec3 f107 = vec3(f106) + (vec3(0.039999999105930328369140625) * (1.0 - f106));
    float f108 = f101 * f101;
    float f109 = (((f102 * f108) - f102) * f102) + 1.0;
    float f110 = f96 * 5.0;
    vec3 f111 = vec4(f98, f110).xyz;
    vec4 f112 = texture(PrecomputedBRDFTexture, vec2(f96, max(9.9999997473787516355514526367188e-05, dot(f64, f94))));
    float f113 = f112.x;
    float f114 = f112.y;
    vec3 f115 = ((vec3(0.039999999105930328369140625) * f113) + vec3(f114)) / vec3(f113 + f114);
    vec3 f116 = f115 * f97;
    vec3 f117 = f64 * f64;
    bvec3 f118 = lessThan(f64, vec3(0.0));
    vec3 f119 = vec3(f118.x ? f117.x : vec3(0.0).x, f118.y ? f117.y : vec3(0.0).y, f118.z ? f117.z : vec3(0.0).z);
    vec3 f120 = f117 - f119;
    float f121 = f120.x;
    float f122 = f120.y;
    float f123 = f120.z;
    float f124 = f119.x;
    float f125 = f119.y;
    float f126 = f119.z;
    vec3 f127 = (mix(textureLod(PrefilteredEnvIndoorTexture, f111, f110).xyz * f73, textureLod(PrefilteredEnvTexture, f111, f110).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f98.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f74)) * f115) * f97;
    vec3 f128 = ((((((((vec3(1.0) - (f107 * f97)) * CB0[10].xyz) * f100) + ((vec3(1.0) - f116) * (((((((CB0[35].xyz * f121) + (CB0[37].xyz * f122)) + (CB0[39].xyz * f123)) + (CB0[36].xyz * f124)) + (CB0[38].xyz * f125)) + (CB0[40].xyz * f126)) + (((((((CB0[29].xyz * f121) + (CB0[31].xyz * f122)) + (CB0[33].xyz * f123)) + (CB0[30].xyz * f124)) + (CB0[32].xyz * f125)) + (CB0[34].xyz * f126)) * f74)))) + (CB0[27].xyz + (CB0[28].xyz * f74))) + vec3((f28.z * 2.0) * f58)) * f95) + (((((f107 * (((f108 + (f108 * f108)) / (((f109 * f109) * ((f103 * 3.0) + 0.5)) * ((f102 * 0.75) + 0.25))) * f100)) * CB0[10].xyz) * f58) * VARYING0.w) + f127)) + ((f73 * mix(f95, f127 * (1.0 / (max(max(f127.x, f127.y), f127.z) + 0.00999999977648258209228515625)), f116 * (f97 * (1.0 - f74)))) * 1.0);
    vec4 f129 = vec4(f128.x, f128.y, f128.z, vec4(0.0).w);
    f129.w = 1.0;
    float f130 = clamp(exp2((CB0[13].z * VARYING5.w) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f131 = textureLod(PrefilteredEnvTexture, vec4(-f57, 0.0).xyz, max(CB0[13].y, f130) * 5.0).xyz;
    bvec3 f132 = bvec3(CB0[13].w != 0.0);
    vec3 f133 = sqrt(clamp(mix(vec3(f132.x ? CB0[14].xyz.x : f131.x, f132.y ? CB0[14].xyz.y : f131.y, f132.z ? CB0[14].xyz.z : f131.z), f129.xyz, vec3(f130)).xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    _entryPointOutput = vec4(f133.x, f133.y, f133.z, f129.w);
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrecomputedBRDFTexture=s11
//$$SpecularMapTexture=s2
//$$AlbedoMapTexture=s0
//$$NormalMapTexture=s4
