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
uniform sampler2D WangTileMapTexture;
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
    vec2 f4 = f3 * 4.0;
    vec4 f5 = texture(WangTileMapTexture, f4 * vec2(0.0078125));
    vec2 f6 = f4 * 0.25;
    vec2 f7 = dFdx(f6);
    vec2 f8 = dFdy(f6);
    vec4 f9 = vec4(f7, f8);
    vec2 f10 = (f5.xy * 0.99609375) + (fract(f4) * 0.25);
    vec2 f11 = f9.xy;
    vec2 f12 = f9.zw;
    vec4 f13 = textureGrad(DiffuseMapTexture, f10, f11, f12);
    vec2 f14 = textureGrad(NormalMapTexture, f10, f11, f12).wy * 2.0;
    vec2 f15 = f14 - vec2(1.0);
    float f16 = sqrt(clamp(1.0 + dot(vec2(1.0) - f14, f15), 0.0, 1.0));
    vec4 f17 = texture(NormalDetailMapTexture, f3 * CB2[0].w);
    vec2 f18 = (vec3(f15, f16).xy + (vec3((f17.wy * 2.0) - vec2(1.0), 0.0).xy * CB2[1].x)).xy * f2;
    float f19 = f18.x;
    vec4 f20 = textureGrad(SpecularMapTexture, f10, f11, f12);
    float f21 = gl_FrontFacing ? 1.0 : (-1.0);
    vec3 f22 = VARYING6.xyz * f21;
    vec3 f23 = VARYING5.xyz * f21;
    vec3 f24 = normalize(((f22 * f19) + (cross(f23, f22) * f18.y)) + (f23 * f16));
    vec3 f25 = -CB0[11].xyz;
    float f26 = dot(f24, f25);
    vec3 f27 = vec4((mix(vec3(1.0), VARYING2.xyz, vec3(clamp(f13.w + CB2[2].w, 0.0, 1.0))) * f13.xyz) * (1.0 + (f19 * CB2[0].z)), VARYING2.w).xyz;
    vec3 f28 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f29 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f30 = VARYING3.yzx - (VARYING3.yzx * f29);
    vec4 f31 = texture(LightMapTexture, f30);
    vec4 f32 = texture(LightGridSkylightTexture, f30);
    vec4 f33 = vec4(clamp(f29, 0.0, 1.0));
    vec4 f34 = mix(f31, vec4(0.0), f33);
    vec4 f35 = mix(f32, vec4(1.0), f33);
    float f36 = f35.x;
    float f37 = f35.y;
    vec3 f38 = f28 - CB0[41].xyz;
    vec3 f39 = f28 - CB0[42].xyz;
    vec3 f40 = f28 - CB0[43].xyz;
    vec4 f41 = vec4(f28, 1.0) * mat4(CB8[((dot(f38, f38) < CB0[41].w) ? 0 : ((dot(f39, f39) < CB0[42].w) ? 1 : ((dot(f40, f40) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f38, f38) < CB0[41].w) ? 0 : ((dot(f39, f39) < CB0[42].w) ? 1 : ((dot(f40, f40) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f38, f38) < CB0[41].w) ? 0 : ((dot(f39, f39) < CB0[42].w) ? 1 : ((dot(f40, f40) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f38, f38) < CB0[41].w) ? 0 : ((dot(f39, f39) < CB0[42].w) ? 1 : ((dot(f40, f40) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f42 = textureLod(ShadowAtlasTexture, f41.xy, 0.0);
    vec2 f43 = vec2(0.0);
    f43.x = CB0[46].z;
    vec2 f44 = f43;
    f44.y = CB0[46].w;
    float f45 = (2.0 * f41.z) - 1.0;
    float f46 = exp(CB0[46].z * f45);
    float f47 = -exp((-CB0[46].w) * f45);
    vec2 f48 = (f44 * CB0[47].y) * vec2(f46, f47);
    vec2 f49 = f48 * f48;
    float f50 = f42.x;
    float f51 = max(f42.y - (f50 * f50), f49.x);
    float f52 = f46 - f50;
    float f53 = f42.z;
    float f54 = max(f42.w - (f53 * f53), f49.y);
    float f55 = f47 - f53;
    vec3 f56 = (f27 * f27).xyz;
    float f57 = CB0[26].w * f2;
    float f58 = max(f20.y, 0.04500000178813934326171875);
    vec3 f59 = reflect(-f1, f24);
    float f60 = f58 * 5.0;
    vec3 f61 = vec4(f59, f60).xyz;
    vec3 f62 = textureLod(PrefilteredEnvIndoorTexture, f61, f60).xyz;
    vec3 f63;
    if (CB0[27].w == 0.0)
    {
        f63 = f62;
    }
    else
    {
        f63 = mix(f62, textureLod(PrefilteredEnvBlendTargetTexture, f61, f60).xyz, vec3(CB0[27].w));
    }
    vec4 f64 = texture(PrecomputedBRDFTexture, vec2(f58, max(9.9999997473787516355514526367188e-05, dot(f24, f1))));
    float f65 = f20.x * f57;
    vec3 f66 = mix(vec3(0.039999999105930328369140625), f56, vec3(f65));
    vec3 f67 = normalize(f25 + f1);
    float f68 = clamp(f26 * (((f26 * CB0[47].x) > 0.0) ? mix(min((f46 <= f50) ? 1.0 : clamp(((f51 / (f51 + (f52 * f52))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f47 <= f53) ? 1.0 : clamp(((f54 / (f54 + (f55 * f55))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f37, clamp((length(f28 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f37), 0.0, 1.0);
    float f69 = f58 * f58;
    float f70 = max(0.001000000047497451305389404296875, dot(f24, f67));
    float f71 = dot(f25, f67);
    float f72 = 1.0 - f71;
    float f73 = f72 * f72;
    float f74 = (f73 * f73) * f72;
    vec3 f75 = vec3(f74) + (f66 * (1.0 - f74));
    float f76 = f69 * f69;
    float f77 = (((f70 * f76) - f70) * f70) + 1.0;
    float f78 = 1.0 - f65;
    float f79 = f57 * f78;
    vec3 f80 = vec3(f78);
    float f81 = f64.x;
    float f82 = f64.y;
    vec3 f83 = ((f66 * f81) + vec3(f82)) / vec3(f81 + f82);
    vec3 f84 = f24 * f24;
    bvec3 f85 = lessThan(f24, vec3(0.0));
    vec3 f86 = vec3(f85.x ? f84.x : vec3(0.0).x, f85.y ? f84.y : vec3(0.0).y, f85.z ? f84.z : vec3(0.0).z);
    vec3 f87 = f84 - f86;
    float f88 = f87.x;
    float f89 = f87.y;
    float f90 = f87.z;
    float f91 = f86.x;
    float f92 = f86.y;
    float f93 = f86.z;
    vec3 f94 = (((((((f80 - (f75 * f79)) * CB0[10].xyz) * f68) + ((f34.xyz * (f34.w * 120.0)).xyz * 1.0)) + ((f80 - (f83 * f79)) * (((((((CB0[35].xyz * f88) + (CB0[37].xyz * f89)) + (CB0[39].xyz * f90)) + (CB0[36].xyz * f91)) + (CB0[38].xyz * f92)) + (CB0[40].xyz * f93)) + (((((((CB0[29].xyz * f88) + (CB0[31].xyz * f89)) + (CB0[33].xyz * f90)) + (CB0[30].xyz * f91)) + (CB0[32].xyz * f92)) + (CB0[34].xyz * f93)) * f36)))) + (CB0[27].xyz + (CB0[28].xyz * f36))) * f56) + (((f75 * (((f76 + (f76 * f76)) / (((f77 * f77) * ((f71 * 3.0) + 0.5)) * ((f70 * 0.75) + 0.25))) * f68)) * CB0[10].xyz) + ((mix(f63, textureLod(PrefilteredEnvTexture, f61, f60).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f59.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f36)) * f83) * f57));
    vec4 f95 = vec4(f94.x, f94.y, f94.z, vec4(0.0).w);
    f95.w = VARYING2.w;
    float f96 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f97 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f96) * 5.0).xyz;
    bvec3 f98 = bvec3(CB0[13].w != 0.0);
    vec3 f99 = sqrt(clamp(mix(vec3(f98.x ? CB0[14].xyz.x : f97.x, f98.y ? CB0[14].xyz.y : f97.y, f98.z ? CB0[14].xyz.z : f97.z), f95.xyz, vec3(f96)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f100 = vec4(f99.x, f99.y, f99.z, f95.w);
    f100.w = VARYING2.w;
    _entryPointOutput = f100;
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrefilteredEnvBlendTargetTexture=s2
//$$PrecomputedBRDFTexture=s11
//$$WangTileMapTexture=s9
//$$DiffuseMapTexture=s3
//$$NormalMapTexture=s4
//$$NormalDetailMapTexture=s8
//$$SpecularMapTexture=s5
