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
uniform sampler2D NormalMapTexture;
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
    vec4 f3 = texture(DiffuseMapTexture, VARYING0);
    float f4 = f3.w;
    if (f4 < (0.5 * CB0[47].z))
    {
        discard;
    }
    vec4 f5 = vec4(mix(VARYING2.xyz, f3.xyz, vec3(f4)), VARYING2.w);
    vec4 f6 = vec4(f3.xyz, VARYING2.w * f4);
    bvec4 f7 = bvec4(CB3[0].x != 0.0);
    vec4 f8 = vec4(f7.x ? f5.x : f6.x, f7.y ? f5.y : f6.y, f7.z ? f5.z : f6.z, f7.w ? f5.w : f6.w);
    vec4 f9 = texture(NormalMapTexture, VARYING0);
    vec2 f10 = f9.wy * 2.0;
    vec2 f11 = f10 - vec2(1.0);
    float f12 = sqrt(clamp(1.0 + dot(vec2(1.0) - f10, f11), 0.0, 1.0));
    vec2 f13 = vec3(f11, f12).xy * f2;
    vec4 f14 = texture(SpecularMapTexture, VARYING0);
    float f15 = gl_FrontFacing ? 1.0 : (-1.0);
    vec3 f16 = VARYING6.xyz * f15;
    vec3 f17 = VARYING5.xyz * f15;
    vec3 f18 = normalize(((f16 * f13.x) + ((cross(f17, f16) * VARYING6.w) * f13.y)) + (f17 * f12));
    vec3 f19 = -CB0[11].xyz;
    float f20 = dot(f18, f19);
    vec3 f21 = f8.xyz;
    vec3 f22 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f23 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f24 = VARYING3.yzx - (VARYING3.yzx * f23);
    vec4 f25 = texture(LightMapTexture, f24);
    vec4 f26 = texture(LightGridSkylightTexture, f24);
    vec4 f27 = vec4(clamp(f23, 0.0, 1.0));
    vec4 f28 = mix(f25, vec4(0.0), f27);
    vec4 f29 = mix(f26, vec4(1.0), f27);
    float f30 = f29.x;
    float f31 = f29.y;
    vec3 f32 = f22 - CB0[41].xyz;
    vec3 f33 = f22 - CB0[42].xyz;
    vec3 f34 = f22 - CB0[43].xyz;
    vec4 f35 = vec4(f22, 1.0) * mat4(CB8[((dot(f32, f32) < CB0[41].w) ? 0 : ((dot(f33, f33) < CB0[42].w) ? 1 : ((dot(f34, f34) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f32, f32) < CB0[41].w) ? 0 : ((dot(f33, f33) < CB0[42].w) ? 1 : ((dot(f34, f34) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f32, f32) < CB0[41].w) ? 0 : ((dot(f33, f33) < CB0[42].w) ? 1 : ((dot(f34, f34) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f32, f32) < CB0[41].w) ? 0 : ((dot(f33, f33) < CB0[42].w) ? 1 : ((dot(f34, f34) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f36 = textureLod(ShadowAtlasTexture, f35.xy, 0.0);
    vec2 f37 = vec2(0.0);
    f37.x = CB0[46].z;
    vec2 f38 = f37;
    f38.y = CB0[46].w;
    float f39 = (2.0 * f35.z) - 1.0;
    float f40 = exp(CB0[46].z * f39);
    float f41 = -exp((-CB0[46].w) * f39);
    vec2 f42 = (f38 * CB0[47].y) * vec2(f40, f41);
    vec2 f43 = f42 * f42;
    float f44 = f36.x;
    float f45 = max(f36.y - (f44 * f44), f43.x);
    float f46 = f40 - f44;
    float f47 = f36.z;
    float f48 = max(f36.w - (f47 * f47), f43.y);
    float f49 = f41 - f47;
    vec3 f50 = (f21 * f21).xyz;
    float f51 = CB0[26].w * f2;
    float f52 = max(f14.y, 0.04500000178813934326171875);
    vec3 f53 = reflect(-f1, f18);
    float f54 = f52 * 5.0;
    vec3 f55 = vec4(f53, f54).xyz;
    vec3 f56 = textureLod(PrefilteredEnvIndoorTexture, f55, f54).xyz;
    vec3 f57;
    if (CB0[27].w == 0.0)
    {
        f57 = f56;
    }
    else
    {
        f57 = mix(f56, textureLod(PrefilteredEnvBlendTargetTexture, f55, f54).xyz, vec3(CB0[27].w));
    }
    vec4 f58 = texture(PrecomputedBRDFTexture, vec2(f52, max(9.9999997473787516355514526367188e-05, dot(f18, f1))));
    float f59 = f14.x * f51;
    vec3 f60 = mix(vec3(0.039999999105930328369140625), f50, vec3(f59));
    vec3 f61 = normalize(f19 + f1);
    float f62 = clamp(f20 * (((f20 * CB0[47].x) > 0.0) ? mix(min((f40 <= f44) ? 1.0 : clamp(((f45 / (f45 + (f46 * f46))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f41 <= f47) ? 1.0 : clamp(((f48 / (f48 + (f49 * f49))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f31, clamp((length(f22 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f31), 0.0, 1.0);
    float f63 = f52 * f52;
    float f64 = max(0.001000000047497451305389404296875, dot(f18, f61));
    float f65 = dot(f19, f61);
    float f66 = 1.0 - f65;
    float f67 = f66 * f66;
    float f68 = (f67 * f67) * f66;
    vec3 f69 = vec3(f68) + (f60 * (1.0 - f68));
    float f70 = f63 * f63;
    float f71 = (((f64 * f70) - f64) * f64) + 1.0;
    float f72 = 1.0 - f59;
    float f73 = f51 * f72;
    vec3 f74 = vec3(f72);
    float f75 = f58.x;
    float f76 = f58.y;
    vec3 f77 = ((f60 * f75) + vec3(f76)) / vec3(f75 + f76);
    vec3 f78 = f18 * f18;
    bvec3 f79 = lessThan(f18, vec3(0.0));
    vec3 f80 = vec3(f79.x ? f78.x : vec3(0.0).x, f79.y ? f78.y : vec3(0.0).y, f79.z ? f78.z : vec3(0.0).z);
    vec3 f81 = f78 - f80;
    float f82 = f81.x;
    float f83 = f81.y;
    float f84 = f81.z;
    float f85 = f80.x;
    float f86 = f80.y;
    float f87 = f80.z;
    vec3 f88 = (((((((f74 - (f69 * f73)) * CB0[10].xyz) * f62) + ((f28.xyz * (f28.w * 120.0)).xyz * 1.0)) + ((f74 - (f77 * f73)) * (((((((CB0[35].xyz * f82) + (CB0[37].xyz * f83)) + (CB0[39].xyz * f84)) + (CB0[36].xyz * f85)) + (CB0[38].xyz * f86)) + (CB0[40].xyz * f87)) + (((((((CB0[29].xyz * f82) + (CB0[31].xyz * f83)) + (CB0[33].xyz * f84)) + (CB0[30].xyz * f85)) + (CB0[32].xyz * f86)) + (CB0[34].xyz * f87)) * f30)))) + (CB0[27].xyz + (CB0[28].xyz * f30))) * f50) + (((f69 * (((f70 + (f70 * f70)) / (((f71 * f71) * ((f65 * 3.0) + 0.5)) * ((f64 * 0.75) + 0.25))) * f62)) * CB0[10].xyz) + ((mix(f57, textureLod(PrefilteredEnvTexture, f55, f54).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f53.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f30)) * f77) * f51));
    float f89 = f8.w;
    vec4 f90 = vec4(f88.x, f88.y, f88.z, vec4(0.0).w);
    f90.w = f89;
    float f91 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f92 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f91) * 5.0).xyz;
    bvec3 f93 = bvec3(CB0[13].w != 0.0);
    vec3 f94 = sqrt(clamp(mix(vec3(f93.x ? CB0[14].xyz.x : f92.x, f93.y ? CB0[14].xyz.y : f92.y, f93.z ? CB0[14].xyz.z : f92.z), f90.xyz, vec3(f91)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f95 = vec4(f94.x, f94.y, f94.z, f90.w);
    f95.w = f89;
    _entryPointOutput = f95;
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
//$$SpecularMapTexture=s5
