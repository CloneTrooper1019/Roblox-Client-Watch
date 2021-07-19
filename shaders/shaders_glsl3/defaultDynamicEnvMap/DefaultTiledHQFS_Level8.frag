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
    float f0 = length(VARYING4.xyz);
    vec3 f1 = VARYING4.xyz / vec3(f0);
    float f2 = clamp(1.0 - (VARYING4.w * CB0[23].y), 0.0, 1.0);
    vec2 f3 = VARYING0 * CB2[0].x;
    vec4 f4 = texture(DiffuseMapTexture, f3);
    vec4 f5 = texture(NormalMapTexture, f3);
    vec2 f6 = f5.wy * 2.0;
    vec2 f7 = f6 - vec2(1.0);
    float f8 = sqrt(clamp(1.0 + dot(vec2(1.0) - f6, f7), 0.0, 1.0));
    vec4 f9 = texture(NormalDetailMapTexture, f3 * CB2[0].w);
    vec2 f10 = (vec3(f7, f8).xy + (vec3((f9.wy * 2.0) - vec2(1.0), 0.0).xy * CB2[1].x)).xy * f2;
    float f11 = f10.x;
    vec4 f12 = texture(SpecularMapTexture, f3);
    float f13 = gl_FrontFacing ? 1.0 : (-1.0);
    vec3 f14 = VARYING6.xyz * f13;
    vec3 f15 = VARYING5.xyz * f13;
    vec3 f16 = normalize(((f14 * f11) + (cross(f15, f14) * f10.y)) + (f15 * f8));
    vec3 f17 = -CB0[11].xyz;
    float f18 = dot(f16, f17);
    vec3 f19 = vec4((mix(vec3(1.0), VARYING2.xyz, vec3(clamp(f4.w + CB2[2].w, 0.0, 1.0))) * f4.xyz) * (1.0 + (f11 * CB2[0].z)), VARYING2.w).xyz;
    vec3 f20 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f21 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f22 = VARYING3.yzx - (VARYING3.yzx * f21);
    vec4 f23 = texture(LightMapTexture, f22);
    vec4 f24 = texture(LightGridSkylightTexture, f22);
    vec4 f25 = vec4(clamp(f21, 0.0, 1.0));
    vec4 f26 = mix(f23, vec4(0.0), f25);
    vec4 f27 = mix(f24, vec4(1.0), f25);
    float f28 = f27.x;
    float f29 = f27.y;
    vec3 f30 = f20 - CB0[41].xyz;
    vec3 f31 = f20 - CB0[42].xyz;
    vec3 f32 = f20 - CB0[43].xyz;
    vec4 f33 = vec4(f20, 1.0) * mat4(CB8[((dot(f30, f30) < CB0[41].w) ? 0 : ((dot(f31, f31) < CB0[42].w) ? 1 : ((dot(f32, f32) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f30, f30) < CB0[41].w) ? 0 : ((dot(f31, f31) < CB0[42].w) ? 1 : ((dot(f32, f32) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f30, f30) < CB0[41].w) ? 0 : ((dot(f31, f31) < CB0[42].w) ? 1 : ((dot(f32, f32) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f30, f30) < CB0[41].w) ? 0 : ((dot(f31, f31) < CB0[42].w) ? 1 : ((dot(f32, f32) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f34 = textureLod(ShadowAtlasTexture, f33.xy, 0.0);
    vec2 f35 = vec2(0.0);
    f35.x = CB0[46].z;
    vec2 f36 = f35;
    f36.y = CB0[46].w;
    float f37 = (2.0 * f33.z) - 1.0;
    float f38 = exp(CB0[46].z * f37);
    float f39 = -exp((-CB0[46].w) * f37);
    vec2 f40 = (f36 * CB0[47].y) * vec2(f38, f39);
    vec2 f41 = f40 * f40;
    float f42 = f34.x;
    float f43 = max(f34.y - (f42 * f42), f41.x);
    float f44 = f38 - f42;
    float f45 = f34.z;
    float f46 = max(f34.w - (f45 * f45), f41.y);
    float f47 = f39 - f45;
    vec3 f48 = (f19 * f19).xyz;
    float f49 = CB0[26].w * f2;
    float f50 = max(f12.y, 0.04500000178813934326171875);
    vec3 f51 = reflect(-f1, f16);
    float f52 = f50 * 5.0;
    vec3 f53 = vec4(f51, f52).xyz;
    vec3 f54 = textureLod(PrefilteredEnvIndoorTexture, f53, f52).xyz;
    vec3 f55;
    if (CB0[27].w == 0.0)
    {
        f55 = f54;
    }
    else
    {
        f55 = mix(f54, textureLod(PrefilteredEnvBlendTargetTexture, f53, f52).xyz, vec3(CB0[27].w));
    }
    vec4 f56 = texture(PrecomputedBRDFTexture, vec2(f50, max(9.9999997473787516355514526367188e-05, dot(f16, f1))));
    float f57 = f12.x * f49;
    vec3 f58 = mix(vec3(0.039999999105930328369140625), f48, vec3(f57));
    vec3 f59 = normalize(f17 + f1);
    float f60 = clamp(f18 * (((f18 * CB0[47].x) > 0.0) ? mix(min((f38 <= f42) ? 1.0 : clamp(((f43 / (f43 + (f44 * f44))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f39 <= f45) ? 1.0 : clamp(((f46 / (f46 + (f47 * f47))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f29, clamp((length(f20 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f29), 0.0, 1.0);
    float f61 = f50 * f50;
    float f62 = max(0.001000000047497451305389404296875, dot(f16, f59));
    float f63 = dot(f17, f59);
    float f64 = 1.0 - f63;
    float f65 = f64 * f64;
    float f66 = (f65 * f65) * f64;
    vec3 f67 = vec3(f66) + (f58 * (1.0 - f66));
    float f68 = f61 * f61;
    float f69 = (((f62 * f68) - f62) * f62) + 1.0;
    float f70 = 1.0 - f57;
    float f71 = f49 * f70;
    vec3 f72 = vec3(f70);
    float f73 = f56.x;
    float f74 = f56.y;
    vec3 f75 = ((f58 * f73) + vec3(f74)) / vec3(f73 + f74);
    vec3 f76 = f16 * f16;
    bvec3 f77 = lessThan(f16, vec3(0.0));
    vec3 f78 = vec3(f77.x ? f76.x : vec3(0.0).x, f77.y ? f76.y : vec3(0.0).y, f77.z ? f76.z : vec3(0.0).z);
    vec3 f79 = f76 - f78;
    float f80 = f79.x;
    float f81 = f79.y;
    float f82 = f79.z;
    float f83 = f78.x;
    float f84 = f78.y;
    float f85 = f78.z;
    vec3 f86 = (((((((f72 - (f67 * f71)) * CB0[10].xyz) * f60) + ((f26.xyz * (f26.w * 120.0)).xyz * 1.0)) + ((f72 - (f75 * f71)) * (((((((CB0[35].xyz * f80) + (CB0[37].xyz * f81)) + (CB0[39].xyz * f82)) + (CB0[36].xyz * f83)) + (CB0[38].xyz * f84)) + (CB0[40].xyz * f85)) + (((((((CB0[29].xyz * f80) + (CB0[31].xyz * f81)) + (CB0[33].xyz * f82)) + (CB0[30].xyz * f83)) + (CB0[32].xyz * f84)) + (CB0[34].xyz * f85)) * f28)))) + (CB0[27].xyz + (CB0[28].xyz * f28))) * f48) + (((f67 * (((f68 + (f68 * f68)) / (((f69 * f69) * ((f63 * 3.0) + 0.5)) * ((f62 * 0.75) + 0.25))) * f60)) * CB0[10].xyz) + ((mix(f55, textureLod(PrefilteredEnvTexture, f53, f52).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f51.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f28)) * f75) * f49));
    vec4 f87 = vec4(f86.x, f86.y, f86.z, vec4(0.0).w);
    f87.w = VARYING2.w;
    float f88 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f89 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f88) * 5.0).xyz;
    bvec3 f90 = bvec3(CB0[13].w != 0.0);
    vec3 f91 = sqrt(clamp(mix(vec3(f90.x ? CB0[14].xyz.x : f89.x, f90.y ? CB0[14].xyz.y : f89.y, f90.z ? CB0[14].xyz.z : f89.z), f87.xyz, vec3(f88)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f92 = vec4(f91.x, f91.y, f91.z, f87.w);
    f92.w = VARYING2.w;
    _entryPointOutput = f92;
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
