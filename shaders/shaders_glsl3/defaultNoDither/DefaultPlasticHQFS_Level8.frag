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
uniform sampler2D DiffuseMapTexture;
uniform sampler2D NormalMapTexture;
uniform sampler2D NormalDetailMapTexture;

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
    vec2 f4 = texture(NormalMapTexture, f2).wy * 2.0;
    vec2 f5 = f4 - vec2(1.0);
    float f6 = sqrt(clamp(1.0 + dot(vec2(1.0) - f4, f5), 0.0, 1.0));
    vec2 f7 = ((vec3(f5, f6).xy + (vec3((texture(NormalDetailMapTexture, VARYING0 * CB2[0].x).wy * 2.0) - vec2(1.0), 0.0).xy * (clamp(VARYING2.w - 0.5, 0.0, 1.0) * clamp(1.0 - (2.0 * VARYING7.w), 0.0, 1.0)))).xy * f3).xy * CB2[3].w;
    float f8 = gl_FrontFacing ? 1.0 : (-1.0);
    vec3 f9 = VARYING6.xyz * f8;
    vec3 f10 = VARYING5.xyz * f8;
    vec3 f11 = normalize(((f9 * f7.x) + (cross(f10, f9) * f7.y)) + (f10 * f6));
    vec3 f12 = -CB0[11].xyz;
    float f13 = dot(f11, f12);
    vec3 f14 = vec4(VARYING2.xyz * (texture(DiffuseMapTexture, f2).x * 2.0), VARYING2.w).xyz;
    vec3 f15 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f16 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f17 = VARYING3.yzx - (VARYING3.yzx * f16);
    vec4 f18 = vec4(clamp(f16, 0.0, 1.0));
    vec4 f19 = mix(texture(LightMapTexture, f17), vec4(0.0), f18);
    vec4 f20 = mix(texture(LightGridSkylightTexture, f17), vec4(1.0), f18);
    vec3 f21 = (f19.xyz * (f19.w * 120.0)).xyz;
    float f22 = f20.x;
    float f23 = f20.y;
    vec3 f24 = f15 - CB0[41].xyz;
    vec3 f25 = f15 - CB0[42].xyz;
    vec3 f26 = f15 - CB0[43].xyz;
    vec4 f27 = vec4(f15, 1.0) * mat4(CB8[((dot(f24, f24) < CB0[41].w) ? 0 : ((dot(f25, f25) < CB0[42].w) ? 1 : ((dot(f26, f26) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f24, f24) < CB0[41].w) ? 0 : ((dot(f25, f25) < CB0[42].w) ? 1 : ((dot(f26, f26) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f24, f24) < CB0[41].w) ? 0 : ((dot(f25, f25) < CB0[42].w) ? 1 : ((dot(f26, f26) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f24, f24) < CB0[41].w) ? 0 : ((dot(f25, f25) < CB0[42].w) ? 1 : ((dot(f26, f26) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f28 = textureLod(ShadowAtlasTexture, f27.xy, 0.0);
    vec2 f29 = vec2(0.0);
    f29.x = CB0[46].z;
    vec2 f30 = f29;
    f30.y = CB0[46].w;
    float f31 = (2.0 * f27.z) - 1.0;
    float f32 = exp(CB0[46].z * f31);
    float f33 = -exp((-CB0[46].w) * f31);
    vec2 f34 = (f30 * CB0[47].y) * vec2(f32, f33);
    vec2 f35 = f34 * f34;
    float f36 = f28.x;
    float f37 = max(f28.y - (f36 * f36), f35.x);
    float f38 = f32 - f36;
    float f39 = f28.z;
    float f40 = max(f28.w - (f39 * f39), f35.y);
    float f41 = f33 - f39;
    float f42 = CB0[26].w * f3;
    float f43 = max(CB2[0].y, 0.04500000178813934326171875);
    vec3 f44 = reflect(-f1, f11);
    float f45 = (VARYING7.w != 0.0) ? 0.0 : (f43 * 5.0);
    vec3 f46 = vec4(f44, f45).xyz;
    vec3 f47 = textureLod(PrefilteredEnvTexture, f46, f45).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f44.y * 1.58823525905609130859375, 0.0, 1.0)));
    vec4 f48 = texture(PrecomputedBRDFTexture, vec2(f43, max(9.9999997473787516355514526367188e-05, dot(f11, f1))));
    vec3 f49 = mix((f14 * f14).xyz, f47, vec3(VARYING7.w));
    vec3 f50 = normalize(f12 + f1);
    float f51 = clamp(f13 * (((f13 * CB0[47].x) > 0.0) ? mix(min((f32 <= f36) ? 1.0 : clamp(((f37 / (f37 + (f38 * f38))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f33 <= f39) ? 1.0 : clamp(((f40 / (f40 + (f41 * f41))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f23, clamp((length(f15 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f23), 0.0, 1.0);
    float f52 = f43 * f43;
    float f53 = max(0.001000000047497451305389404296875, dot(f11, f50));
    float f54 = dot(f12, f50);
    float f55 = 1.0 - f54;
    float f56 = f55 * f55;
    float f57 = (f56 * f56) * f55;
    vec3 f58 = vec3(f57) + (vec3(0.039999999105930328369140625) * (1.0 - f57));
    float f59 = f52 * f52;
    float f60 = (((f53 * f59) - f53) * f53) + 1.0;
    float f61 = f48.x;
    float f62 = f48.y;
    vec3 f63 = ((vec3(0.039999999105930328369140625) * f61) + vec3(f62)) / vec3(f61 + f62);
    vec3 f64 = f63 * f42;
    vec3 f65 = f11 * f11;
    bvec3 f66 = lessThan(f11, vec3(0.0));
    vec3 f67 = vec3(f66.x ? f65.x : vec3(0.0).x, f66.y ? f65.y : vec3(0.0).y, f66.z ? f65.z : vec3(0.0).z);
    vec3 f68 = f65 - f67;
    float f69 = f68.x;
    float f70 = f68.y;
    float f71 = f68.z;
    float f72 = f67.x;
    float f73 = f67.y;
    float f74 = f67.z;
    vec3 f75 = (mix(textureLod(PrefilteredEnvIndoorTexture, f46, f45).xyz * f21, f47, vec3(f22)) * f63) * f42;
    vec3 f76 = (((((((vec3(1.0) - (f58 * f42)) * CB0[10].xyz) * f51) + ((vec3(1.0) - f64) * (((((((CB0[35].xyz * f69) + (CB0[37].xyz * f70)) + (CB0[39].xyz * f71)) + (CB0[36].xyz * f72)) + (CB0[38].xyz * f73)) + (CB0[40].xyz * f74)) + (((((((CB0[29].xyz * f69) + (CB0[31].xyz * f70)) + (CB0[33].xyz * f71)) + (CB0[30].xyz * f72)) + (CB0[32].xyz * f73)) + (CB0[34].xyz * f74)) * f22)))) + (CB0[27].xyz + (CB0[28].xyz * f22))) * f49) + (((f58 * (((f59 + (f59 * f59)) / (((f60 * f60) * ((f54 * 3.0) + 0.5)) * ((f53 * 0.75) + 0.25))) * f51)) * CB0[10].xyz) + f75)) + ((f21 * mix(f49, f75 * (1.0 / (max(max(f75.x, f75.y), f75.z) + 0.00999999977648258209228515625)), f64 * (f42 * (1.0 - f22)))) * 1.0);
    vec4 f77 = vec4(f76.x, f76.y, f76.z, vec4(0.0).w);
    f77.w = VARYING2.w;
    float f78 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f79 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f78) * 5.0).xyz;
    bvec3 f80 = bvec3(CB0[13].w != 0.0);
    vec3 f81 = sqrt(clamp(mix(vec3(f80.x ? CB0[14].xyz.x : f79.x, f80.y ? CB0[14].xyz.y : f79.y, f80.z ? CB0[14].xyz.z : f79.z), f77.xyz, vec3(f78)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f82 = vec4(f81.x, f81.y, f81.z, f77.w);
    f82.w = VARYING2.w;
    _entryPointOutput = f82;
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
