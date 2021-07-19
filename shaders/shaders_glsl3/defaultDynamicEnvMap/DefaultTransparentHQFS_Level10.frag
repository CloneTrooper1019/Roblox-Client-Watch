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
uniform samplerCube PrefilteredEnvBlendTargetTexture;
uniform sampler2D PrecomputedBRDFTexture;
uniform sampler2D Tc2DiffuseMapTexture;
uniform sampler2D DiffuseMapTexture;

in vec2 VARYING0;
in vec2 VARYING1;
in vec4 VARYING2;
in vec4 VARYING3;
in vec4 VARYING4;
in vec4 VARYING5;
in vec4 VARYING6;
out vec4 _entryPointOutput;

void main()
{
    float f0 = length(VARYING4.xyz);
    vec3 f1 = VARYING4.xyz / vec3(f0);
    vec4 f2 = texture(Tc2DiffuseMapTexture, VARYING1);
    vec4 f3 = texture(DiffuseMapTexture, VARYING0);
    vec4 f4 = mix(f3, f2, vec4(f2.w)) * VARYING2;
    vec3 f5 = normalize(VARYING5.xyz) * (gl_FrontFacing ? 1.0 : (-1.0));
    vec3 f6 = -CB0[11].xyz;
    float f7 = dot(f5, f6);
    vec3 f8 = f4.xyz;
    vec3 f9 = VARYING6.xyz - (CB0[11].xyz * VARYING3.w);
    float f10 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f11 = VARYING3.yzx - (VARYING3.yzx * f10);
    vec4 f12 = texture(LightMapTexture, f11);
    vec4 f13 = texture(LightGridSkylightTexture, f11);
    vec4 f14 = vec4(clamp(f10, 0.0, 1.0));
    vec4 f15 = mix(f12, vec4(0.0), f14);
    vec4 f16 = mix(f13, vec4(1.0), f14);
    float f17 = f16.x;
    float f18 = f16.y;
    vec3 f19 = f9 - CB0[41].xyz;
    vec3 f20 = f9 - CB0[42].xyz;
    vec3 f21 = f9 - CB0[43].xyz;
    vec4 f22 = vec4(f9, 1.0) * mat4(CB8[((dot(f19, f19) < CB0[41].w) ? 0 : ((dot(f20, f20) < CB0[42].w) ? 1 : ((dot(f21, f21) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f19, f19) < CB0[41].w) ? 0 : ((dot(f20, f20) < CB0[42].w) ? 1 : ((dot(f21, f21) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f19, f19) < CB0[41].w) ? 0 : ((dot(f20, f20) < CB0[42].w) ? 1 : ((dot(f21, f21) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f19, f19) < CB0[41].w) ? 0 : ((dot(f20, f20) < CB0[42].w) ? 1 : ((dot(f21, f21) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f23 = textureLod(ShadowAtlasTexture, f22.xy, 0.0);
    vec2 f24 = vec2(0.0);
    f24.x = CB0[46].z;
    vec2 f25 = f24;
    f25.y = CB0[46].w;
    float f26 = (2.0 * f22.z) - 1.0;
    float f27 = exp(CB0[46].z * f26);
    float f28 = -exp((-CB0[46].w) * f26);
    vec2 f29 = (f25 * CB0[47].y) * vec2(f27, f28);
    vec2 f30 = f29 * f29;
    float f31 = f23.x;
    float f32 = max(f23.y - (f31 * f31), f30.x);
    float f33 = f27 - f31;
    float f34 = f23.z;
    float f35 = max(f23.w - (f34 * f34), f30.y);
    float f36 = f28 - f34;
    vec3 f37 = (f8 * f8).xyz;
    float f38 = CB0[26].w * clamp(1.0 - (VARYING4.w * CB0[23].y), 0.0, 1.0);
    float f39 = max(VARYING5.w, 0.04500000178813934326171875);
    vec3 f40 = reflect(-f1, f5);
    float f41 = f39 * 5.0;
    vec3 f42 = vec4(f40, f41).xyz;
    vec3 f43 = textureLod(PrefilteredEnvIndoorTexture, f42, f41).xyz;
    vec3 f44;
    if (CB0[27].w == 0.0)
    {
        f44 = f43;
    }
    else
    {
        f44 = mix(f43, textureLod(PrefilteredEnvBlendTargetTexture, f42, f41).xyz, vec3(CB0[27].w));
    }
    vec4 f45 = texture(PrecomputedBRDFTexture, vec2(f39, max(9.9999997473787516355514526367188e-05, dot(f5, f1))));
    float f46 = VARYING6.w * f38;
    vec3 f47 = mix(vec3(0.039999999105930328369140625), f37, vec3(f46));
    vec3 f48 = normalize(f6 + f1);
    float f49 = clamp(f7 * (((f7 * CB0[47].x) > 0.0) ? mix(min((f27 <= f31) ? 1.0 : clamp(((f32 / (f32 + (f33 * f33))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f28 <= f34) ? 1.0 : clamp(((f35 / (f35 + (f36 * f36))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f18, clamp((length(f9 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f18), 0.0, 1.0);
    float f50 = f39 * f39;
    float f51 = max(0.001000000047497451305389404296875, dot(f5, f48));
    float f52 = dot(f6, f48);
    float f53 = 1.0 - f52;
    float f54 = f53 * f53;
    float f55 = (f54 * f54) * f53;
    vec3 f56 = vec3(f55) + (f47 * (1.0 - f55));
    float f57 = f50 * f50;
    float f58 = (((f51 * f57) - f51) * f51) + 1.0;
    float f59 = 1.0 - f46;
    float f60 = f38 * f59;
    vec3 f61 = vec3(f59);
    float f62 = f45.x;
    float f63 = f45.y;
    vec3 f64 = ((f47 * f62) + vec3(f63)) / vec3(f62 + f63);
    vec3 f65 = f5 * f5;
    bvec3 f66 = lessThan(f5, vec3(0.0));
    vec3 f67 = vec3(f66.x ? f65.x : vec3(0.0).x, f66.y ? f65.y : vec3(0.0).y, f66.z ? f65.z : vec3(0.0).z);
    vec3 f68 = f65 - f67;
    float f69 = f68.x;
    float f70 = f68.y;
    float f71 = f68.z;
    float f72 = f67.x;
    float f73 = f67.y;
    float f74 = f67.z;
    vec3 f75 = (((((((f61 - (f56 * f60)) * CB0[10].xyz) * f49) + ((f15.xyz * (f15.w * 120.0)).xyz * 1.0)) + ((f61 - (f64 * f60)) * (((((((CB0[35].xyz * f69) + (CB0[37].xyz * f70)) + (CB0[39].xyz * f71)) + (CB0[36].xyz * f72)) + (CB0[38].xyz * f73)) + (CB0[40].xyz * f74)) + (((((((CB0[29].xyz * f69) + (CB0[31].xyz * f70)) + (CB0[33].xyz * f71)) + (CB0[30].xyz * f72)) + (CB0[32].xyz * f73)) + (CB0[34].xyz * f74)) * f17)))) + (CB0[27].xyz + (CB0[28].xyz * f17))) * f37) + (((f56 * (((f57 + (f57 * f57)) / (((f58 * f58) * ((f52 * 3.0) + 0.5)) * ((f51 * 0.75) + 0.25))) * f49)) * CB0[10].xyz) + ((mix(f44, textureLod(PrefilteredEnvTexture, f42, f41).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f40.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f17)) * f64) * f38));
    float f76 = f4.w;
    vec4 f77 = vec4(f75.x, f75.y, f75.z, vec4(0.0).w);
    f77.w = f76;
    float f78 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f79 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f78) * 5.0).xyz;
    bvec3 f80 = bvec3(CB0[13].w != 0.0);
    vec3 f81 = sqrt(clamp(mix(vec3(f80.x ? CB0[14].xyz.x : f79.x, f80.y ? CB0[14].xyz.y : f79.y, f80.z ? CB0[14].xyz.z : f79.z), f77.xyz, vec3(f78)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f82 = vec4(f81.x, f81.y, f81.z, f77.w);
    f82.w = f76;
    _entryPointOutput = f82;
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrefilteredEnvBlendTargetTexture=s2
//$$PrecomputedBRDFTexture=s11
//$$Tc2DiffuseMapTexture=s0
//$$DiffuseMapTexture=s3
