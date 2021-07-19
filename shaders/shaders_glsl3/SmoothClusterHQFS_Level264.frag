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
    vec3 f1 = vec3(VARYING1.zw, VARYING2.z);
    vec4 f2 = ((texture(SpecularMapTexture, f0) * VARYING0.x) + (texture(SpecularMapTexture, f1) * VARYING0.y)) + (texture(SpecularMapTexture, VARYING3.xyz) * VARYING0.z);
    vec4 f3 = ((texture(AlbedoMapTexture, f0).yxzw * VARYING0.x) + (texture(AlbedoMapTexture, f1).yxzw * VARYING0.y)) + (texture(AlbedoMapTexture, VARYING3.xyz).yxzw * VARYING0.z);
    vec2 f4 = f3.yz - vec2(0.5);
    float f5 = VARYING8.x * f3.x;
    float f6 = f4.x;
    float f7 = f4.y;
    float f8 = (VARYING8.y * f6) - (VARYING8.z * f7);
    float f9 = (VARYING8.z * f6) + (VARYING8.y * f7);
    float f10 = f5 - f9;
    vec3 f11 = vec4(vec3(f10, f5, f10) + (vec3(f8, f9, f8) * vec3(1.0, 1.0, -1.0)), 0.0).xyz;
    vec3 f12 = CB0[7].xyz - VARYING5.xyz;
    float f13 = clamp(1.0 - (VARYING5.w * CB0[23].y), 0.0, 1.0);
    vec3 f14 = normalize(VARYING6);
    vec3 f15 = -CB0[11].xyz;
    float f16 = dot(f14, f15);
    vec3 f17 = VARYING5.xyz - (CB0[11].xyz * 0.001000000047497451305389404296875);
    float f18 = clamp(dot(step(CB0[19].xyz, abs(VARYING4 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f19 = VARYING4.yzx - (VARYING4.yzx * f18);
    vec4 f20 = vec4(clamp(f18, 0.0, 1.0));
    vec4 f21 = mix(texture(LightMapTexture, f19), vec4(0.0), f20);
    vec4 f22 = mix(texture(LightGridSkylightTexture, f19), vec4(1.0), f20);
    vec3 f23 = (f21.xyz * (f21.w * 120.0)).xyz;
    float f24 = f22.x;
    float f25 = f22.y;
    vec3 f26 = f17 - CB0[41].xyz;
    vec3 f27 = f17 - CB0[42].xyz;
    vec3 f28 = f17 - CB0[43].xyz;
    vec4 f29 = vec4(f17, 1.0) * mat4(CB8[((dot(f26, f26) < CB0[41].w) ? 0 : ((dot(f27, f27) < CB0[42].w) ? 1 : ((dot(f28, f28) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f26, f26) < CB0[41].w) ? 0 : ((dot(f27, f27) < CB0[42].w) ? 1 : ((dot(f28, f28) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f26, f26) < CB0[41].w) ? 0 : ((dot(f27, f27) < CB0[42].w) ? 1 : ((dot(f28, f28) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f26, f26) < CB0[41].w) ? 0 : ((dot(f27, f27) < CB0[42].w) ? 1 : ((dot(f28, f28) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f30 = textureLod(ShadowAtlasTexture, f29.xy, 0.0);
    vec2 f31 = vec2(0.0);
    f31.x = CB0[46].z;
    vec2 f32 = f31;
    f32.y = CB0[46].w;
    float f33 = (2.0 * f29.z) - 1.0;
    float f34 = exp(CB0[46].z * f33);
    float f35 = -exp((-CB0[46].w) * f33);
    vec2 f36 = (f32 * CB0[47].y) * vec2(f34, f35);
    vec2 f37 = f36 * f36;
    float f38 = f30.x;
    float f39 = max(f30.y - (f38 * f38), f37.x);
    float f40 = f34 - f38;
    float f41 = f30.z;
    float f42 = max(f30.w - (f41 * f41), f37.y);
    float f43 = f35 - f41;
    vec3 f44 = normalize(f12);
    vec3 f45 = (f11 * f11).xyz;
    float f46 = f2.y;
    float f47 = CB0[26].w * f13;
    vec3 f48 = reflect(-f44, f14);
    vec3 f49 = normalize(f15 + f44);
    float f50 = clamp(f16 * (((f16 * CB0[47].x) > 0.0) ? mix(min((f34 <= f38) ? 1.0 : clamp(((f39 / (f39 + (f40 * f40))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f35 <= f41) ? 1.0 : clamp(((f42 / (f42 + (f43 * f43))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f25, clamp((length(f17 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f25), 0.0, 1.0);
    float f51 = f46 * f46;
    float f52 = max(0.001000000047497451305389404296875, dot(f14, f49));
    float f53 = dot(f15, f49);
    float f54 = 1.0 - f53;
    float f55 = f54 * f54;
    float f56 = (f55 * f55) * f54;
    vec3 f57 = vec3(f56) + (vec3(0.039999999105930328369140625) * (1.0 - f56));
    float f58 = f51 * f51;
    float f59 = (((f52 * f58) - f52) * f52) + 1.0;
    float f60 = f46 * 5.0;
    vec3 f61 = vec4(f48, f60).xyz;
    vec4 f62 = texture(PrecomputedBRDFTexture, vec2(f46, max(9.9999997473787516355514526367188e-05, dot(f14, f44))));
    float f63 = f62.x;
    float f64 = f62.y;
    vec3 f65 = ((vec3(0.039999999105930328369140625) * f63) + vec3(f64)) / vec3(f63 + f64);
    vec3 f66 = f65 * f47;
    vec3 f67 = f14 * f14;
    bvec3 f68 = lessThan(f14, vec3(0.0));
    vec3 f69 = vec3(f68.x ? f67.x : vec3(0.0).x, f68.y ? f67.y : vec3(0.0).y, f68.z ? f67.z : vec3(0.0).z);
    vec3 f70 = f67 - f69;
    float f71 = f70.x;
    float f72 = f70.y;
    float f73 = f70.z;
    float f74 = f69.x;
    float f75 = f69.y;
    float f76 = f69.z;
    vec3 f77 = (mix(textureLod(PrefilteredEnvIndoorTexture, f61, f60).xyz * f23, textureLod(PrefilteredEnvTexture, f61, f60).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f48.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f24)) * f65) * f47;
    vec3 f78 = ((((((((vec3(1.0) - (f57 * f47)) * CB0[10].xyz) * f50) + ((vec3(1.0) - f66) * (((((((CB0[35].xyz * f71) + (CB0[37].xyz * f72)) + (CB0[39].xyz * f73)) + (CB0[36].xyz * f74)) + (CB0[38].xyz * f75)) + (CB0[40].xyz * f76)) + (((((((CB0[29].xyz * f71) + (CB0[31].xyz * f72)) + (CB0[33].xyz * f73)) + (CB0[30].xyz * f74)) + (CB0[32].xyz * f75)) + (CB0[34].xyz * f76)) * f24)))) + (CB0[27].xyz + (CB0[28].xyz * f24))) + vec3((f2.z * 2.0) * f13)) * f45) + (((((f57 * (((f58 + (f58 * f58)) / (((f59 * f59) * ((f53 * 3.0) + 0.5)) * ((f52 * 0.75) + 0.25))) * f50)) * CB0[10].xyz) * f13) * VARYING0.w) + f77)) + ((f23 * mix(f45, f77 * (1.0 / (max(max(f77.x, f77.y), f77.z) + 0.00999999977648258209228515625)), f66 * (f47 * (1.0 - f24)))) * 1.0);
    vec4 f79 = vec4(f78.x, f78.y, f78.z, vec4(0.0).w);
    f79.w = 1.0;
    float f80 = clamp(exp2((CB0[13].z * VARYING5.w) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f81 = textureLod(PrefilteredEnvTexture, vec4(-f12, 0.0).xyz, max(CB0[13].y, f80) * 5.0).xyz;
    bvec3 f82 = bvec3(CB0[13].w != 0.0);
    vec3 f83 = sqrt(clamp(mix(vec3(f82.x ? CB0[14].xyz.x : f81.x, f82.y ? CB0[14].xyz.y : f81.y, f82.z ? CB0[14].xyz.z : f81.z), f79.xyz, vec3(f80)).xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    _entryPointOutput = vec4(f83.x, f83.y, f83.z, f79.w);
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrecomputedBRDFTexture=s11
//$$SpecularMapTexture=s2
//$$AlbedoMapTexture=s0
