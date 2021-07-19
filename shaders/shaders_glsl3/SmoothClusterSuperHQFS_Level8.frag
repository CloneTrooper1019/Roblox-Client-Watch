#version 150

#extension GL_ARB_shading_language_include : require
#include <Globals.h>
#include <LightShadowGPUTransform.h>
uniform vec4 CB0[53];
uniform vec4 CB8[24];
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
    vec4 f29 = ((texture(AlbedoMapTexture, f0).yxzw * f5.x) + (texture(AlbedoMapTexture, f2).yxzw * f5.y)) + (texture(AlbedoMapTexture, VARYING3.xyz).yxzw * f5.z);
    vec2 f30 = f29.yz - vec2(0.5);
    float f31 = f29.x;
    float f32 = f31 - f30.y;
    vec3 f33 = vec4(vec3(f32, f31, f32) + (vec3(f30.xyx) * vec3(1.0, 1.0, -1.0)), 0.0).xyz;
    vec3 f34 = CB0[7].xyz - VARYING5.xyz;
    float f35 = clamp(1.0 - (VARYING5.w * CB0[23].y), 0.0, 1.0);
    float f36 = -VARYING6.x;
    vec2 f37 = (((texture(NormalMapTexture, f0) * f5.x) + (texture(NormalMapTexture, f2) * f5.y)) + (texture(NormalMapTexture, VARYING3.xyz) * f5.z)).wy * 2.0;
    vec2 f38 = f37 - vec2(1.0);
    vec3 f39 = normalize(((vec3(f38, sqrt(clamp(1.0 + dot(vec2(1.0) - f37, f38), 0.0, 1.0))) - vec3(0.0, 0.0, 1.0)) * inversesqrt(dot(f5, f5))) + vec3(0.0, 0.0, 1.0));
    vec3 f40 = vec3(dot(VARYING7, f5));
    vec3 f41 = vec4(normalize(((mix(vec3(VARYING6.z, 0.0, f36), vec3(VARYING6.y, f36, 0.0), f40) * f39.x) + (mix(vec3(0.0, 1.0, 0.0), vec3(0.0, VARYING6.z, -VARYING6.y), f40) * f39.y)) + (VARYING6 * f39.z)), 0.0).xyz;
    vec3 f42 = -CB0[11].xyz;
    float f43 = dot(f41, f42);
    vec3 f44 = VARYING5.xyz - (CB0[11].xyz * 0.001000000047497451305389404296875);
    float f45 = clamp(dot(step(CB0[19].xyz, abs(VARYING4 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f46 = VARYING4.yzx - (VARYING4.yzx * f45);
    vec4 f47 = vec4(clamp(f45, 0.0, 1.0));
    vec4 f48 = mix(texture(LightMapTexture, f46), vec4(0.0), f47);
    vec4 f49 = mix(texture(LightGridSkylightTexture, f46), vec4(1.0), f47);
    vec3 f50 = (f48.xyz * (f48.w * 120.0)).xyz;
    float f51 = f49.x;
    float f52 = f49.y;
    vec3 f53 = f44 - CB0[41].xyz;
    vec3 f54 = f44 - CB0[42].xyz;
    vec3 f55 = f44 - CB0[43].xyz;
    vec4 f56 = vec4(f44, 1.0) * mat4(CB8[((dot(f53, f53) < CB0[41].w) ? 0 : ((dot(f54, f54) < CB0[42].w) ? 1 : ((dot(f55, f55) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f53, f53) < CB0[41].w) ? 0 : ((dot(f54, f54) < CB0[42].w) ? 1 : ((dot(f55, f55) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f53, f53) < CB0[41].w) ? 0 : ((dot(f54, f54) < CB0[42].w) ? 1 : ((dot(f55, f55) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f53, f53) < CB0[41].w) ? 0 : ((dot(f54, f54) < CB0[42].w) ? 1 : ((dot(f55, f55) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f57 = textureLod(ShadowAtlasTexture, f56.xy, 0.0);
    vec2 f58 = vec2(0.0);
    f58.x = CB0[46].z;
    vec2 f59 = f58;
    f59.y = CB0[46].w;
    float f60 = (2.0 * f56.z) - 1.0;
    float f61 = exp(CB0[46].z * f60);
    float f62 = -exp((-CB0[46].w) * f60);
    vec2 f63 = (f59 * CB0[47].y) * vec2(f61, f62);
    vec2 f64 = f63 * f63;
    float f65 = f57.x;
    float f66 = max(f57.y - (f65 * f65), f64.x);
    float f67 = f61 - f65;
    float f68 = f57.z;
    float f69 = max(f57.w - (f68 * f68), f64.y);
    float f70 = f62 - f68;
    vec3 f71 = normalize(f34);
    vec3 f72 = (f33 * f33).xyz;
    float f73 = f28.y;
    float f74 = CB0[26].w * f35;
    vec3 f75 = reflect(-f71, f41);
    vec3 f76 = normalize(f42 + f71);
    float f77 = clamp(f43 * (((f43 * CB0[47].x) > 0.0) ? mix(min((f61 <= f65) ? 1.0 : clamp(((f66 / (f66 + (f67 * f67))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f62 <= f68) ? 1.0 : clamp(((f69 / (f69 + (f70 * f70))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f52, clamp((length(f44 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f52), 0.0, 1.0);
    float f78 = f73 * f73;
    float f79 = max(0.001000000047497451305389404296875, dot(f41, f76));
    float f80 = dot(f42, f76);
    float f81 = 1.0 - f80;
    float f82 = f81 * f81;
    float f83 = (f82 * f82) * f81;
    vec3 f84 = vec3(f83) + (vec3(0.039999999105930328369140625) * (1.0 - f83));
    float f85 = f78 * f78;
    float f86 = (((f79 * f85) - f79) * f79) + 1.0;
    float f87 = f73 * 5.0;
    vec3 f88 = vec4(f75, f87).xyz;
    vec4 f89 = texture(PrecomputedBRDFTexture, vec2(f73, max(9.9999997473787516355514526367188e-05, dot(f41, f71))));
    float f90 = f89.x;
    float f91 = f89.y;
    vec3 f92 = ((vec3(0.039999999105930328369140625) * f90) + vec3(f91)) / vec3(f90 + f91);
    vec3 f93 = f92 * f74;
    vec3 f94 = f41 * f41;
    bvec3 f95 = lessThan(f41, vec3(0.0));
    vec3 f96 = vec3(f95.x ? f94.x : vec3(0.0).x, f95.y ? f94.y : vec3(0.0).y, f95.z ? f94.z : vec3(0.0).z);
    vec3 f97 = f94 - f96;
    float f98 = f97.x;
    float f99 = f97.y;
    float f100 = f97.z;
    float f101 = f96.x;
    float f102 = f96.y;
    float f103 = f96.z;
    vec3 f104 = (mix(textureLod(PrefilteredEnvIndoorTexture, f88, f87).xyz * f50, textureLod(PrefilteredEnvTexture, f88, f87).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f75.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f51)) * f92) * f74;
    vec3 f105 = ((((((((vec3(1.0) - (f84 * f74)) * CB0[10].xyz) * f77) + ((vec3(1.0) - f93) * (((((((CB0[35].xyz * f98) + (CB0[37].xyz * f99)) + (CB0[39].xyz * f100)) + (CB0[36].xyz * f101)) + (CB0[38].xyz * f102)) + (CB0[40].xyz * f103)) + (((((((CB0[29].xyz * f98) + (CB0[31].xyz * f99)) + (CB0[33].xyz * f100)) + (CB0[30].xyz * f101)) + (CB0[32].xyz * f102)) + (CB0[34].xyz * f103)) * f51)))) + (CB0[27].xyz + (CB0[28].xyz * f51))) + vec3((f28.z * 2.0) * f35)) * f72) + (((((f84 * (((f85 + (f85 * f85)) / (((f86 * f86) * ((f80 * 3.0) + 0.5)) * ((f79 * 0.75) + 0.25))) * f77)) * CB0[10].xyz) * f35) * VARYING0.w) + f104)) + ((f50 * mix(f72, f104 * (1.0 / (max(max(f104.x, f104.y), f104.z) + 0.00999999977648258209228515625)), f93 * (f74 * (1.0 - f51)))) * 1.0);
    vec4 f106 = vec4(f105.x, f105.y, f105.z, vec4(0.0).w);
    f106.w = 1.0;
    float f107 = clamp(exp2((CB0[13].z * VARYING5.w) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f108 = textureLod(PrefilteredEnvTexture, vec4(-f34, 0.0).xyz, max(CB0[13].y, f107) * 5.0).xyz;
    bvec3 f109 = bvec3(CB0[13].w != 0.0);
    vec3 f110 = sqrt(clamp(mix(vec3(f109.x ? CB0[14].xyz.x : f108.x, f109.y ? CB0[14].xyz.y : f108.y, f109.z ? CB0[14].xyz.z : f108.z), f106.xyz, vec3(f107)).xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    _entryPointOutput = vec4(f110.x, f110.y, f110.z, f106.w);
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
