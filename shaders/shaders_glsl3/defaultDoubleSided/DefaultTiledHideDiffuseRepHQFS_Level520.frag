#version 150

#extension GL_ARB_shading_language_include : require
#include <Globals.h>
#include <LightShadowGPUTransform.h>
#include <MaterialParams.h>
uniform vec4 CB0[52];
uniform vec4 CB8[24];
uniform vec4 CB2[4];
uniform sampler2D ShadowAtlasTexture;
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform samplerCube PrefilteredEnvTexture;
uniform samplerCube PrefilteredEnvIndoorTexture;
uniform sampler2D PrecomputedBRDFTexture;
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
    vec4 f5 = mix(texture(DiffuseMapTexture, f4 * CB2[1].y), texture(DiffuseMapTexture, f4), vec4(clamp((clamp(1.0 - (VARYING4.w * 0.0033333334140479564666748046875), 0.0, 1.0) * CB2[3].x) - (CB2[2].x * CB2[3].x), 0.0, 1.0)));
    vec2 f6 = texture(NormalMapTexture, f4).wy * 2.0;
    vec2 f7 = f6 - vec2(1.0);
    float f8 = sqrt(clamp(1.0 + dot(vec2(1.0) - f6, f7), 0.0, 1.0));
    vec2 f9 = (vec3(f7, f8).xy + (vec3((texture(NormalDetailMapTexture, f4 * CB2[0].w).wy * 2.0) - vec2(1.0), 0.0).xy * CB2[1].x)).xy * f3;
    float f10 = f9.x;
    vec4 f11 = texture(SpecularMapTexture, f4);
    float f12 = gl_FrontFacing ? 1.0 : (-1.0);
    vec3 f13 = VARYING6.xyz * f12;
    vec3 f14 = VARYING5.xyz * f12;
    vec3 f15 = normalize(((f13 * f10) + (cross(f14, f13) * f9.y)) + (f14 * f8));
    vec3 f16 = -CB0[11].xyz;
    float f17 = dot(f15, f16);
    vec3 f18 = vec4(((mix(vec3(1.0), VARYING2.xyz, vec3(clamp(f5.w + CB2[2].w, 0.0, 1.0))) * f5.xyz) * (1.0 + (f10 * CB2[0].z))) * (texture(StudsMapTexture, f2).x * 2.0), VARYING2.w).xyz;
    vec3 f19 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f20 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f21 = VARYING3.yzx - (VARYING3.yzx * f20);
    vec4 f22 = vec4(clamp(f20, 0.0, 1.0));
    vec4 f23 = mix(texture(LightMapTexture, f21), vec4(0.0), f22);
    vec4 f24 = mix(texture(LightGridSkylightTexture, f21), vec4(1.0), f22);
    float f25 = f24.x;
    float f26 = f24.y;
    vec3 f27 = f19 - CB0[41].xyz;
    vec3 f28 = f19 - CB0[42].xyz;
    vec3 f29 = f19 - CB0[43].xyz;
    vec4 f30 = vec4(f19, 1.0) * mat4(CB8[((dot(f27, f27) < CB0[41].w) ? 0 : ((dot(f28, f28) < CB0[42].w) ? 1 : ((dot(f29, f29) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f27, f27) < CB0[41].w) ? 0 : ((dot(f28, f28) < CB0[42].w) ? 1 : ((dot(f29, f29) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f27, f27) < CB0[41].w) ? 0 : ((dot(f28, f28) < CB0[42].w) ? 1 : ((dot(f29, f29) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f27, f27) < CB0[41].w) ? 0 : ((dot(f28, f28) < CB0[42].w) ? 1 : ((dot(f29, f29) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f31 = textureLod(ShadowAtlasTexture, f30.xy, 0.0);
    vec2 f32 = vec2(0.0);
    f32.x = CB0[45].z;
    vec2 f33 = f32;
    f33.y = CB0[45].w;
    float f34 = (2.0 * f30.z) - 1.0;
    float f35 = exp(CB0[45].z * f34);
    float f36 = -exp((-CB0[45].w) * f34);
    vec2 f37 = (f33 * CB0[46].y) * vec2(f35, f36);
    vec2 f38 = f37 * f37;
    float f39 = f31.x;
    float f40 = max(f31.y - (f39 * f39), f38.x);
    float f41 = f35 - f39;
    float f42 = f31.z;
    float f43 = max(f31.w - (f42 * f42), f38.y);
    float f44 = f36 - f42;
    vec3 f45 = (f18 * f18).xyz;
    float f46 = CB0[26].w * f3;
    float f47 = max(f11.y, 0.04500000178813934326171875);
    vec3 f48 = reflect(-f1, f15);
    float f49 = f47 * 5.0;
    vec3 f50 = vec4(f48, f49).xyz;
    vec4 f51 = texture(PrecomputedBRDFTexture, vec2(f47, max(9.9999997473787516355514526367188e-05, dot(f15, f1))));
    float f52 = f11.x * f46;
    vec3 f53 = mix(vec3(0.039999999105930328369140625), f45, vec3(f52));
    vec3 f54 = normalize(f16 + f1);
    float f55 = clamp(f17 * ((f17 > 0.0) ? mix(f26, mix(min((f35 <= f39) ? 1.0 : clamp(((f40 / (f40 + (f41 * f41))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f36 <= f42) ? 1.0 : clamp(((f43 / (f43 + (f44 * f44))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f26, clamp((length(f19 - CB0[7].xyz) * CB0[45].y) - (CB0[45].x * CB0[45].y), 0.0, 1.0)), CB0[46].x) : 0.0), 0.0, 1.0);
    float f56 = f47 * f47;
    float f57 = max(0.001000000047497451305389404296875, dot(f15, f54));
    float f58 = dot(f16, f54);
    float f59 = 1.0 - f58;
    float f60 = f59 * f59;
    float f61 = (f60 * f60) * f59;
    vec3 f62 = vec3(f61) + (f53 * (1.0 - f61));
    float f63 = f56 * f56;
    float f64 = (((f57 * f63) - f57) * f57) + 1.0;
    float f65 = 1.0 - f52;
    float f66 = f46 * f65;
    vec3 f67 = vec3(f65);
    float f68 = f51.x;
    float f69 = f51.y;
    vec3 f70 = ((f53 * f68) + vec3(f69)) / vec3(f68 + f69);
    vec3 f71 = f67 - (f70 * f66);
    vec3 f72 = f15 * f15;
    bvec3 f73 = lessThan(f15, vec3(0.0));
    vec3 f74 = vec3(f73.x ? f72.x : vec3(0.0).x, f73.y ? f72.y : vec3(0.0).y, f73.z ? f72.z : vec3(0.0).z);
    vec3 f75 = f72 - f74;
    float f76 = f75.x;
    float f77 = f75.y;
    float f78 = f75.z;
    float f79 = f74.x;
    float f80 = f74.y;
    float f81 = f74.z;
    vec3 f82 = ((((((CB0[35].xyz * f76) + (CB0[37].xyz * f77)) + (CB0[39].xyz * f78)) + (CB0[36].xyz * f79)) + (CB0[38].xyz * f80)) + (CB0[40].xyz * f81)) + (((((((CB0[29].xyz * f76) + (CB0[31].xyz * f77)) + (CB0[33].xyz * f78)) + (CB0[30].xyz * f79)) + (CB0[32].xyz * f80)) + (CB0[34].xyz * f81)) * f25);
    vec3 f83 = (mix(textureLod(PrefilteredEnvIndoorTexture, f50, f49).xyz, textureLod(PrefilteredEnvTexture, f50, f49).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f48.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f25)) * f70) * f46;
    vec3 f84 = (((((((f67 - (f62 * f66)) * CB0[10].xyz) * f55) + ((f71 * f82) * CB0[25].w)) + (CB0[27].xyz + (CB0[28].xyz * f25))) * f45) + (((f62 * (((f63 + (f63 * f63)) / (((f64 * f64) * ((f58 * 3.0) + 0.5)) * ((f57 * 0.75) + 0.25))) * f55)) * CB0[10].xyz) + f83)) + ((f23.xyz * (f23.w * 120.0)).xyz * mix(f45, f83 * (1.0 / (max(max(f82.x, f82.y), f82.z) + 0.00999999977648258209228515625)), (vec3(1.0) - f71) * (f46 * (1.0 - f25))));
    vec4 f85 = vec4(f84.x, f84.y, f84.z, vec4(0.0).w);
    f85.w = VARYING2.w;
    float f86 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f87 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f86) * 5.0).xyz;
    bvec3 f88 = bvec3(CB0[13].w != 0.0);
    vec3 f89 = sqrt(clamp(mix(vec3(f88.x ? CB0[14].xyz.x : f87.x, f88.y ? CB0[14].xyz.y : f87.y, f88.z ? CB0[14].xyz.z : f87.z), f85.xyz, vec3(f86)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f90 = vec4(f89.x, f89.y, f89.z, f85.w);
    f90.w = VARYING2.w;
    _entryPointOutput = f90;
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrecomputedBRDFTexture=s11
//$$DiffuseMapTexture=s3
//$$NormalMapTexture=s4
//$$NormalDetailMapTexture=s8
//$$StudsMapTexture=s0
//$$SpecularMapTexture=s5
