#version 150

#extension GL_ARB_shading_language_include : require
#include <Globals.h>
#include <LightShadowGPUTransform.h>
#include <SAParams.h>
uniform vec4 CB0[53];
uniform vec4 CB8[24];
uniform vec4 CB3[1];
uniform sampler2D ShadowAtlasTexture;
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform samplerCube PrefilteredEnvTexture;
uniform samplerCube PrefilteredEnvIndoorTexture;
uniform samplerCube PrefilteredEnvBlendTargetTexture;
uniform sampler2D PrecomputedBRDFTexture;
uniform sampler2D DiffuseMapTexture;
uniform sampler2D Tc2DiffuseMapTexture;
uniform sampler2D NormalMapTexture;
uniform sampler2D SpecularMapTexture;

in vec2 VARYING0;
in vec2 VARYING1;
in vec4 VARYING2;
in vec4 VARYING3;
in vec4 VARYING4;
in vec4 VARYING5;
in vec4 VARYING6;
in vec4 VARYING7;
out vec4 _entryPointOutput;

void main()
{
    float f0 = length(VARYING4.xyz);
    vec3 f1 = VARYING4.xyz / vec3(f0);
    float f2 = clamp(1.0 - (VARYING4.w * CB0[23].y), 0.0, 1.0);
    vec4 f3 = texture(DiffuseMapTexture, VARYING0);
    vec4 f4 = texture(Tc2DiffuseMapTexture, VARYING1);
    float f5 = f4.w;
    vec4 f6 = vec4(mix(vec4(f3.xyz * VARYING2.xyz, f5).xyz, f4.xyz, vec3(f5)), f5);
    vec4 f7 = vec4(f4.xyz, f5 * f5);
    bvec4 f8 = bvec4(CB3[0].x != 0.0);
    vec4 f9 = vec4(f8.x ? f6.x : f7.x, f8.y ? f6.y : f7.y, f8.z ? f6.z : f7.z, f8.w ? f6.w : f7.w);
    vec4 f10 = texture(NormalMapTexture, VARYING1);
    vec2 f11 = f10.wy * 2.0;
    vec2 f12 = f11 - vec2(1.0);
    float f13 = sqrt(clamp(1.0 + dot(vec2(1.0) - f11, f12), 0.0, 1.0));
    vec2 f14 = vec3(f12, f13).xy * f2;
    vec4 f15 = texture(SpecularMapTexture, VARYING1);
    float f16 = gl_FrontFacing ? 1.0 : (-1.0);
    vec3 f17 = VARYING6.xyz * f16;
    vec3 f18 = VARYING5.xyz * f16;
    vec3 f19 = normalize(((f17 * f14.x) + ((cross(f18, f17) * VARYING6.w) * f14.y)) + (f18 * f13));
    vec3 f20 = -CB0[11].xyz;
    float f21 = dot(f19, f20);
    vec3 f22 = f9.xyz;
    vec3 f23 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f24 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f25 = VARYING3.yzx - (VARYING3.yzx * f24);
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
    vec3 f51 = (f22 * f22).xyz;
    float f52 = CB0[26].w * f2;
    float f53 = max(f15.y, 0.04500000178813934326171875);
    vec3 f54 = reflect(-f1, f19);
    float f55 = f53 * 5.0;
    vec3 f56 = vec4(f54, f55).xyz;
    vec3 f57 = textureLod(PrefilteredEnvIndoorTexture, f56, f55).xyz;
    vec3 f58;
    if (CB0[27].w == 0.0)
    {
        f58 = f57;
    }
    else
    {
        f58 = mix(f57, textureLod(PrefilteredEnvBlendTargetTexture, f56, f55).xyz, vec3(CB0[27].w));
    }
    vec4 f59 = texture(PrecomputedBRDFTexture, vec2(f53, max(9.9999997473787516355514526367188e-05, dot(f19, f1))));
    float f60 = f15.x * f52;
    vec3 f61 = mix(vec3(0.039999999105930328369140625), f51, vec3(f60));
    vec3 f62 = normalize(f20 + f1);
    float f63 = clamp(f21 * (((f21 * CB0[47].x) > 0.0) ? mix(min((f41 <= f45) ? 1.0 : clamp(((f46 / (f46 + (f47 * f47))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f42 <= f48) ? 1.0 : clamp(((f49 / (f49 + (f50 * f50))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f32, clamp((length(f23 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f32), 0.0, 1.0);
    float f64 = f53 * f53;
    float f65 = max(0.001000000047497451305389404296875, dot(f19, f62));
    float f66 = dot(f20, f62);
    float f67 = 1.0 - f66;
    float f68 = f67 * f67;
    float f69 = (f68 * f68) * f67;
    vec3 f70 = vec3(f69) + (f61 * (1.0 - f69));
    float f71 = f64 * f64;
    float f72 = (((f65 * f71) - f65) * f65) + 1.0;
    float f73 = 1.0 - f60;
    float f74 = f52 * f73;
    vec3 f75 = vec3(f73);
    float f76 = f59.x;
    float f77 = f59.y;
    vec3 f78 = ((f61 * f76) + vec3(f77)) / vec3(f76 + f77);
    vec3 f79 = f19 * f19;
    bvec3 f80 = lessThan(f19, vec3(0.0));
    vec3 f81 = vec3(f80.x ? f79.x : vec3(0.0).x, f80.y ? f79.y : vec3(0.0).y, f80.z ? f79.z : vec3(0.0).z);
    vec3 f82 = f79 - f81;
    float f83 = f82.x;
    float f84 = f82.y;
    float f85 = f82.z;
    float f86 = f81.x;
    float f87 = f81.y;
    float f88 = f81.z;
    vec3 f89 = (((((((f75 - (f70 * f74)) * CB0[10].xyz) * f63) + ((f29.xyz * (f29.w * 120.0)).xyz * 1.0)) + ((f75 - (f78 * f74)) * (((((((CB0[35].xyz * f83) + (CB0[37].xyz * f84)) + (CB0[39].xyz * f85)) + (CB0[36].xyz * f86)) + (CB0[38].xyz * f87)) + (CB0[40].xyz * f88)) + (((((((CB0[29].xyz * f83) + (CB0[31].xyz * f84)) + (CB0[33].xyz * f85)) + (CB0[30].xyz * f86)) + (CB0[32].xyz * f87)) + (CB0[34].xyz * f88)) * f31)))) + (CB0[27].xyz + (CB0[28].xyz * f31))) * f51) + (((f70 * (((f71 + (f71 * f71)) / (((f72 * f72) * ((f66 * 3.0) + 0.5)) * ((f65 * 0.75) + 0.25))) * f63)) * CB0[10].xyz) + ((mix(f58, textureLod(PrefilteredEnvTexture, f56, f55).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f54.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f31)) * f78) * f52));
    float f90 = f9.w;
    vec4 f91 = vec4(f89.x, f89.y, f89.z, vec4(0.0).w);
    f91.w = f90;
    float f92 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f93 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f92) * 5.0).xyz;
    bvec3 f94 = bvec3(CB0[13].w != 0.0);
    vec3 f95 = sqrt(clamp(mix(vec3(f94.x ? CB0[14].xyz.x : f93.x, f94.y ? CB0[14].xyz.y : f93.y, f94.z ? CB0[14].xyz.z : f93.z), f91.xyz, vec3(f92)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f96 = vec4(f95.x, f95.y, f95.z, f91.w);
    f96.w = f90;
    _entryPointOutput = f96;
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrefilteredEnvBlendTargetTexture=s2
//$$PrecomputedBRDFTexture=s11
//$$DiffuseMapTexture=s3
//$$Tc2DiffuseMapTexture=s0
//$$NormalMapTexture=s4
//$$SpecularMapTexture=s5
