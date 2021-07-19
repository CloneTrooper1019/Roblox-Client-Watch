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
    vec4 f32 = ((f29.yxzw * f5.x) + (f30.yxzw * f5.y)) + (f31.yxzw * f5.z);
    vec2 f33 = f32.yz - vec2(0.5);
    float f34 = f32.x;
    float f35 = f34 - f33.y;
    vec3 f36 = vec4(vec3(f35, f34, f35) + (vec3(f33.xyx) * vec3(1.0, 1.0, -1.0)), 0.0).xyz;
    vec3 f37 = CB0[7].xyz - VARYING5.xyz;
    float f38 = clamp(1.0 - (VARYING5.w * CB0[23].y), 0.0, 1.0);
    vec4 f39 = texture(NormalMapTexture, f0);
    vec4 f40 = texture(NormalMapTexture, f2);
    vec4 f41 = texture(NormalMapTexture, VARYING3.xyz);
    float f42 = -VARYING6.x;
    vec2 f43 = (((f39 * f5.x) + (f40 * f5.y)) + (f41 * f5.z)).wy * 2.0;
    vec2 f44 = f43 - vec2(1.0);
    vec3 f45 = normalize(((vec3(f44, sqrt(clamp(1.0 + dot(vec2(1.0) - f43, f44), 0.0, 1.0))) - vec3(0.0, 0.0, 1.0)) * inversesqrt(dot(f5, f5))) + vec3(0.0, 0.0, 1.0));
    vec3 f46 = vec3(dot(VARYING7, f5));
    vec3 f47 = vec4(normalize(((mix(vec3(VARYING6.z, 0.0, f42), vec3(VARYING6.y, f42, 0.0), f46) * f45.x) + (mix(vec3(0.0, 1.0, 0.0), vec3(0.0, VARYING6.z, -VARYING6.y), f46) * f45.y)) + (VARYING6 * f45.z)), 0.0).xyz;
    vec3 f48 = -CB0[11].xyz;
    float f49 = dot(f47, f48);
    vec3 f50 = VARYING5.xyz - (CB0[11].xyz * 0.001000000047497451305389404296875);
    float f51 = clamp(dot(step(CB0[19].xyz, abs(VARYING4 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f52 = VARYING4.yzx - (VARYING4.yzx * f51);
    vec4 f53 = texture(LightMapTexture, f52);
    vec4 f54 = texture(LightGridSkylightTexture, f52);
    vec4 f55 = vec4(clamp(f51, 0.0, 1.0));
    vec4 f56 = mix(f53, vec4(0.0), f55);
    vec4 f57 = mix(f54, vec4(1.0), f55);
    float f58 = f57.x;
    float f59 = f57.y;
    vec3 f60 = f50 - CB0[41].xyz;
    vec3 f61 = f50 - CB0[42].xyz;
    vec3 f62 = f50 - CB0[43].xyz;
    vec4 f63 = vec4(f50, 1.0) * mat4(CB8[((dot(f60, f60) < CB0[41].w) ? 0 : ((dot(f61, f61) < CB0[42].w) ? 1 : ((dot(f62, f62) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f60, f60) < CB0[41].w) ? 0 : ((dot(f61, f61) < CB0[42].w) ? 1 : ((dot(f62, f62) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f60, f60) < CB0[41].w) ? 0 : ((dot(f61, f61) < CB0[42].w) ? 1 : ((dot(f62, f62) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f60, f60) < CB0[41].w) ? 0 : ((dot(f61, f61) < CB0[42].w) ? 1 : ((dot(f62, f62) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f64 = textureLod(ShadowAtlasTexture, f63.xy, 0.0);
    vec2 f65 = vec2(0.0);
    f65.x = CB0[46].z;
    vec2 f66 = f65;
    f66.y = CB0[46].w;
    float f67 = (2.0 * f63.z) - 1.0;
    float f68 = exp(CB0[46].z * f67);
    float f69 = -exp((-CB0[46].w) * f67);
    vec2 f70 = (f66 * CB0[47].y) * vec2(f68, f69);
    vec2 f71 = f70 * f70;
    float f72 = f64.x;
    float f73 = max(f64.y - (f72 * f72), f71.x);
    float f74 = f68 - f72;
    float f75 = f64.z;
    float f76 = max(f64.w - (f75 * f75), f71.y);
    float f77 = f69 - f75;
    vec3 f78 = normalize(f37);
    float f79 = f28.y;
    float f80 = CB0[26].w * f38;
    vec3 f81 = reflect(-f78, f47);
    vec3 f82 = normalize(f48 + f78);
    float f83 = clamp(f49 * (((f49 * CB0[47].x) > 0.0) ? mix(min((f68 <= f72) ? 1.0 : clamp(((f73 / (f73 + (f74 * f74))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f69 <= f75) ? 1.0 : clamp(((f76 / (f76 + (f77 * f77))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f59, clamp((length(f50 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f59), 0.0, 1.0);
    float f84 = f79 * f79;
    float f85 = max(0.001000000047497451305389404296875, dot(f47, f82));
    float f86 = dot(f48, f82);
    float f87 = 1.0 - f86;
    float f88 = f87 * f87;
    float f89 = (f88 * f88) * f87;
    vec3 f90 = vec3(f89) + (vec3(0.039999999105930328369140625) * (1.0 - f89));
    float f91 = f84 * f84;
    float f92 = (((f85 * f91) - f85) * f85) + 1.0;
    float f93 = f79 * 5.0;
    vec3 f94 = vec4(f81, f93).xyz;
    vec3 f95 = textureLod(PrefilteredEnvIndoorTexture, f94, f93).xyz;
    vec3 f96;
    if (CB0[27].w == 0.0)
    {
        f96 = f95;
    }
    else
    {
        f96 = mix(f95, textureLod(PrefilteredEnvBlendTargetTexture, f94, f93).xyz, vec3(CB0[27].w));
    }
    vec4 f97 = texture(PrecomputedBRDFTexture, vec2(f79, max(9.9999997473787516355514526367188e-05, dot(f47, f78))));
    float f98 = f97.x;
    float f99 = f97.y;
    vec3 f100 = ((vec3(0.039999999105930328369140625) * f98) + vec3(f99)) / vec3(f98 + f99);
    vec3 f101 = f47 * f47;
    bvec3 f102 = lessThan(f47, vec3(0.0));
    vec3 f103 = vec3(f102.x ? f101.x : vec3(0.0).x, f102.y ? f101.y : vec3(0.0).y, f102.z ? f101.z : vec3(0.0).z);
    vec3 f104 = f101 - f103;
    float f105 = f104.x;
    float f106 = f104.y;
    float f107 = f104.z;
    float f108 = f103.x;
    float f109 = f103.y;
    float f110 = f103.z;
    vec3 f111 = ((((((((vec3(1.0) - (f90 * f80)) * CB0[10].xyz) * f83) + ((f56.xyz * (f56.w * 120.0)).xyz * 1.0)) + ((vec3(1.0) - (f100 * f80)) * (((((((CB0[35].xyz * f105) + (CB0[37].xyz * f106)) + (CB0[39].xyz * f107)) + (CB0[36].xyz * f108)) + (CB0[38].xyz * f109)) + (CB0[40].xyz * f110)) + (((((((CB0[29].xyz * f105) + (CB0[31].xyz * f106)) + (CB0[33].xyz * f107)) + (CB0[30].xyz * f108)) + (CB0[32].xyz * f109)) + (CB0[34].xyz * f110)) * f58)))) + (CB0[27].xyz + (CB0[28].xyz * f58))) + vec3((f28.z * 2.0) * f38)) * (f36 * f36).xyz) + (((((f90 * (((f91 + (f91 * f91)) / (((f92 * f92) * ((f86 * 3.0) + 0.5)) * ((f85 * 0.75) + 0.25))) * f83)) * CB0[10].xyz) * f38) * VARYING0.w) + ((mix(f96, textureLod(PrefilteredEnvTexture, f94, f93).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f81.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f58)) * f100) * f80));
    vec4 f112 = vec4(f111.x, f111.y, f111.z, vec4(0.0).w);
    f112.w = 1.0;
    float f113 = clamp(exp2((CB0[13].z * VARYING5.w) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f114 = textureLod(PrefilteredEnvTexture, vec4(-f37, 0.0).xyz, max(CB0[13].y, f113) * 5.0).xyz;
    bvec3 f115 = bvec3(CB0[13].w != 0.0);
    vec3 f116 = sqrt(clamp(mix(vec3(f115.x ? CB0[14].xyz.x : f114.x, f115.y ? CB0[14].xyz.y : f114.y, f115.z ? CB0[14].xyz.z : f114.z), f112.xyz, vec3(f113)).xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    _entryPointOutput = vec4(f116.x, f116.y, f116.z, f112.w);
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
