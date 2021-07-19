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
    vec4 f3 = mix(texture(DiffuseMapTexture, VARYING0), f2, vec4(f2.w)) * VARYING2;
    vec3 f4 = normalize(VARYING5.xyz) * (gl_FrontFacing ? 1.0 : (-1.0));
    vec3 f5 = -CB0[11].xyz;
    float f6 = dot(f4, f5);
    vec3 f7 = f3.xyz;
    vec3 f8 = VARYING6.xyz - (CB0[11].xyz * VARYING3.w);
    float f9 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f10 = VARYING3.yzx - (VARYING3.yzx * f9);
    vec4 f11 = vec4(clamp(f9, 0.0, 1.0));
    vec4 f12 = mix(texture(LightMapTexture, f10), vec4(0.0), f11);
    vec4 f13 = mix(texture(LightGridSkylightTexture, f10), vec4(1.0), f11);
    vec3 f14 = (f12.xyz * (f12.w * 120.0)).xyz;
    float f15 = f13.x;
    float f16 = f13.y;
    vec3 f17 = f8 - CB0[41].xyz;
    vec3 f18 = f8 - CB0[42].xyz;
    vec3 f19 = f8 - CB0[43].xyz;
    vec4 f20 = vec4(f8, 1.0) * mat4(CB8[((dot(f17, f17) < CB0[41].w) ? 0 : ((dot(f18, f18) < CB0[42].w) ? 1 : ((dot(f19, f19) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f17, f17) < CB0[41].w) ? 0 : ((dot(f18, f18) < CB0[42].w) ? 1 : ((dot(f19, f19) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f17, f17) < CB0[41].w) ? 0 : ((dot(f18, f18) < CB0[42].w) ? 1 : ((dot(f19, f19) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f17, f17) < CB0[41].w) ? 0 : ((dot(f18, f18) < CB0[42].w) ? 1 : ((dot(f19, f19) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f21 = textureLod(ShadowAtlasTexture, f20.xy, 0.0);
    vec2 f22 = vec2(0.0);
    f22.x = CB0[46].z;
    vec2 f23 = f22;
    f23.y = CB0[46].w;
    float f24 = (2.0 * f20.z) - 1.0;
    float f25 = exp(CB0[46].z * f24);
    float f26 = -exp((-CB0[46].w) * f24);
    vec2 f27 = (f23 * CB0[47].y) * vec2(f25, f26);
    vec2 f28 = f27 * f27;
    float f29 = f21.x;
    float f30 = max(f21.y - (f29 * f29), f28.x);
    float f31 = f25 - f29;
    float f32 = f21.z;
    float f33 = max(f21.w - (f32 * f32), f28.y);
    float f34 = f26 - f32;
    vec3 f35 = (f7 * f7).xyz;
    float f36 = CB0[26].w * clamp(1.0 - (VARYING4.w * CB0[23].y), 0.0, 1.0);
    float f37 = max(VARYING5.w, 0.04500000178813934326171875);
    vec3 f38 = reflect(-f1, f4);
    float f39 = f37 * 5.0;
    vec3 f40 = vec4(f38, f39).xyz;
    vec4 f41 = texture(PrecomputedBRDFTexture, vec2(f37, max(9.9999997473787516355514526367188e-05, dot(f4, f1))));
    float f42 = VARYING6.w * f36;
    vec3 f43 = mix(vec3(0.039999999105930328369140625), f35, vec3(f42));
    vec3 f44 = normalize(f5 + f1);
    float f45 = clamp(f6 * (((f6 * CB0[47].x) > 0.0) ? mix(min((f25 <= f29) ? 1.0 : clamp(((f30 / (f30 + (f31 * f31))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f26 <= f32) ? 1.0 : clamp(((f33 / (f33 + (f34 * f34))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f16, clamp((length(f8 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f16), 0.0, 1.0);
    float f46 = f37 * f37;
    float f47 = max(0.001000000047497451305389404296875, dot(f4, f44));
    float f48 = dot(f5, f44);
    float f49 = 1.0 - f48;
    float f50 = f49 * f49;
    float f51 = (f50 * f50) * f49;
    vec3 f52 = vec3(f51) + (f43 * (1.0 - f51));
    float f53 = f46 * f46;
    float f54 = (((f47 * f53) - f47) * f47) + 1.0;
    float f55 = 1.0 - f42;
    float f56 = f36 * f55;
    vec3 f57 = vec3(f55);
    float f58 = f41.x;
    float f59 = f41.y;
    vec3 f60 = ((f43 * f58) + vec3(f59)) / vec3(f58 + f59);
    vec3 f61 = f57 - (f60 * f56);
    vec3 f62 = f4 * f4;
    bvec3 f63 = lessThan(f4, vec3(0.0));
    vec3 f64 = vec3(f63.x ? f62.x : vec3(0.0).x, f63.y ? f62.y : vec3(0.0).y, f63.z ? f62.z : vec3(0.0).z);
    vec3 f65 = f62 - f64;
    float f66 = f65.x;
    float f67 = f65.y;
    float f68 = f65.z;
    float f69 = f64.x;
    float f70 = f64.y;
    float f71 = f64.z;
    vec3 f72 = (mix(textureLod(PrefilteredEnvIndoorTexture, f40, f39).xyz * f14, textureLod(PrefilteredEnvTexture, f40, f39).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f38.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f15)) * f60) * f36;
    vec3 f73 = (((((((f57 - (f52 * f56)) * CB0[10].xyz) * f45) + (f61 * (((((((CB0[35].xyz * f66) + (CB0[37].xyz * f67)) + (CB0[39].xyz * f68)) + (CB0[36].xyz * f69)) + (CB0[38].xyz * f70)) + (CB0[40].xyz * f71)) + (((((((CB0[29].xyz * f66) + (CB0[31].xyz * f67)) + (CB0[33].xyz * f68)) + (CB0[30].xyz * f69)) + (CB0[32].xyz * f70)) + (CB0[34].xyz * f71)) * f15)))) + (CB0[27].xyz + (CB0[28].xyz * f15))) * f35) + (((f52 * (((f53 + (f53 * f53)) / (((f54 * f54) * ((f48 * 3.0) + 0.5)) * ((f47 * 0.75) + 0.25))) * f45)) * CB0[10].xyz) + f72)) + ((f14 * mix(f35, f72 * (1.0 / (max(max(f72.x, f72.y), f72.z) + 0.00999999977648258209228515625)), (vec3(1.0) - f61) * (f36 * (1.0 - f15)))) * 1.0);
    float f74 = f3.w;
    vec4 f75 = vec4(f73.x, f73.y, f73.z, vec4(0.0).w);
    f75.w = f74;
    float f76 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f77 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f76) * 5.0).xyz;
    bvec3 f78 = bvec3(CB0[13].w != 0.0);
    vec3 f79 = sqrt(clamp(mix(vec3(f78.x ? CB0[14].xyz.x : f77.x, f78.y ? CB0[14].xyz.y : f77.y, f78.z ? CB0[14].xyz.z : f77.z), f75.xyz, vec3(f76)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f80 = vec4(f79.x, f79.y, f79.z, f75.w);
    f80.w = f74;
    _entryPointOutput = f80;
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrecomputedBRDFTexture=s11
//$$Tc2DiffuseMapTexture=s0
//$$DiffuseMapTexture=s3
