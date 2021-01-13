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
uniform sampler2D WangTileMapTexture;
uniform sampler2D DiffuseMapTexture;
uniform sampler2D NormalMapTexture;
uniform sampler2D NormalDetailMapTexture;
uniform sampler2D StudsMapTexture;
uniform sampler2D SpecularMapTexture;

in vec2 VARYING0;
in vec2 VARYING1;
in vec4 VARYING2;
in vec4 VARYING3;
in vec4 VARYING4;
in vec4 VARYING5;
in vec4 VARYING6;
in vec4 VARYING7;
in float VARYING8;
out vec4 _entryPointOutput;

void main()
{
    float f0 = length(VARYING4.xyz);
    vec3 f1 = VARYING4.xyz / vec3(f0);
    vec2 f2 = VARYING1;
    f2.y = (fract(VARYING1.y) + VARYING8) * 0.25;
    float f3 = clamp(1.0 - (VARYING4.w * CB0[23].y), 0.0, 1.0);
    vec2 f4 = VARYING0 * CB2[0].x;
    vec2 f5 = f4 * 4.0;
    vec2 f6 = f5 * 0.25;
    vec4 f7 = vec4(dFdx(f6), dFdy(f6));
    vec2 f8 = (texture(WangTileMapTexture, f5 * vec2(0.0078125)).xy * 0.99609375) + (fract(f5) * 0.25);
    vec2 f9 = f7.xy;
    vec2 f10 = f7.zw;
    vec4 f11 = textureGrad(DiffuseMapTexture, f8, f9, f10);
    vec2 f12 = textureGrad(NormalMapTexture, f8, f9, f10).wy * 2.0;
    vec2 f13 = f12 - vec2(1.0);
    float f14 = sqrt(clamp(1.0 + dot(vec2(1.0) - f12, f13), 0.0, 1.0));
    vec2 f15 = (vec3(f13, f14).xy + (vec3((texture(NormalDetailMapTexture, f4 * CB2[0].w).wy * 2.0) - vec2(1.0), 0.0).xy * CB2[1].x)).xy * f3;
    float f16 = f15.x;
    vec4 f17 = textureGrad(SpecularMapTexture, f8, f9, f10);
    float f18 = gl_FrontFacing ? 1.0 : (-1.0);
    vec3 f19 = VARYING6.xyz * f18;
    vec3 f20 = VARYING5.xyz * f18;
    vec3 f21 = normalize(((f19 * f16) + (cross(f20, f19) * f15.y)) + (f20 * f14));
    vec3 f22 = -CB0[11].xyz;
    float f23 = dot(f21, f22);
    vec3 f24 = vec4(((mix(vec3(1.0), VARYING2.xyz, vec3(clamp(f11.w + CB2[2].w, 0.0, 1.0))) * f11.xyz) * (1.0 + (f16 * CB2[0].z))) * (texture(StudsMapTexture, f2).x * 2.0), VARYING2.w).xyz;
    vec3 f25 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f26 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f27 = VARYING3.yzx - (VARYING3.yzx * f26);
    vec4 f28 = vec4(clamp(f26, 0.0, 1.0));
    vec4 f29 = mix(texture(LightMapTexture, f27), vec4(0.0), f28);
    vec4 f30 = mix(texture(LightGridSkylightTexture, f27), vec4(1.0), f28);
    float f31 = f30.x;
    float f32 = f30.y;
    vec3 f33 = f25 - CB0[41].xyz;
    vec3 f34 = f25 - CB0[42].xyz;
    vec3 f35 = f25 - CB0[43].xyz;
    vec4 f36 = vec4(f25, 1.0) * mat4(CB8[((dot(f33, f33) < CB0[41].w) ? 0 : ((dot(f34, f34) < CB0[42].w) ? 1 : ((dot(f35, f35) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f33, f33) < CB0[41].w) ? 0 : ((dot(f34, f34) < CB0[42].w) ? 1 : ((dot(f35, f35) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f33, f33) < CB0[41].w) ? 0 : ((dot(f34, f34) < CB0[42].w) ? 1 : ((dot(f35, f35) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f33, f33) < CB0[41].w) ? 0 : ((dot(f34, f34) < CB0[42].w) ? 1 : ((dot(f35, f35) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
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
    vec3 f51 = (f24 * f24).xyz;
    float f52 = CB0[26].w * f3;
    float f53 = max(f17.y, 0.04500000178813934326171875);
    vec3 f54 = reflect(-f1, f21);
    float f55 = f53 * 5.0;
    vec3 f56 = vec4(f54, f55).xyz;
    vec4 f57 = texture(PrecomputedBRDFTexture, vec2(f53, max(9.9999997473787516355514526367188e-05, dot(f21, f1))));
    float f58 = f17.x * f52;
    vec3 f59 = mix(vec3(0.039999999105930328369140625), f51, vec3(f58));
    vec3 f60 = normalize(f22 + f1);
    float f61 = clamp(f23 * ((f23 > 0.0) ? mix(f32, mix(min((f41 <= f45) ? 1.0 : clamp(((f46 / (f46 + (f47 * f47))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f42 <= f48) ? 1.0 : clamp(((f49 / (f49 + (f50 * f50))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f32, clamp((length(f25 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)), CB0[47].x) : 0.0), 0.0, 1.0);
    float f62 = f53 * f53;
    float f63 = max(0.001000000047497451305389404296875, dot(f21, f60));
    float f64 = dot(f22, f60);
    float f65 = 1.0 - f64;
    float f66 = f65 * f65;
    float f67 = (f66 * f66) * f65;
    vec3 f68 = vec3(f67) + (f59 * (1.0 - f67));
    float f69 = f62 * f62;
    float f70 = (((f63 * f69) - f63) * f63) + 1.0;
    float f71 = 1.0 - f58;
    float f72 = f52 * f71;
    vec3 f73 = vec3(f71);
    float f74 = f57.x;
    float f75 = f57.y;
    vec3 f76 = ((f59 * f74) + vec3(f75)) / vec3(f74 + f75);
    vec3 f77 = f73 - (f76 * f72);
    vec3 f78 = f21 * f21;
    bvec3 f79 = lessThan(f21, vec3(0.0));
    vec3 f80 = vec3(f79.x ? f78.x : vec3(0.0).x, f79.y ? f78.y : vec3(0.0).y, f79.z ? f78.z : vec3(0.0).z);
    vec3 f81 = f78 - f80;
    float f82 = f81.x;
    float f83 = f81.y;
    float f84 = f81.z;
    float f85 = f80.x;
    float f86 = f80.y;
    float f87 = f80.z;
    vec3 f88 = ((((((CB0[35].xyz * f82) + (CB0[37].xyz * f83)) + (CB0[39].xyz * f84)) + (CB0[36].xyz * f85)) + (CB0[38].xyz * f86)) + (CB0[40].xyz * f87)) + (((((((CB0[29].xyz * f82) + (CB0[31].xyz * f83)) + (CB0[33].xyz * f84)) + (CB0[30].xyz * f85)) + (CB0[32].xyz * f86)) + (CB0[34].xyz * f87)) * f31);
    vec3 f89 = (mix(textureLod(PrefilteredEnvIndoorTexture, f56, f55).xyz, textureLod(PrefilteredEnvTexture, f56, f55).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f54.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f31)) * f76) * f52;
    vec3 f90 = (((((((f73 - (f68 * f72)) * CB0[10].xyz) * f61) + ((f77 * f88) * CB0[25].w)) + ((CB0[27].xyz + (CB0[28].xyz * f31)) * 1.0)) * f51) + (((f68 * (((f69 + (f69 * f69)) / (((f70 * f70) * ((f64 * 3.0) + 0.5)) * ((f63 * 0.75) + 0.25))) * f61)) * CB0[10].xyz) + (f89 * f31))) + (((f29.xyz * (f29.w * 120.0)).xyz * mix(f51, f89 * (1.0 / (max(max(f88.x, f88.y), f88.z) + 0.00999999977648258209228515625)), (vec3(1.0) - f77) * (f52 * (1.0 - f31)))) * 1.0);
    vec4 f91 = vec4(f90.x, f90.y, f90.z, vec4(0.0).w);
    f91.w = VARYING2.w;
    float f92 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f93 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f92) * 5.0).xyz;
    bvec3 f94 = bvec3(CB0[13].w != 0.0);
    vec3 f95 = sqrt(clamp(mix(vec3(f94.x ? CB0[14].xyz.x : f93.x, f94.y ? CB0[14].xyz.y : f93.y, f94.z ? CB0[14].xyz.z : f93.z), f91.xyz, vec3(f92)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f96 = vec4(f95.x, f95.y, f95.z, f91.w);
    f96.w = VARYING2.w;
    _entryPointOutput = f96;
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrecomputedBRDFTexture=s11
//$$WangTileMapTexture=s9
//$$DiffuseMapTexture=s3
//$$NormalMapTexture=s4
//$$NormalDetailMapTexture=s8
//$$StudsMapTexture=s0
//$$SpecularMapTexture=s5
