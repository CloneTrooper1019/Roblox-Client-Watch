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
    float f11 = f9.x;
    float f12 = f11 - f10.y;
    vec3 f13 = vec4(vec3(f12, f11, f12) + (vec3(f10.xyx) * vec3(1.0, 1.0, -1.0)), 0.0).xyz;
    vec3 f14 = CB0[7].xyz - VARYING5.xyz;
    float f15 = clamp(1.0 - (VARYING5.w * CB0[23].y), 0.0, 1.0);
    vec3 f16 = normalize(VARYING6);
    vec3 f17 = -CB0[11].xyz;
    float f18 = dot(f16, f17);
    vec3 f19 = VARYING5.xyz - (CB0[11].xyz * 0.001000000047497451305389404296875);
    float f20 = clamp(dot(step(CB0[19].xyz, abs(VARYING4 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f21 = VARYING4.yzx - (VARYING4.yzx * f20);
    vec4 f22 = texture(LightMapTexture, f21);
    vec4 f23 = texture(LightGridSkylightTexture, f21);
    vec4 f24 = vec4(clamp(f20, 0.0, 1.0));
    vec4 f25 = mix(f22, vec4(0.0), f24);
    vec4 f26 = mix(f23, vec4(1.0), f24);
    float f27 = f26.x;
    float f28 = f26.y;
    vec3 f29 = f19 - CB0[41].xyz;
    vec3 f30 = f19 - CB0[42].xyz;
    vec3 f31 = f19 - CB0[43].xyz;
    vec4 f32 = vec4(f19, 1.0) * mat4(CB8[((dot(f29, f29) < CB0[41].w) ? 0 : ((dot(f30, f30) < CB0[42].w) ? 1 : ((dot(f31, f31) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f29, f29) < CB0[41].w) ? 0 : ((dot(f30, f30) < CB0[42].w) ? 1 : ((dot(f31, f31) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f29, f29) < CB0[41].w) ? 0 : ((dot(f30, f30) < CB0[42].w) ? 1 : ((dot(f31, f31) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f29, f29) < CB0[41].w) ? 0 : ((dot(f30, f30) < CB0[42].w) ? 1 : ((dot(f31, f31) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
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
    vec3 f47 = normalize(f14);
    float f48 = f5.y;
    float f49 = CB0[26].w * f15;
    vec3 f50 = reflect(-f47, f16);
    vec3 f51 = normalize(f17 + f47);
    float f52 = clamp(f18 * (((f18 * CB0[47].x) > 0.0) ? mix(min((f37 <= f41) ? 1.0 : clamp(((f42 / (f42 + (f43 * f43))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f38 <= f44) ? 1.0 : clamp(((f45 / (f45 + (f46 * f46))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f28, clamp((length(f19 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f28), 0.0, 1.0);
    float f53 = f48 * f48;
    float f54 = max(0.001000000047497451305389404296875, dot(f16, f51));
    float f55 = dot(f17, f51);
    float f56 = 1.0 - f55;
    float f57 = f56 * f56;
    float f58 = (f57 * f57) * f56;
    vec3 f59 = vec3(f58) + (vec3(0.039999999105930328369140625) * (1.0 - f58));
    float f60 = f53 * f53;
    float f61 = (((f54 * f60) - f54) * f54) + 1.0;
    float f62 = f48 * 5.0;
    vec3 f63 = vec4(f50, f62).xyz;
    vec3 f64 = textureLod(PrefilteredEnvIndoorTexture, f63, f62).xyz;
    vec3 f65;
    if (CB0[27].w == 0.0)
    {
        f65 = f64;
    }
    else
    {
        f65 = mix(f64, textureLod(PrefilteredEnvBlendTargetTexture, f63, f62).xyz, vec3(CB0[27].w));
    }
    vec4 f66 = texture(PrecomputedBRDFTexture, vec2(f48, max(9.9999997473787516355514526367188e-05, dot(f16, f47))));
    float f67 = f66.x;
    float f68 = f66.y;
    vec3 f69 = ((vec3(0.039999999105930328369140625) * f67) + vec3(f68)) / vec3(f67 + f68);
    vec3 f70 = f16 * f16;
    bvec3 f71 = lessThan(f16, vec3(0.0));
    vec3 f72 = vec3(f71.x ? f70.x : vec3(0.0).x, f71.y ? f70.y : vec3(0.0).y, f71.z ? f70.z : vec3(0.0).z);
    vec3 f73 = f70 - f72;
    float f74 = f73.x;
    float f75 = f73.y;
    float f76 = f73.z;
    float f77 = f72.x;
    float f78 = f72.y;
    float f79 = f72.z;
    vec3 f80 = ((((((((vec3(1.0) - (f59 * f49)) * CB0[10].xyz) * f52) + ((f25.xyz * (f25.w * 120.0)).xyz * 1.0)) + ((vec3(1.0) - (f69 * f49)) * (((((((CB0[35].xyz * f74) + (CB0[37].xyz * f75)) + (CB0[39].xyz * f76)) + (CB0[36].xyz * f77)) + (CB0[38].xyz * f78)) + (CB0[40].xyz * f79)) + (((((((CB0[29].xyz * f74) + (CB0[31].xyz * f75)) + (CB0[33].xyz * f76)) + (CB0[30].xyz * f77)) + (CB0[32].xyz * f78)) + (CB0[34].xyz * f79)) * f27)))) + (CB0[27].xyz + (CB0[28].xyz * f27))) + vec3((f5.z * 2.0) * f15)) * (f13 * f13).xyz) + (((((f59 * (((f60 + (f60 * f60)) / (((f61 * f61) * ((f55 * 3.0) + 0.5)) * ((f54 * 0.75) + 0.25))) * f52)) * CB0[10].xyz) * f15) * VARYING0.w) + ((mix(f65, textureLod(PrefilteredEnvTexture, f63, f62).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f50.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f27)) * f69) * f49));
    vec4 f81 = vec4(f80.x, f80.y, f80.z, vec4(0.0).w);
    f81.w = 1.0;
    float f82 = clamp(exp2((CB0[13].z * VARYING5.w) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f83 = textureLod(PrefilteredEnvTexture, vec4(-f14, 0.0).xyz, max(CB0[13].y, f82) * 5.0).xyz;
    bvec3 f84 = bvec3(CB0[13].w != 0.0);
    vec3 f85 = sqrt(clamp(mix(vec3(f84.x ? CB0[14].xyz.x : f83.x, f84.y ? CB0[14].xyz.y : f83.y, f84.z ? CB0[14].xyz.z : f83.z), f81.xyz, vec3(f82)).xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    _entryPointOutput = vec4(f85.x, f85.y, f85.z, f81.w);
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
