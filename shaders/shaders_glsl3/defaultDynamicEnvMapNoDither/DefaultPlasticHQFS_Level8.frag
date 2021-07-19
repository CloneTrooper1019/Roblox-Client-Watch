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
    vec4 f4 = texture(DiffuseMapTexture, f2);
    vec4 f5 = texture(NormalMapTexture, f2);
    vec2 f6 = f5.wy * 2.0;
    vec2 f7 = f6 - vec2(1.0);
    float f8 = sqrt(clamp(1.0 + dot(vec2(1.0) - f6, f7), 0.0, 1.0));
    vec4 f9 = texture(NormalDetailMapTexture, VARYING0 * CB2[0].x);
    vec2 f10 = ((vec3(f7, f8).xy + (vec3((f9.wy * 2.0) - vec2(1.0), 0.0).xy * (clamp(VARYING2.w - 0.5, 0.0, 1.0) * clamp(1.0 - (2.0 * VARYING7.w), 0.0, 1.0)))).xy * f3).xy * CB2[3].w;
    float f11 = gl_FrontFacing ? 1.0 : (-1.0);
    vec3 f12 = VARYING6.xyz * f11;
    vec3 f13 = VARYING5.xyz * f11;
    vec3 f14 = normalize(((f12 * f10.x) + (cross(f13, f12) * f10.y)) + (f13 * f8));
    vec3 f15 = -CB0[11].xyz;
    float f16 = dot(f14, f15);
    vec3 f17 = vec4(VARYING2.xyz * (f4.x * 2.0), VARYING2.w).xyz;
    vec3 f18 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f19 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f20 = VARYING3.yzx - (VARYING3.yzx * f19);
    vec4 f21 = texture(LightMapTexture, f20);
    vec4 f22 = texture(LightGridSkylightTexture, f20);
    vec4 f23 = vec4(clamp(f19, 0.0, 1.0));
    vec4 f24 = mix(f21, vec4(0.0), f23);
    vec4 f25 = mix(f22, vec4(1.0), f23);
    float f26 = f25.x;
    float f27 = f25.y;
    vec3 f28 = f18 - CB0[41].xyz;
    vec3 f29 = f18 - CB0[42].xyz;
    vec3 f30 = f18 - CB0[43].xyz;
    vec4 f31 = vec4(f18, 1.0) * mat4(CB8[((dot(f28, f28) < CB0[41].w) ? 0 : ((dot(f29, f29) < CB0[42].w) ? 1 : ((dot(f30, f30) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f28, f28) < CB0[41].w) ? 0 : ((dot(f29, f29) < CB0[42].w) ? 1 : ((dot(f30, f30) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f28, f28) < CB0[41].w) ? 0 : ((dot(f29, f29) < CB0[42].w) ? 1 : ((dot(f30, f30) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f28, f28) < CB0[41].w) ? 0 : ((dot(f29, f29) < CB0[42].w) ? 1 : ((dot(f30, f30) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f32 = textureLod(ShadowAtlasTexture, f31.xy, 0.0);
    vec2 f33 = vec2(0.0);
    f33.x = CB0[46].z;
    vec2 f34 = f33;
    f34.y = CB0[46].w;
    float f35 = (2.0 * f31.z) - 1.0;
    float f36 = exp(CB0[46].z * f35);
    float f37 = -exp((-CB0[46].w) * f35);
    vec2 f38 = (f34 * CB0[47].y) * vec2(f36, f37);
    vec2 f39 = f38 * f38;
    float f40 = f32.x;
    float f41 = max(f32.y - (f40 * f40), f39.x);
    float f42 = f36 - f40;
    float f43 = f32.z;
    float f44 = max(f32.w - (f43 * f43), f39.y);
    float f45 = f37 - f43;
    float f46 = CB0[26].w * f3;
    float f47 = max(CB2[0].y, 0.04500000178813934326171875);
    vec3 f48 = reflect(-f1, f14);
    float f49 = (VARYING7.w != 0.0) ? 0.0 : (f47 * 5.0);
    vec3 f50 = vec4(f48, f49).xyz;
    vec3 f51 = textureLod(PrefilteredEnvTexture, f50, f49).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f48.y * 1.58823525905609130859375, 0.0, 1.0)));
    vec3 f52 = textureLod(PrefilteredEnvIndoorTexture, f50, f49).xyz;
    vec3 f53;
    if (CB0[27].w == 0.0)
    {
        f53 = f52;
    }
    else
    {
        f53 = mix(f52, textureLod(PrefilteredEnvBlendTargetTexture, f50, f49).xyz, vec3(CB0[27].w));
    }
    vec4 f54 = texture(PrecomputedBRDFTexture, vec2(f47, max(9.9999997473787516355514526367188e-05, dot(f14, f1))));
    vec3 f55 = normalize(f15 + f1);
    float f56 = clamp(f16 * (((f16 * CB0[47].x) > 0.0) ? mix(min((f36 <= f40) ? 1.0 : clamp(((f41 / (f41 + (f42 * f42))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f37 <= f43) ? 1.0 : clamp(((f44 / (f44 + (f45 * f45))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f27, clamp((length(f18 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f27), 0.0, 1.0);
    float f57 = f47 * f47;
    float f58 = max(0.001000000047497451305389404296875, dot(f14, f55));
    float f59 = dot(f15, f55);
    float f60 = 1.0 - f59;
    float f61 = f60 * f60;
    float f62 = (f61 * f61) * f60;
    vec3 f63 = vec3(f62) + (vec3(0.039999999105930328369140625) * (1.0 - f62));
    float f64 = f57 * f57;
    float f65 = (((f58 * f64) - f58) * f58) + 1.0;
    float f66 = f54.x;
    float f67 = f54.y;
    vec3 f68 = ((vec3(0.039999999105930328369140625) * f66) + vec3(f67)) / vec3(f66 + f67);
    vec3 f69 = f14 * f14;
    bvec3 f70 = lessThan(f14, vec3(0.0));
    vec3 f71 = vec3(f70.x ? f69.x : vec3(0.0).x, f70.y ? f69.y : vec3(0.0).y, f70.z ? f69.z : vec3(0.0).z);
    vec3 f72 = f69 - f71;
    float f73 = f72.x;
    float f74 = f72.y;
    float f75 = f72.z;
    float f76 = f71.x;
    float f77 = f71.y;
    float f78 = f71.z;
    vec3 f79 = (((((((vec3(1.0) - (f63 * f46)) * CB0[10].xyz) * f56) + ((f24.xyz * (f24.w * 120.0)).xyz * 1.0)) + ((vec3(1.0) - (f68 * f46)) * (((((((CB0[35].xyz * f73) + (CB0[37].xyz * f74)) + (CB0[39].xyz * f75)) + (CB0[36].xyz * f76)) + (CB0[38].xyz * f77)) + (CB0[40].xyz * f78)) + (((((((CB0[29].xyz * f73) + (CB0[31].xyz * f74)) + (CB0[33].xyz * f75)) + (CB0[30].xyz * f76)) + (CB0[32].xyz * f77)) + (CB0[34].xyz * f78)) * f26)))) + (CB0[27].xyz + (CB0[28].xyz * f26))) * mix((f17 * f17).xyz, f51, vec3(VARYING7.w))) + (((f63 * (((f64 + (f64 * f64)) / (((f65 * f65) * ((f59 * 3.0) + 0.5)) * ((f58 * 0.75) + 0.25))) * f56)) * CB0[10].xyz) + ((mix(f53, f51, vec3(f26)) * f68) * f46));
    vec4 f80 = vec4(f79.x, f79.y, f79.z, vec4(0.0).w);
    f80.w = VARYING2.w;
    float f81 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f82 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f81) * 5.0).xyz;
    bvec3 f83 = bvec3(CB0[13].w != 0.0);
    vec3 f84 = sqrt(clamp(mix(vec3(f83.x ? CB0[14].xyz.x : f82.x, f83.y ? CB0[14].xyz.y : f82.y, f83.z ? CB0[14].xyz.z : f82.z), f80.xyz, vec3(f81)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f85 = vec4(f84.x, f84.y, f84.z, f80.w);
    f85.w = VARYING2.w;
    _entryPointOutput = f85;
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
