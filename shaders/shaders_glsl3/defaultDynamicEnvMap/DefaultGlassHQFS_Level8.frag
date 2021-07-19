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
uniform samplerCube PrefilteredEnvBlendTargetTexture;
uniform sampler2D PrecomputedBRDFTexture;
uniform sampler2D DiffuseMapTexture;
uniform sampler2D NormalMapTexture;
uniform sampler2D NormalDetailMapTexture;
uniform sampler2D SpecularMapTexture;

in vec2 VARYING0;
in vec4 VARYING2;
in vec4 VARYING3;
in vec4 VARYING4;
in vec4 VARYING5;
in vec4 VARYING6;
in vec4 VARYING7;
out vec4 _entryPointOutput;

void main()
{
    float f0 = clamp(1.0 - (VARYING4.w * CB0[23].y), 0.0, 1.0);
    vec2 f1 = VARYING0 * CB2[0].x;
    vec4 f2 = texture(DiffuseMapTexture, f1);
    vec4 f3 = texture(NormalMapTexture, f1);
    vec2 f4 = f3.wy * 2.0;
    vec2 f5 = f4 - vec2(1.0);
    float f6 = sqrt(clamp(1.0 + dot(vec2(1.0) - f4, f5), 0.0, 1.0));
    vec4 f7 = texture(NormalDetailMapTexture, f1 * CB2[0].w);
    vec2 f8 = (vec3(f5, f6).xy + (vec3((f7.wy * 2.0) - vec2(1.0), 0.0).xy * CB2[1].x)).xy * f0;
    float f9 = f2.w;
    vec3 f10 = (mix(vec3(1.0), VARYING2.xyz, vec3(clamp(f9 + CB2[2].w, 0.0, 1.0))) * f2.xyz) * (1.0 + (f8.x * CB2[0].z));
    vec4 f11 = texture(SpecularMapTexture, f1 * CB2[1].w);
    vec4 f12 = texture(SpecularMapTexture, f1);
    vec4 f13 = mix(f11, f12, vec4(clamp((f0 * CB2[3].z) - (CB2[2].z * CB2[3].z), 0.0, 1.0)));
    float f14 = f13.y;
    float f15 = VARYING2.w * 2.0;
    float f16 = clamp((f15 - 1.0) + f9, 0.0, 1.0);
    float f17 = gl_FrontFacing ? 1.0 : (-1.0);
    vec3 f18 = VARYING6.xyz * f17;
    vec3 f19 = VARYING5.xyz * f17;
    vec3 f20 = normalize(((f18 * f8.x) + (cross(f19, f18) * f8.y)) + (f19 * (f6 * 10.0)));
    vec3 f21 = -CB0[11].xyz;
    float f22 = dot(f20, f21);
    vec3 f23 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f24 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f25 = VARYING3.yzx - (VARYING3.yzx * f24);
    vec4 f26 = texture(LightMapTexture, f25);
    vec4 f27 = texture(LightGridSkylightTexture, f25);
    vec4 f28 = vec4(clamp(f24, 0.0, 1.0));
    vec4 f29 = mix(f26, vec4(0.0), f28);
    vec4 f30 = mix(f27, vec4(1.0), f28);
    vec3 f31 = (f29.xyz * (f29.w * 120.0)).xyz;
    float f32 = f30.x;
    float f33 = f30.y;
    vec3 f34 = f23 - CB0[41].xyz;
    vec3 f35 = f23 - CB0[42].xyz;
    vec3 f36 = f23 - CB0[43].xyz;
    vec4 f37 = vec4(f23, 1.0) * mat4(CB8[((dot(f34, f34) < CB0[41].w) ? 0 : ((dot(f35, f35) < CB0[42].w) ? 1 : ((dot(f36, f36) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f34, f34) < CB0[41].w) ? 0 : ((dot(f35, f35) < CB0[42].w) ? 1 : ((dot(f36, f36) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f34, f34) < CB0[41].w) ? 0 : ((dot(f35, f35) < CB0[42].w) ? 1 : ((dot(f36, f36) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f34, f34) < CB0[41].w) ? 0 : ((dot(f35, f35) < CB0[42].w) ? 1 : ((dot(f36, f36) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f38 = textureLod(ShadowAtlasTexture, f37.xy, 0.0);
    vec2 f39 = vec2(0.0);
    f39.x = CB0[46].z;
    vec2 f40 = f39;
    f40.y = CB0[46].w;
    float f41 = (2.0 * f37.z) - 1.0;
    float f42 = exp(CB0[46].z * f41);
    float f43 = -exp((-CB0[46].w) * f41);
    vec2 f44 = (f40 * CB0[47].y) * vec2(f42, f43);
    vec2 f45 = f44 * f44;
    float f46 = f38.x;
    float f47 = max(f38.y - (f46 * f46), f45.x);
    float f48 = f42 - f46;
    float f49 = f38.z;
    float f50 = max(f38.w - (f49 * f49), f45.y);
    float f51 = f43 - f49;
    vec3 f52 = f10 * f10;
    float f53 = length(VARYING4.xyz);
    vec3 f54 = VARYING4.xyz / vec3(f53);
    float f55 = CB0[26].w * f0;
    float f56 = max(9.9999997473787516355514526367188e-05, dot(f20, f54));
    vec3 f57 = reflect(-f54, f20);
    float f58 = f14 * 5.0;
    vec3 f59 = vec4(f57, f58).xyz;
    vec3 f60 = textureLod(PrefilteredEnvTexture, f59, f58).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f57.y * 1.58823525905609130859375, 0.0, 1.0)));
    vec3 f61 = textureLod(PrefilteredEnvIndoorTexture, f59, f58).xyz;
    vec3 f62;
    if (CB0[27].w == 0.0)
    {
        f62 = f61;
    }
    else
    {
        f62 = mix(f61, textureLod(PrefilteredEnvBlendTargetTexture, f59, f58).xyz, vec3(CB0[27].w));
    }
    vec4 f63 = texture(PrecomputedBRDFTexture, vec2(f14, f56));
    vec3 f64 = normalize(f21 + f54);
    float f65 = clamp(f22 * (((f22 * CB0[47].x) > 0.0) ? mix(min((f42 <= f46) ? 1.0 : clamp(((f47 / (f47 + (f48 * f48))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f43 <= f49) ? 1.0 : clamp(((f50 / (f50 + (f51 * f51))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f33, clamp((length(f23 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f33), 0.0, 1.0);
    float f66 = f14 * f14;
    float f67 = max(0.001000000047497451305389404296875, dot(f20, f64));
    float f68 = dot(f21, f64);
    float f69 = 1.0 - f68;
    float f70 = f69 * f69;
    float f71 = (f70 * f70) * f69;
    vec3 f72 = vec3(f71) + (vec3(0.039999999105930328369140625) * (1.0 - f71));
    float f73 = f66 * f66;
    float f74 = (((f67 * f73) - f67) * f67) + 1.0;
    vec3 f75 = vec3(f32);
    vec3 f76 = mix(f31, f60, f75) * mix(vec3(1.0), f52, vec3(0.5));
    float f77 = f63.x;
    float f78 = f63.y;
    vec3 f79 = ((vec3(0.039999999105930328369140625) * f77) + vec3(f78)) / vec3(f77 + f78);
    vec3 f80 = f20 * f20;
    bvec3 f81 = lessThan(f20, vec3(0.0));
    vec3 f82 = vec3(f81.x ? f80.x : vec3(0.0).x, f81.y ? f80.y : vec3(0.0).y, f81.z ? f80.z : vec3(0.0).z);
    vec3 f83 = f80 - f82;
    float f84 = f83.x;
    float f85 = f83.y;
    float f86 = f83.z;
    float f87 = f82.x;
    float f88 = f82.y;
    float f89 = f82.z;
    float f90 = 1.0 - f56;
    vec4 f91 = mix(vec4(mix(((((((vec3(1.0) - (f72 * f55)) * CB0[10].xyz) * f65) + (f31 * f16)) + (((vec3(1.0) - (f79 * f55)) * (((((((CB0[35].xyz * f84) + (CB0[37].xyz * f85)) + (CB0[39].xyz * f86)) + (CB0[36].xyz * f87)) + (CB0[38].xyz * f88)) + (CB0[40].xyz * f89)) + (((((((CB0[29].xyz * f84) + (CB0[31].xyz * f85)) + (CB0[33].xyz * f86)) + (CB0[30].xyz * f87)) + (CB0[32].xyz * f88)) + (CB0[34].xyz * f89)) * f32))) * f16)) + (CB0[27].xyz + (CB0[28].xyz * f32))) * (f52 * f16), f76, vec3(VARYING7.w)) * f16, f16), vec4(f76, 1.0), vec4(((f90 * f90) * 0.800000011920928955078125) * clamp(f15, 0.0, 1.0))) + vec4(((f72 * (((f73 + (f73 * f73)) / (((f74 * f74) * ((f68 * 3.0) + 0.5)) * ((f67 * 0.75) + 0.25))) * f65)) * CB0[10].xyz) + (((mix(f62, f60, f75) * f79) * f55) * f16), 0.0);
    float f92 = clamp(exp2((CB0[13].z * f53) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f93 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f92) * 5.0).xyz;
    bvec3 f94 = bvec3(CB0[13].w != 0.0);
    vec3 f95 = mix(vec3(f94.x ? CB0[14].xyz.x : f93.x, f94.y ? CB0[14].xyz.y : f93.y, f94.z ? CB0[14].xyz.z : f93.z), f91.xyz, vec3(f92));
    vec4 f96 = vec4(f95.x, f95.y, f95.z, f91.w);
    f96.w = 1.0 - ((1.0 - f91.w) * f92);
    vec3 f97 = sqrt(clamp(f96.xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    _entryPointOutput = vec4(f97.x, f97.y, f97.z, f96.w);
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrefilteredEnvBlendTargetTexture=s2
//$$PrecomputedBRDFTexture=s11
//$$DiffuseMapTexture=s3
//$$NormalMapTexture=s4
//$$NormalDetailMapTexture=s8
//$$SpecularMapTexture=s5
