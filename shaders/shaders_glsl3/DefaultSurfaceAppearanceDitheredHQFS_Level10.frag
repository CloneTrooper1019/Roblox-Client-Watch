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
    float f6 = fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))));
    if (smoothstep(0.0, 1.0, f5) < (f6 * CB0[47].z))
    {
        discard;
    }
    vec4 f7 = vec4(mix(vec4(f3.xyz * VARYING2.xyz, f5).xyz, f4.xyz, vec3(f5)), f5);
    vec4 f8 = vec4(f4.xyz, f5 * f5);
    bvec4 f9 = bvec4(CB3[0].x != 0.0);
    vec4 f10 = vec4(f9.x ? f7.x : f8.x, f9.y ? f7.y : f8.y, f9.z ? f7.z : f8.z, f9.w ? f7.w : f8.w);
    vec2 f11 = texture(NormalMapTexture, VARYING1).wy * 2.0;
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
    vec3 f22 = f10.xyz;
    vec3 f23 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f24 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f25 = VARYING3.yzx - (VARYING3.yzx * f24);
    vec4 f26 = vec4(clamp(f24, 0.0, 1.0));
    vec4 f27 = mix(texture(LightMapTexture, f25), vec4(0.0), f26);
    vec4 f28 = mix(texture(LightGridSkylightTexture, f25), vec4(1.0), f26);
    vec3 f29 = (f27.xyz * (f27.w * 120.0)).xyz;
    float f30 = f28.x;
    float f31 = f28.y;
    vec3 f32 = f23 - CB0[41].xyz;
    vec3 f33 = f23 - CB0[42].xyz;
    vec3 f34 = f23 - CB0[43].xyz;
    vec4 f35 = vec4(f23, 1.0) * mat4(CB8[((dot(f32, f32) < CB0[41].w) ? 0 : ((dot(f33, f33) < CB0[42].w) ? 1 : ((dot(f34, f34) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f32, f32) < CB0[41].w) ? 0 : ((dot(f33, f33) < CB0[42].w) ? 1 : ((dot(f34, f34) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f32, f32) < CB0[41].w) ? 0 : ((dot(f33, f33) < CB0[42].w) ? 1 : ((dot(f34, f34) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f32, f32) < CB0[41].w) ? 0 : ((dot(f33, f33) < CB0[42].w) ? 1 : ((dot(f34, f34) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
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
    vec3 f50 = (f22 * f22).xyz;
    float f51 = CB0[26].w * f2;
    float f52 = max(f15.y, 0.04500000178813934326171875);
    vec3 f53 = reflect(-f1, f19);
    float f54 = f52 * 5.0;
    vec3 f55 = vec4(f53, f54).xyz;
    vec4 f56 = texture(PrecomputedBRDFTexture, vec2(f52, max(9.9999997473787516355514526367188e-05, dot(f19, f1))));
    float f57 = f15.x * f51;
    vec3 f58 = mix(vec3(0.039999999105930328369140625), f50, vec3(f57));
    vec3 f59 = normalize(f20 + f1);
    float f60 = clamp(f21 * (((f21 * CB0[47].x) > 0.0) ? mix(min((f40 <= f44) ? 1.0 : clamp(((f45 / (f45 + (f46 * f46))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f41 <= f47) ? 1.0 : clamp(((f48 / (f48 + (f49 * f49))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f31, clamp((length(f23 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f31), 0.0, 1.0);
    float f61 = f52 * f52;
    float f62 = max(0.001000000047497451305389404296875, dot(f19, f59));
    float f63 = dot(f20, f59);
    float f64 = 1.0 - f63;
    float f65 = f64 * f64;
    float f66 = (f65 * f65) * f64;
    vec3 f67 = vec3(f66) + (f58 * (1.0 - f66));
    float f68 = f61 * f61;
    float f69 = (((f62 * f68) - f62) * f62) + 1.0;
    float f70 = 1.0 - f57;
    float f71 = f51 * f70;
    vec3 f72 = vec3(f70);
    float f73 = f56.x;
    float f74 = f56.y;
    vec3 f75 = ((f58 * f73) + vec3(f74)) / vec3(f73 + f74);
    vec3 f76 = f72 - (f75 * f71);
    vec3 f77 = f19 * f19;
    bvec3 f78 = lessThan(f19, vec3(0.0));
    vec3 f79 = vec3(f78.x ? f77.x : vec3(0.0).x, f78.y ? f77.y : vec3(0.0).y, f78.z ? f77.z : vec3(0.0).z);
    vec3 f80 = f77 - f79;
    float f81 = f80.x;
    float f82 = f80.y;
    float f83 = f80.z;
    float f84 = f79.x;
    float f85 = f79.y;
    float f86 = f79.z;
    vec3 f87 = (mix(textureLod(PrefilteredEnvIndoorTexture, f55, f54).xyz * f29, textureLod(PrefilteredEnvTexture, f55, f54).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f53.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f30)) * f75) * f51;
    vec3 f88 = (((((((f72 - (f67 * f71)) * CB0[10].xyz) * f60) + (f76 * (((((((CB0[35].xyz * f81) + (CB0[37].xyz * f82)) + (CB0[39].xyz * f83)) + (CB0[36].xyz * f84)) + (CB0[38].xyz * f85)) + (CB0[40].xyz * f86)) + (((((((CB0[29].xyz * f81) + (CB0[31].xyz * f82)) + (CB0[33].xyz * f83)) + (CB0[30].xyz * f84)) + (CB0[32].xyz * f85)) + (CB0[34].xyz * f86)) * f30)))) + (CB0[27].xyz + (CB0[28].xyz * f30))) * f50) + (((f67 * (((f68 + (f68 * f68)) / (((f69 * f69) * ((f63 * 3.0) + 0.5)) * ((f62 * 0.75) + 0.25))) * f60)) * CB0[10].xyz) + f87)) + ((f29 * mix(f50, f87 * (1.0 / (max(max(f87.x, f87.y), f87.z) + 0.00999999977648258209228515625)), (vec3(1.0) - f76) * (f51 * (1.0 - f30)))) * 1.0);
    float f89 = f10.w;
    vec4 f90 = vec4(f88.x, f88.y, f88.z, vec4(0.0).w);
    f90.w = f89;
    float f91 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f92 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f91) * 5.0).xyz;
    bvec3 f93 = bvec3(CB0[13].w != 0.0);
    vec3 f94 = sqrt(clamp(mix(vec3(f93.x ? CB0[14].xyz.x : f92.x, f93.y ? CB0[14].xyz.y : f92.y, f93.z ? CB0[14].xyz.z : f92.z), f90.xyz, vec3(f91)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * f6));
    vec4 f95 = vec4(f94.x, f94.y, f94.z, f90.w);
    f95.w = f89;
    _entryPointOutput = f95;
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
