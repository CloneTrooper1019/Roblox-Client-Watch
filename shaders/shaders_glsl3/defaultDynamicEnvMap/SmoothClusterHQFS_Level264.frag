#version 150

#extension GL_ARB_shading_language_include : require
#include <Globals.h>
#include <LightShadowGPUTransform.h>
uniform vec4 CB0[53];
uniform vec4 CB8[24];
uniform sampler2D ShadowAtlasTexture;
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform samplerCube PrefilteredEnvTexture;
uniform samplerCube PrefilteredEnvIndoorTexture;
uniform samplerCube PrefilteredEnvBlendTargetTexture;
uniform sampler2D PrecomputedBRDFTexture;
uniform sampler2DArray SpecularMapTexture;
uniform sampler2DArray AlbedoMapTexture;

in vec4 VARYING0;
in vec4 VARYING1;
in vec4 VARYING2;
in vec4 VARYING3;
in vec3 VARYING4;
in vec4 VARYING5;
in vec3 VARYING6;
in vec4 VARYING8;
out vec4 _entryPointOutput;

void main()
{
    vec3 f0 = vec3(VARYING1.xy, VARYING2.x);
    vec4 f1 = texture(SpecularMapTexture, f0);
    vec3 f2 = vec3(VARYING1.zw, VARYING2.z);
    vec4 f3 = texture(SpecularMapTexture, f2);
    vec4 f4 = texture(SpecularMapTexture, VARYING3.xyz);
    vec4 f5 = ((f1 * VARYING0.x) + (f3 * VARYING0.y)) + (f4 * VARYING0.z);
    vec4 f6 = texture(AlbedoMapTexture, f0);
    vec4 f7 = texture(AlbedoMapTexture, f2);
    vec4 f8 = texture(AlbedoMapTexture, VARYING3.xyz);
    vec4 f9 = ((f6.yxzw * VARYING0.x) + (f7.yxzw * VARYING0.y)) + (f8.yxzw * VARYING0.z);
    vec2 f10 = f9.yz - vec2(0.5);
    float f11 = VARYING8.x * f9.x;
    float f12 = f10.x;
    float f13 = f10.y;
    float f14 = (VARYING8.y * f12) - (VARYING8.z * f13);
    float f15 = (VARYING8.z * f12) + (VARYING8.y * f13);
    float f16 = f11 - f15;
    vec3 f17 = vec4(vec3(f16, f11, f16) + (vec3(f14, f15, f14) * vec3(1.0, 1.0, -1.0)), 0.0).xyz;
    vec3 f18 = CB0[7].xyz - VARYING5.xyz;
    float f19 = clamp(1.0 - (VARYING5.w * CB0[23].y), 0.0, 1.0);
    vec3 f20 = normalize(VARYING6);
    vec3 f21 = -CB0[11].xyz;
    float f22 = dot(f20, f21);
    vec3 f23 = VARYING5.xyz - (CB0[11].xyz * 0.001000000047497451305389404296875);
    float f24 = clamp(dot(step(CB0[19].xyz, abs(VARYING4 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f25 = VARYING4.yzx - (VARYING4.yzx * f24);
    vec4 f26 = texture(LightMapTexture, f25);
    vec4 f27 = texture(LightGridSkylightTexture, f25);
    vec4 f28 = vec4(clamp(f24, 0.0, 1.0));
    vec4 f29 = mix(f26, vec4(0.0), f28);
    vec4 f30 = mix(f27, vec4(1.0), f28);
    float f31 = f30.x;
    float f32 = f30.y;
    vec3 f33 = f23 - CB0[41].xyz;
    vec3 f34 = f23 - CB0[42].xyz;
    vec3 f35 = f23 - CB0[43].xyz;
    vec4 f36 = vec4(f23, 1.0) * mat4(CB8[((dot(f33, f33) < CB0[41].w) ? 0 : ((dot(f34, f34) < CB0[42].w) ? 1 : ((dot(f35, f35) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f33, f33) < CB0[41].w) ? 0 : ((dot(f34, f34) < CB0[42].w) ? 1 : ((dot(f35, f35) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f33, f33) < CB0[41].w) ? 0 : ((dot(f34, f34) < CB0[42].w) ? 1 : ((dot(f35, f35) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f33, f33) < CB0[41].w) ? 0 : ((dot(f34, f34) < CB0[42].w) ? 1 : ((dot(f35, f35) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f37 = textureLod(ShadowAtlasTexture, f36.xy, 0.0);
    vec2 f38 = vec2(0.0);
    f38.x = CB0[46].z;
    vec2 f39 = f38;
    f39.y = CB0[46].w;
    float f40 = (2.0 * f36.z) - 1.0;
    float f41 = exp(CB0[46].z * f40);
    float f42 = -exp((-CB0[46].w) * f40);
    vec2 f43 = (f39 * CB0[47].y) * vec2(f41, f42);
    vec2 f44 = f43 * f43;
    float f45 = f37.x;
    float f46 = max(f37.y - (f45 * f45), f44.x);
    float f47 = f41 - f45;
    float f48 = f37.z;
    float f49 = max(f37.w - (f48 * f48), f44.y);
    float f50 = f42 - f48;
    vec3 f51 = normalize(f18);
    float f52 = f5.y;
    float f53 = CB0[26].w * f19;
    vec3 f54 = reflect(-f51, f20);
    vec3 f55 = normalize(f21 + f51);
    float f56 = clamp(f22 * (((f22 * CB0[47].x) > 0.0) ? mix(min((f41 <= f45) ? 1.0 : clamp(((f46 / (f46 + (f47 * f47))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f42 <= f48) ? 1.0 : clamp(((f49 / (f49 + (f50 * f50))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f32, clamp((length(f23 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f32), 0.0, 1.0);
    float f57 = f52 * f52;
    float f58 = max(0.001000000047497451305389404296875, dot(f20, f55));
    float f59 = dot(f21, f55);
    float f60 = 1.0 - f59;
    float f61 = f60 * f60;
    float f62 = (f61 * f61) * f60;
    vec3 f63 = vec3(f62) + (vec3(0.039999999105930328369140625) * (1.0 - f62));
    float f64 = f57 * f57;
    float f65 = (((f58 * f64) - f58) * f58) + 1.0;
    float f66 = f52 * 5.0;
    vec3 f67 = vec4(f54, f66).xyz;
    vec3 f68 = textureLod(PrefilteredEnvIndoorTexture, f67, f66).xyz;
    vec3 f69;
    if (CB0[27].w == 0.0)
    {
        f69 = f68;
    }
    else
    {
        f69 = mix(f68, textureLod(PrefilteredEnvBlendTargetTexture, f67, f66).xyz, vec3(CB0[27].w));
    }
    vec4 f70 = texture(PrecomputedBRDFTexture, vec2(f52, max(9.9999997473787516355514526367188e-05, dot(f20, f51))));
    float f71 = f70.x;
    float f72 = f70.y;
    vec3 f73 = ((vec3(0.039999999105930328369140625) * f71) + vec3(f72)) / vec3(f71 + f72);
    vec3 f74 = f20 * f20;
    bvec3 f75 = lessThan(f20, vec3(0.0));
    vec3 f76 = vec3(f75.x ? f74.x : vec3(0.0).x, f75.y ? f74.y : vec3(0.0).y, f75.z ? f74.z : vec3(0.0).z);
    vec3 f77 = f74 - f76;
    float f78 = f77.x;
    float f79 = f77.y;
    float f80 = f77.z;
    float f81 = f76.x;
    float f82 = f76.y;
    float f83 = f76.z;
    vec3 f84 = ((((((((vec3(1.0) - (f63 * f53)) * CB0[10].xyz) * f56) + ((f29.xyz * (f29.w * 120.0)).xyz * 1.0)) + ((vec3(1.0) - (f73 * f53)) * (((((((CB0[35].xyz * f78) + (CB0[37].xyz * f79)) + (CB0[39].xyz * f80)) + (CB0[36].xyz * f81)) + (CB0[38].xyz * f82)) + (CB0[40].xyz * f83)) + (((((((CB0[29].xyz * f78) + (CB0[31].xyz * f79)) + (CB0[33].xyz * f80)) + (CB0[30].xyz * f81)) + (CB0[32].xyz * f82)) + (CB0[34].xyz * f83)) * f31)))) + (CB0[27].xyz + (CB0[28].xyz * f31))) + vec3((f5.z * 2.0) * f19)) * (f17 * f17).xyz) + (((((f63 * (((f64 + (f64 * f64)) / (((f65 * f65) * ((f59 * 3.0) + 0.5)) * ((f58 * 0.75) + 0.25))) * f56)) * CB0[10].xyz) * f19) * VARYING0.w) + ((mix(f69, textureLod(PrefilteredEnvTexture, f67, f66).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f54.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f31)) * f73) * f53));
    vec4 f85 = vec4(f84.x, f84.y, f84.z, vec4(0.0).w);
    f85.w = 1.0;
    float f86 = clamp(exp2((CB0[13].z * VARYING5.w) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f87 = textureLod(PrefilteredEnvTexture, vec4(-f18, 0.0).xyz, max(CB0[13].y, f86) * 5.0).xyz;
    bvec3 f88 = bvec3(CB0[13].w != 0.0);
    vec3 f89 = sqrt(clamp(mix(vec3(f88.x ? CB0[14].xyz.x : f87.x, f88.y ? CB0[14].xyz.y : f87.y, f88.z ? CB0[14].xyz.z : f87.z), f85.xyz, vec3(f86)).xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    _entryPointOutput = vec4(f89.x, f89.y, f89.z, f85.w);
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
