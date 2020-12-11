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
uniform sampler2D DiffuseMapTexture;

in vec2 VARYING0;
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
    vec3 f2 = normalize(VARYING5.xyz) * (gl_FrontFacing ? 1.0 : (-1.0));
    vec3 f3 = -CB0[11].xyz;
    float f4 = dot(f2, f3);
    vec3 f5 = (texture(DiffuseMapTexture, VARYING0) * VARYING2).xyz;
    vec3 f6 = VARYING6.xyz - (CB0[11].xyz * VARYING3.w);
    float f7 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f8 = VARYING3.yzx - (VARYING3.yzx * f7);
    vec4 f9 = vec4(clamp(f7, 0.0, 1.0));
    vec4 f10 = mix(texture(LightMapTexture, f8), vec4(0.0), f9);
    vec4 f11 = mix(texture(LightGridSkylightTexture, f8), vec4(1.0), f9);
    float f12 = f11.x;
    float f13 = f11.y;
    vec3 f14 = f6 - CB0[41].xyz;
    vec3 f15 = f6 - CB0[42].xyz;
    vec3 f16 = f6 - CB0[43].xyz;
    vec4 f17 = vec4(f6, 1.0) * mat4(CB8[((dot(f14, f14) < CB0[41].w) ? 0 : ((dot(f15, f15) < CB0[42].w) ? 1 : ((dot(f16, f16) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f14, f14) < CB0[41].w) ? 0 : ((dot(f15, f15) < CB0[42].w) ? 1 : ((dot(f16, f16) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f14, f14) < CB0[41].w) ? 0 : ((dot(f15, f15) < CB0[42].w) ? 1 : ((dot(f16, f16) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f14, f14) < CB0[41].w) ? 0 : ((dot(f15, f15) < CB0[42].w) ? 1 : ((dot(f16, f16) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f18 = textureLod(ShadowAtlasTexture, f17.xy, 0.0);
    vec2 f19 = vec2(0.0);
    f19.x = CB0[46].z;
    vec2 f20 = f19;
    f20.y = CB0[46].w;
    float f21 = (2.0 * f17.z) - 1.0;
    float f22 = exp(CB0[46].z * f21);
    float f23 = -exp((-CB0[46].w) * f21);
    vec2 f24 = (f20 * CB0[47].y) * vec2(f22, f23);
    vec2 f25 = f24 * f24;
    float f26 = f18.x;
    float f27 = max(f18.y - (f26 * f26), f25.x);
    float f28 = f22 - f26;
    float f29 = f18.z;
    float f30 = max(f18.w - (f29 * f29), f25.y);
    float f31 = f23 - f29;
    vec3 f32 = (f5 * f5).xyz;
    float f33 = CB0[26].w * clamp(1.0 - (VARYING4.w * CB0[23].y), 0.0, 1.0);
    float f34 = max(VARYING5.w, 0.04500000178813934326171875);
    vec3 f35 = reflect(-f1, f2);
    float f36 = f34 * 5.0;
    vec3 f37 = vec4(f35, f36).xyz;
    vec4 f38 = texture(PrecomputedBRDFTexture, vec2(f34, max(9.9999997473787516355514526367188e-05, dot(f2, f1))));
    float f39 = VARYING6.w * f33;
    vec3 f40 = mix(vec3(0.039999999105930328369140625), f32, vec3(f39));
    vec3 f41 = normalize(f3 + f1);
    float f42 = clamp(f4 * ((f4 > 0.0) ? mix(f13, mix(min((f22 <= f26) ? 1.0 : clamp(((f27 / (f27 + (f28 * f28))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f23 <= f29) ? 1.0 : clamp(((f30 / (f30 + (f31 * f31))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f13, clamp((length(f6 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)), CB0[47].x) : 0.0), 0.0, 1.0);
    float f43 = f34 * f34;
    float f44 = max(0.001000000047497451305389404296875, dot(f2, f41));
    float f45 = dot(f3, f41);
    float f46 = 1.0 - f45;
    float f47 = f46 * f46;
    float f48 = (f47 * f47) * f46;
    vec3 f49 = vec3(f48) + (f40 * (1.0 - f48));
    float f50 = f43 * f43;
    float f51 = (((f44 * f50) - f44) * f44) + 1.0;
    float f52 = 1.0 - f39;
    float f53 = f33 * f52;
    vec3 f54 = vec3(f52);
    float f55 = f38.x;
    float f56 = f38.y;
    vec3 f57 = ((f40 * f55) + vec3(f56)) / vec3(f55 + f56);
    vec3 f58 = f54 - (f57 * f53);
    vec3 f59 = f2 * f2;
    bvec3 f60 = lessThan(f2, vec3(0.0));
    vec3 f61 = vec3(f60.x ? f59.x : vec3(0.0).x, f60.y ? f59.y : vec3(0.0).y, f60.z ? f59.z : vec3(0.0).z);
    vec3 f62 = f59 - f61;
    float f63 = f62.x;
    float f64 = f62.y;
    float f65 = f62.z;
    float f66 = f61.x;
    float f67 = f61.y;
    float f68 = f61.z;
    vec3 f69 = ((((((CB0[35].xyz * f63) + (CB0[37].xyz * f64)) + (CB0[39].xyz * f65)) + (CB0[36].xyz * f66)) + (CB0[38].xyz * f67)) + (CB0[40].xyz * f68)) + (((((((CB0[29].xyz * f63) + (CB0[31].xyz * f64)) + (CB0[33].xyz * f65)) + (CB0[30].xyz * f66)) + (CB0[32].xyz * f67)) + (CB0[34].xyz * f68)) * f12);
    vec3 f70 = (mix(textureLod(PrefilteredEnvIndoorTexture, f37, f36).xyz, textureLod(PrefilteredEnvTexture, f37, f36).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f35.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f12)) * f57) * f33;
    vec3 f71 = (((((((f54 - (f49 * f53)) * CB0[10].xyz) * f42) + ((f58 * f69) * CB0[25].w)) + ((CB0[27].xyz + (CB0[28].xyz * f12)) * 1.0)) * f32) + (((f49 * (((f50 + (f50 * f50)) / (((f51 * f51) * ((f45 * 3.0) + 0.5)) * ((f44 * 0.75) + 0.25))) * f42)) * CB0[10].xyz) + f70)) + (((f10.xyz * (f10.w * 120.0)).xyz * mix(f32, f70 * (1.0 / (max(max(f69.x, f69.y), f69.z) + 0.00999999977648258209228515625)), (vec3(1.0) - f58) * (f33 * (1.0 - f12)))) * 1.0);
    vec4 f72 = vec4(f71.x, f71.y, f71.z, vec4(0.0).w);
    f72.w = 1.0;
    float f73 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f74 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f73) * 5.0).xyz;
    bvec3 f75 = bvec3(CB0[13].w != 0.0);
    vec3 f76 = sqrt(clamp(mix(vec3(f75.x ? CB0[14].xyz.x : f74.x, f75.y ? CB0[14].xyz.y : f74.y, f75.z ? CB0[14].xyz.z : f74.z), f72.xyz, vec3(f73)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f77 = vec4(f76.x, f76.y, f76.z, f72.w);
    f77.w = 1.0;
    _entryPointOutput = f77;
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrecomputedBRDFTexture=s11
//$$DiffuseMapTexture=s3
