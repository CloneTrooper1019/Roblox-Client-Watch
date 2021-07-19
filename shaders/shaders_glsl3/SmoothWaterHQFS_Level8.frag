#version 150

#extension GL_ARB_shading_language_include : require
#include <Globals.h>
#include <LightShadowGPUTransform.h>
#include <Params.h>
uniform vec4 CB0[53];
uniform vec4 CB8[24];
uniform vec4 CB3[3];
uniform sampler2D ShadowAtlasTexture;
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform samplerCube PrefilteredEnvTexture;
uniform sampler2D NormalMap1Texture;
uniform sampler2D NormalMap2Texture;

in vec4 VARYING0;
in vec3 VARYING1;
in vec2 VARYING2;
in vec2 VARYING3;
in vec2 VARYING4;
in vec3 VARYING5;
in vec4 VARYING6;
in vec4 VARYING7;
out vec4 _entryPointOutput;

void main()
{
    vec3 f0 = CB0[7].xyz - VARYING7.xyz;
    vec3 f1 = -CB0[11].xyz;
    float f2 = clamp(dot(step(CB0[19].xyz, abs(VARYING5 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f3 = VARYING5.yzx - (VARYING5.yzx * f2);
    vec4 f4 = vec4(clamp(f2, 0.0, 1.0));
    vec4 f5 = mix(texture(LightMapTexture, f3), vec4(0.0), f4);
    vec4 f6 = mix(texture(LightGridSkylightTexture, f3), vec4(1.0), f4);
    vec3 f7 = (f5.xyz * (f5.w * 120.0)).xyz;
    float f8 = f6.x;
    float f9 = f6.y;
    vec3 f10 = f0 - CB0[41].xyz;
    vec3 f11 = f0 - CB0[42].xyz;
    vec3 f12 = f0 - CB0[43].xyz;
    vec4 f13 = vec4(f0, 1.0) * mat4(CB8[((dot(f10, f10) < CB0[41].w) ? 0 : ((dot(f11, f11) < CB0[42].w) ? 1 : ((dot(f12, f12) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f10, f10) < CB0[41].w) ? 0 : ((dot(f11, f11) < CB0[42].w) ? 1 : ((dot(f12, f12) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f10, f10) < CB0[41].w) ? 0 : ((dot(f11, f11) < CB0[42].w) ? 1 : ((dot(f12, f12) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f10, f10) < CB0[41].w) ? 0 : ((dot(f11, f11) < CB0[42].w) ? 1 : ((dot(f12, f12) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f14 = textureLod(ShadowAtlasTexture, f13.xy, 0.0);
    vec2 f15 = vec2(0.0);
    f15.x = CB0[46].z;
    vec2 f16 = f15;
    f16.y = CB0[46].w;
    float f17 = (2.0 * f13.z) - 1.0;
    float f18 = exp(CB0[46].z * f17);
    float f19 = -exp((-CB0[46].w) * f17);
    vec2 f20 = (f16 * CB0[47].y) * vec2(f18, f19);
    vec2 f21 = f20 * f20;
    float f22 = f14.x;
    float f23 = max(f14.y - (f22 * f22), f21.x);
    float f24 = f18 - f22;
    float f25 = f14.z;
    float f26 = max(f14.w - (f25 * f25), f21.y);
    float f27 = f19 - f25;
    float f28 = ((dot(VARYING6.xyz, f1) * CB0[47].x) > 0.0) ? mix(min((f18 <= f22) ? 1.0 : clamp(((f23 / (f23 + (f24 * f24))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f19 <= f25) ? 1.0 : clamp(((f26 / (f26 + (f27 * f27))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f9, clamp((length(f0 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f9;
    vec4 f29 = vec4(CB3[0].w);
    float f30 = -VARYING6.x;
    vec4 f31 = ((mix(texture(NormalMap1Texture, VARYING2), texture(NormalMap2Texture, VARYING2), f29) * VARYING0.x) + (mix(texture(NormalMap1Texture, VARYING3), texture(NormalMap2Texture, VARYING3), f29) * VARYING0.y)) + (mix(texture(NormalMap1Texture, VARYING4), texture(NormalMap2Texture, VARYING4), f29) * VARYING0.z);
    vec2 f32 = f31.wy * 2.0;
    vec2 f33 = f32 - vec2(1.0);
    float f34 = f31.x;
    vec3 f35 = vec3(dot(VARYING1, VARYING0.xyz));
    vec3 f36 = vec4(normalize(((mix(vec3(VARYING6.z, 0.0, f30), vec3(VARYING6.y, f30, 0.0), f35) * f33.x) + (mix(vec3(0.0, 1.0, 0.0), vec3(0.0, VARYING6.z, -VARYING6.y), f35) * f33.y)) + (VARYING6.xyz * sqrt(clamp(1.0 + dot(vec2(1.0) - f32, f33), 0.0, 1.0)))), f34).xyz;
    vec3 f37 = mix(VARYING6.xyz, f36, vec3(0.25));
    vec3 f38 = normalize(VARYING7.xyz);
    vec3 f39 = f36 * f36;
    bvec3 f40 = lessThan(f36, vec3(0.0));
    vec3 f41 = vec3(f40.x ? f39.x : vec3(0.0).x, f40.y ? f39.y : vec3(0.0).y, f40.z ? f39.z : vec3(0.0).z);
    vec3 f42 = f39 - f41;
    float f43 = f42.x;
    float f44 = f42.y;
    float f45 = f42.z;
    float f46 = f41.x;
    float f47 = f41.y;
    float f48 = f41.z;
    vec3 f49 = -f38;
    vec3 f50 = reflect(f49, f37);
    vec3 f51 = normalize(f1 + f38);
    float f52 = f34 * f34;
    float f53 = max(0.001000000047497451305389404296875, dot(f36, f51));
    float f54 = dot(f1, f51);
    float f55 = 1.0 - f54;
    float f56 = f55 * f55;
    float f57 = (f56 * f56) * f55;
    float f58 = f52 * f52;
    float f59 = (((f53 * f58) - f53) * f53) + 1.0;
    vec3 f60 = mix(((min(f7 + (CB0[27].xyz + (CB0[28].xyz * f8)), vec3(CB0[16].w)) + (((((((CB0[35].xyz * f43) + (CB0[37].xyz * f44)) + (CB0[39].xyz * f45)) + (CB0[36].xyz * f46)) + (CB0[38].xyz * f47)) + (CB0[40].xyz * f48)) + (((((((CB0[29].xyz * f43) + (CB0[31].xyz * f44)) + (CB0[33].xyz * f45)) + (CB0[30].xyz * f46)) + (CB0[32].xyz * f47)) + (CB0[34].xyz * f48)) * f8))) + (CB0[10].xyz * f28)) * CB3[1].xyz, ((textureLod(PrefilteredEnvTexture, vec4(f50, 0.0).xyz, 0.0).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f50.y * 1.58823525905609130859375, 0.0, 1.0)))) * f8) + (f7 * 0.100000001490116119384765625), vec3(((clamp(0.7799999713897705078125 - (2.5 * abs(dot(f37, f38))), 0.0, 1.0) + 0.300000011920928955078125) * VARYING0.w) * CB3[2].z)) + ((((vec3(f57) + (vec3(0.0199999995529651641845703125) * (1.0 - f57))) * (((f58 + (f58 * f58)) / (((f59 * f59) * ((f54 * 3.0) + 0.5)) * ((f53 * 0.75) + 0.25))) * clamp(dot(f36, f1) * f28, 0.0, 1.0))) * CB0[10].xyz) * clamp(1.0 - (VARYING7.w * CB0[23].y), 0.0, 1.0));
    vec4 f61 = vec4(f60.x, f60.y, f60.z, vec4(0.0).w);
    f61.w = 1.0;
    vec3 f62 = textureLod(PrefilteredEnvTexture, vec4(f49, 0.0).xyz, max(CB0[13].y, VARYING6.w) * 5.0).xyz;
    bvec3 f63 = bvec3(CB0[13].w != 0.0);
    vec3 f64 = sqrt(clamp(mix(vec3(f63.x ? CB0[14].xyz.x : f62.x, f63.y ? CB0[14].xyz.y : f62.y, f63.z ? CB0[14].xyz.z : f62.z), f61.xyz, vec3(VARYING6.w)).xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    _entryPointOutput = vec4(f64.x, f64.y, f64.z, f61.w);
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$NormalMap1Texture=s0
//$$NormalMap2Texture=s2
