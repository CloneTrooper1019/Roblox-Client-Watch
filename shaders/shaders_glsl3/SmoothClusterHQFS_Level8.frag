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
out vec4 _entryPointOutput;

void main()
{
    vec3 f0 = vec3(VARYING1.xy, VARYING2.x);
    vec3 f1 = vec3(VARYING1.zw, VARYING2.z);
    vec4 f2 = ((texture(SpecularMapTexture, f0) * VARYING0.x) + (texture(SpecularMapTexture, f1) * VARYING0.y)) + (texture(SpecularMapTexture, VARYING3.xyz) * VARYING0.z);
    vec4 f3 = ((texture(AlbedoMapTexture, f0).yxzw * VARYING0.x) + (texture(AlbedoMapTexture, f1).yxzw * VARYING0.y)) + (texture(AlbedoMapTexture, VARYING3.xyz).yxzw * VARYING0.z);
    vec2 f4 = f3.yz - vec2(0.5);
    float f5 = f3.x;
    float f6 = f5 - f4.y;
    vec3 f7 = vec4(vec3(f6, f5, f6) + (vec3(f4.xyx) * vec3(1.0, 1.0, -1.0)), 0.0).xyz;
    vec3 f8 = CB0[7].xyz - VARYING5.xyz;
    float f9 = clamp(1.0 - (VARYING5.w * CB0[23].y), 0.0, 1.0);
    vec3 f10 = normalize(VARYING6);
    vec3 f11 = -CB0[11].xyz;
    float f12 = dot(f10, f11);
    vec3 f13 = VARYING5.xyz - (CB0[11].xyz * 0.001000000047497451305389404296875);
    float f14 = clamp(dot(step(CB0[19].xyz, abs(VARYING4 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f15 = VARYING4.yzx - (VARYING4.yzx * f14);
    vec4 f16 = vec4(clamp(f14, 0.0, 1.0));
    vec4 f17 = mix(texture(LightMapTexture, f15), vec4(0.0), f16);
    vec4 f18 = mix(texture(LightGridSkylightTexture, f15), vec4(1.0), f16);
    vec3 f19 = (f17.xyz * (f17.w * 120.0)).xyz;
    float f20 = f18.x;
    float f21 = f18.y;
    vec3 f22 = f13 - CB0[41].xyz;
    vec3 f23 = f13 - CB0[42].xyz;
    vec3 f24 = f13 - CB0[43].xyz;
    vec4 f25 = vec4(f13, 1.0) * mat4(CB8[((dot(f22, f22) < CB0[41].w) ? 0 : ((dot(f23, f23) < CB0[42].w) ? 1 : ((dot(f24, f24) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f22, f22) < CB0[41].w) ? 0 : ((dot(f23, f23) < CB0[42].w) ? 1 : ((dot(f24, f24) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f22, f22) < CB0[41].w) ? 0 : ((dot(f23, f23) < CB0[42].w) ? 1 : ((dot(f24, f24) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f22, f22) < CB0[41].w) ? 0 : ((dot(f23, f23) < CB0[42].w) ? 1 : ((dot(f24, f24) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f26 = textureLod(ShadowAtlasTexture, f25.xy, 0.0);
    vec2 f27 = vec2(0.0);
    f27.x = CB0[46].z;
    vec2 f28 = f27;
    f28.y = CB0[46].w;
    float f29 = (2.0 * f25.z) - 1.0;
    float f30 = exp(CB0[46].z * f29);
    float f31 = -exp((-CB0[46].w) * f29);
    vec2 f32 = (f28 * CB0[47].y) * vec2(f30, f31);
    vec2 f33 = f32 * f32;
    float f34 = f26.x;
    float f35 = max(f26.y - (f34 * f34), f33.x);
    float f36 = f30 - f34;
    float f37 = f26.z;
    float f38 = max(f26.w - (f37 * f37), f33.y);
    float f39 = f31 - f37;
    vec3 f40 = normalize(f8);
    vec3 f41 = (f7 * f7).xyz;
    float f42 = f2.y;
    float f43 = CB0[26].w * f9;
    vec3 f44 = reflect(-f40, f10);
    vec3 f45 = normalize(f11 + f40);
    float f46 = clamp(f12 * (((f12 * CB0[47].x) > 0.0) ? mix(min((f30 <= f34) ? 1.0 : clamp(((f35 / (f35 + (f36 * f36))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f31 <= f37) ? 1.0 : clamp(((f38 / (f38 + (f39 * f39))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f21, clamp((length(f13 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f21), 0.0, 1.0);
    float f47 = f42 * f42;
    float f48 = max(0.001000000047497451305389404296875, dot(f10, f45));
    float f49 = dot(f11, f45);
    float f50 = 1.0 - f49;
    float f51 = f50 * f50;
    float f52 = (f51 * f51) * f50;
    vec3 f53 = vec3(f52) + (vec3(0.039999999105930328369140625) * (1.0 - f52));
    float f54 = f47 * f47;
    float f55 = (((f48 * f54) - f48) * f48) + 1.0;
    float f56 = f42 * 5.0;
    vec3 f57 = vec4(f44, f56).xyz;
    vec4 f58 = texture(PrecomputedBRDFTexture, vec2(f42, max(9.9999997473787516355514526367188e-05, dot(f10, f40))));
    float f59 = f58.x;
    float f60 = f58.y;
    vec3 f61 = ((vec3(0.039999999105930328369140625) * f59) + vec3(f60)) / vec3(f59 + f60);
    vec3 f62 = f61 * f43;
    vec3 f63 = f10 * f10;
    bvec3 f64 = lessThan(f10, vec3(0.0));
    vec3 f65 = vec3(f64.x ? f63.x : vec3(0.0).x, f64.y ? f63.y : vec3(0.0).y, f64.z ? f63.z : vec3(0.0).z);
    vec3 f66 = f63 - f65;
    float f67 = f66.x;
    float f68 = f66.y;
    float f69 = f66.z;
    float f70 = f65.x;
    float f71 = f65.y;
    float f72 = f65.z;
    vec3 f73 = (mix(textureLod(PrefilteredEnvIndoorTexture, f57, f56).xyz * f19, textureLod(PrefilteredEnvTexture, f57, f56).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f44.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f20)) * f61) * f43;
    vec3 f74 = ((((((((vec3(1.0) - (f53 * f43)) * CB0[10].xyz) * f46) + ((vec3(1.0) - f62) * (((((((CB0[35].xyz * f67) + (CB0[37].xyz * f68)) + (CB0[39].xyz * f69)) + (CB0[36].xyz * f70)) + (CB0[38].xyz * f71)) + (CB0[40].xyz * f72)) + (((((((CB0[29].xyz * f67) + (CB0[31].xyz * f68)) + (CB0[33].xyz * f69)) + (CB0[30].xyz * f70)) + (CB0[32].xyz * f71)) + (CB0[34].xyz * f72)) * f20)))) + (CB0[27].xyz + (CB0[28].xyz * f20))) + vec3((f2.z * 2.0) * f9)) * f41) + (((((f53 * (((f54 + (f54 * f54)) / (((f55 * f55) * ((f49 * 3.0) + 0.5)) * ((f48 * 0.75) + 0.25))) * f46)) * CB0[10].xyz) * f9) * VARYING0.w) + f73)) + ((f19 * mix(f41, f73 * (1.0 / (max(max(f73.x, f73.y), f73.z) + 0.00999999977648258209228515625)), f62 * (f43 * (1.0 - f20)))) * 1.0);
    vec4 f75 = vec4(f74.x, f74.y, f74.z, vec4(0.0).w);
    f75.w = 1.0;
    float f76 = clamp(exp2((CB0[13].z * VARYING5.w) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f77 = textureLod(PrefilteredEnvTexture, vec4(-f8, 0.0).xyz, max(CB0[13].y, f76) * 5.0).xyz;
    bvec3 f78 = bvec3(CB0[13].w != 0.0);
    vec3 f79 = sqrt(clamp(mix(vec3(f78.x ? CB0[14].xyz.x : f77.x, f78.y ? CB0[14].xyz.y : f77.y, f78.z ? CB0[14].xyz.z : f77.z), f75.xyz, vec3(f76)).xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    _entryPointOutput = vec4(f79.x, f79.y, f79.z, f75.w);
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrecomputedBRDFTexture=s11
//$$SpecularMapTexture=s2
//$$AlbedoMapTexture=s0
