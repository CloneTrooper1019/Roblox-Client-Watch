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
    if (f5 < (0.5 * CB0[47].z))
    {
        discard;
    }
    vec4 f6 = vec4(mix(vec4(f3.xyz * VARYING2.xyz, f5).xyz, f4.xyz, vec3(f5)), f5);
    vec4 f7 = vec4(f4.xyz, f5 * f5);
    bvec4 f8 = bvec4(CB3[0].x != 0.0);
    vec4 f9 = vec4(f8.x ? f6.x : f7.x, f8.y ? f6.y : f7.y, f8.z ? f6.z : f7.z, f8.w ? f6.w : f7.w);
    vec2 f10 = texture(NormalMapTexture, VARYING1).wy * 2.0;
    vec2 f11 = f10 - vec2(1.0);
    float f12 = sqrt(clamp(1.0 + dot(vec2(1.0) - f10, f11), 0.0, 1.0));
    vec2 f13 = vec3(f11, f12).xy * f2;
    vec4 f14 = texture(SpecularMapTexture, VARYING1);
    float f15 = gl_FrontFacing ? 1.0 : (-1.0);
    vec3 f16 = VARYING6.xyz * f15;
    vec3 f17 = VARYING5.xyz * f15;
    vec3 f18 = normalize(((f16 * f13.x) + ((cross(f17, f16) * VARYING6.w) * f13.y)) + (f17 * f12));
    vec3 f19 = -CB0[11].xyz;
    float f20 = dot(f18, f19);
    vec3 f21 = f9.xyz;
    vec3 f22 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f23 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f24 = VARYING3.yzx - (VARYING3.yzx * f23);
    vec4 f25 = vec4(clamp(f23, 0.0, 1.0));
    vec4 f26 = mix(texture(LightMapTexture, f24), vec4(0.0), f25);
    vec4 f27 = mix(texture(LightGridSkylightTexture, f24), vec4(1.0), f25);
    vec3 f28 = (f26.xyz * (f26.w * 120.0)).xyz;
    float f29 = f27.x;
    float f30 = f27.y;
    vec3 f31 = f22 - CB0[41].xyz;
    vec3 f32 = f22 - CB0[42].xyz;
    vec3 f33 = f22 - CB0[43].xyz;
    vec4 f34 = vec4(f22, 1.0) * mat4(CB8[((dot(f31, f31) < CB0[41].w) ? 0 : ((dot(f32, f32) < CB0[42].w) ? 1 : ((dot(f33, f33) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f31, f31) < CB0[41].w) ? 0 : ((dot(f32, f32) < CB0[42].w) ? 1 : ((dot(f33, f33) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f31, f31) < CB0[41].w) ? 0 : ((dot(f32, f32) < CB0[42].w) ? 1 : ((dot(f33, f33) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f31, f31) < CB0[41].w) ? 0 : ((dot(f32, f32) < CB0[42].w) ? 1 : ((dot(f33, f33) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f35 = textureLod(ShadowAtlasTexture, f34.xy, 0.0);
    vec2 f36 = vec2(0.0);
    f36.x = CB0[46].z;
    vec2 f37 = f36;
    f37.y = CB0[46].w;
    float f38 = (2.0 * f34.z) - 1.0;
    float f39 = exp(CB0[46].z * f38);
    float f40 = -exp((-CB0[46].w) * f38);
    vec2 f41 = (f37 * CB0[47].y) * vec2(f39, f40);
    vec2 f42 = f41 * f41;
    float f43 = f35.x;
    float f44 = max(f35.y - (f43 * f43), f42.x);
    float f45 = f39 - f43;
    float f46 = f35.z;
    float f47 = max(f35.w - (f46 * f46), f42.y);
    float f48 = f40 - f46;
    vec3 f49 = (f21 * f21).xyz;
    float f50 = CB0[26].w * f2;
    float f51 = max(f14.y, 0.04500000178813934326171875);
    vec3 f52 = reflect(-f1, f18);
    float f53 = f51 * 5.0;
    vec3 f54 = vec4(f52, f53).xyz;
    vec4 f55 = texture(PrecomputedBRDFTexture, vec2(f51, max(9.9999997473787516355514526367188e-05, dot(f18, f1))));
    float f56 = f14.x * f50;
    vec3 f57 = mix(vec3(0.039999999105930328369140625), f49, vec3(f56));
    vec3 f58 = normalize(f19 + f1);
    float f59 = clamp(f20 * (((f20 * CB0[47].x) > 0.0) ? mix(min((f39 <= f43) ? 1.0 : clamp(((f44 / (f44 + (f45 * f45))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f40 <= f46) ? 1.0 : clamp(((f47 / (f47 + (f48 * f48))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f30, clamp((length(f22 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f30), 0.0, 1.0);
    float f60 = f51 * f51;
    float f61 = max(0.001000000047497451305389404296875, dot(f18, f58));
    float f62 = dot(f19, f58);
    float f63 = 1.0 - f62;
    float f64 = f63 * f63;
    float f65 = (f64 * f64) * f63;
    vec3 f66 = vec3(f65) + (f57 * (1.0 - f65));
    float f67 = f60 * f60;
    float f68 = (((f61 * f67) - f61) * f61) + 1.0;
    float f69 = 1.0 - f56;
    float f70 = f50 * f69;
    vec3 f71 = vec3(f69);
    float f72 = f55.x;
    float f73 = f55.y;
    vec3 f74 = ((f57 * f72) + vec3(f73)) / vec3(f72 + f73);
    vec3 f75 = f71 - (f74 * f70);
    vec3 f76 = f18 * f18;
    bvec3 f77 = lessThan(f18, vec3(0.0));
    vec3 f78 = vec3(f77.x ? f76.x : vec3(0.0).x, f77.y ? f76.y : vec3(0.0).y, f77.z ? f76.z : vec3(0.0).z);
    vec3 f79 = f76 - f78;
    float f80 = f79.x;
    float f81 = f79.y;
    float f82 = f79.z;
    float f83 = f78.x;
    float f84 = f78.y;
    float f85 = f78.z;
    vec3 f86 = (mix(textureLod(PrefilteredEnvIndoorTexture, f54, f53).xyz * f28, textureLod(PrefilteredEnvTexture, f54, f53).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f52.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f29)) * f74) * f50;
    vec3 f87 = (((((((f71 - (f66 * f70)) * CB0[10].xyz) * f59) + (f75 * (((((((CB0[35].xyz * f80) + (CB0[37].xyz * f81)) + (CB0[39].xyz * f82)) + (CB0[36].xyz * f83)) + (CB0[38].xyz * f84)) + (CB0[40].xyz * f85)) + (((((((CB0[29].xyz * f80) + (CB0[31].xyz * f81)) + (CB0[33].xyz * f82)) + (CB0[30].xyz * f83)) + (CB0[32].xyz * f84)) + (CB0[34].xyz * f85)) * f29)))) + (CB0[27].xyz + (CB0[28].xyz * f29))) * f49) + (((f66 * (((f67 + (f67 * f67)) / (((f68 * f68) * ((f62 * 3.0) + 0.5)) * ((f61 * 0.75) + 0.25))) * f59)) * CB0[10].xyz) + f86)) + ((f28 * mix(f49, f86 * (1.0 / (max(max(f86.x, f86.y), f86.z) + 0.00999999977648258209228515625)), (vec3(1.0) - f75) * (f50 * (1.0 - f29)))) * 1.0);
    float f88 = f9.w;
    vec4 f89 = vec4(f87.x, f87.y, f87.z, vec4(0.0).w);
    f89.w = f88;
    float f90 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f91 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f90) * 5.0).xyz;
    bvec3 f92 = bvec3(CB0[13].w != 0.0);
    vec3 f93 = sqrt(clamp(mix(vec3(f92.x ? CB0[14].xyz.x : f91.x, f92.y ? CB0[14].xyz.y : f91.y, f92.z ? CB0[14].xyz.z : f91.z), f89.xyz, vec3(f90)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f94 = vec4(f93.x, f93.y, f93.z, f89.w);
    f94.w = f88;
    _entryPointOutput = f94;
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrecomputedBRDFTexture=s11
//$$DiffuseMapTexture=s3
//$$Tc2DiffuseMapTexture=s0
//$$NormalMapTexture=s4
//$$SpecularMapTexture=s5
