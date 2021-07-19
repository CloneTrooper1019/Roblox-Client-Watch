#version 150

#extension GL_ARB_shading_language_include : require
#include <Globals.h>
#include <MaterialParams.h>
uniform vec4 CB0[53];
uniform vec4 CB2[4];
uniform sampler2D ShadowMapTexture;
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform samplerCube PrefilteredEnvTexture;
uniform samplerCube PrefilteredEnvIndoorTexture;
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
    vec2 f4 = texture(NormalMapTexture, f2).wy * 2.0;
    vec2 f5 = f4 - vec2(1.0);
    float f6 = sqrt(clamp(1.0 + dot(vec2(1.0) - f4, f5), 0.0, 1.0));
    vec2 f7 = ((vec3(f5, f6).xy + (vec3((texture(NormalDetailMapTexture, VARYING0 * CB2[0].x).wy * 2.0) - vec2(1.0), 0.0).xy * (clamp(VARYING2.w - 0.5, 0.0, 1.0) * clamp(1.0 - (2.0 * VARYING7.w), 0.0, 1.0)))).xy * f3).xy * CB2[3].w;
    float f8 = gl_FrontFacing ? 1.0 : (-1.0);
    vec3 f9 = VARYING6.xyz * f8;
    vec3 f10 = VARYING5.xyz * f8;
    vec3 f11 = normalize(((f9 * f7.x) + (cross(f10, f9) * f7.y)) + (f10 * f6));
    vec3 f12 = vec4(VARYING2.xyz * (texture(DiffuseMapTexture, f2).x * 2.0), VARYING2.w).xyz;
    vec3 f13 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f14 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f15 = VARYING3.yzx - (VARYING3.yzx * f14);
    vec4 f16 = vec4(clamp(f14, 0.0, 1.0));
    vec4 f17 = mix(texture(LightMapTexture, f15), vec4(0.0), f16);
    vec4 f18 = mix(texture(LightGridSkylightTexture, f15), vec4(1.0), f16);
    vec3 f19 = (f17.xyz * (f17.w * 120.0)).xyz;
    float f20 = f18.x;
    vec4 f21 = texture(ShadowMapTexture, f13.xy);
    float f22 = f13.z;
    float f23 = CB0[26].w * f3;
    float f24 = max(CB2[0].y, 0.04500000178813934326171875);
    vec3 f25 = reflect(-f1, f11);
    float f26 = (VARYING7.w != 0.0) ? 0.0 : (f24 * 5.0);
    vec3 f27 = vec4(f25, f26).xyz;
    vec3 f28 = textureLod(PrefilteredEnvTexture, f27, f26).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f25.y * 1.58823525905609130859375, 0.0, 1.0)));
    vec4 f29 = texture(PrecomputedBRDFTexture, vec2(f24, max(9.9999997473787516355514526367188e-05, dot(f11, f1))));
    vec3 f30 = mix((f12 * f12).xyz, f28, vec3(VARYING7.w));
    vec3 f31 = -CB0[11].xyz;
    float f32 = dot(f11, f31) * ((1.0 - ((step(f21.x, f22) * clamp(CB0[24].z + (CB0[24].w * abs(f22 - 0.5)), 0.0, 1.0)) * f21.y)) * f18.y);
    vec3 f33 = normalize(f31 + f1);
    float f34 = clamp(f32, 0.0, 1.0);
    float f35 = f24 * f24;
    float f36 = max(0.001000000047497451305389404296875, dot(f11, f33));
    float f37 = dot(f31, f33);
    float f38 = 1.0 - f37;
    float f39 = f38 * f38;
    float f40 = (f39 * f39) * f38;
    vec3 f41 = vec3(f40) + (vec3(0.039999999105930328369140625) * (1.0 - f40));
    float f42 = f35 * f35;
    float f43 = (((f36 * f42) - f36) * f36) + 1.0;
    float f44 = f29.x;
    float f45 = f29.y;
    vec3 f46 = ((vec3(0.039999999105930328369140625) * f44) + vec3(f45)) / vec3(f44 + f45);
    vec3 f47 = f46 * f23;
    vec3 f48 = f11 * f11;
    bvec3 f49 = lessThan(f11, vec3(0.0));
    vec3 f50 = vec3(f49.x ? f48.x : vec3(0.0).x, f49.y ? f48.y : vec3(0.0).y, f49.z ? f48.z : vec3(0.0).z);
    vec3 f51 = f48 - f50;
    float f52 = f51.x;
    float f53 = f51.y;
    float f54 = f51.z;
    float f55 = f50.x;
    float f56 = f50.y;
    float f57 = f50.z;
    vec3 f58 = (mix(textureLod(PrefilteredEnvIndoorTexture, f27, f26).xyz * f19, f28, vec3(f20)) * f46) * f23;
    vec3 f59 = ((((((((vec3(1.0) - (f41 * f23)) * CB0[10].xyz) * f34) + (CB0[12].xyz * clamp(-f32, 0.0, 1.0))) + ((vec3(1.0) - f47) * (((((((CB0[35].xyz * f52) + (CB0[37].xyz * f53)) + (CB0[39].xyz * f54)) + (CB0[36].xyz * f55)) + (CB0[38].xyz * f56)) + (CB0[40].xyz * f57)) + (((((((CB0[29].xyz * f52) + (CB0[31].xyz * f53)) + (CB0[33].xyz * f54)) + (CB0[30].xyz * f55)) + (CB0[32].xyz * f56)) + (CB0[34].xyz * f57)) * f20)))) + (CB0[27].xyz + (CB0[28].xyz * f20))) * f30) + (((f41 * (((f42 + (f42 * f42)) / (((f43 * f43) * ((f37 * 3.0) + 0.5)) * ((f36 * 0.75) + 0.25))) * f34)) * CB0[10].xyz) + f58)) + ((f19 * mix(f30, f58 * (1.0 / (max(max(f58.x, f58.y), f58.z) + 0.00999999977648258209228515625)), f47 * (f23 * (1.0 - f20)))) * 1.0);
    vec4 f60 = vec4(f59.x, f59.y, f59.z, vec4(0.0).w);
    f60.w = VARYING2.w;
    float f61 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f62 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f61) * 5.0).xyz;
    bvec3 f63 = bvec3(CB0[13].w != 0.0);
    vec3 f64 = sqrt(clamp(mix(vec3(f63.x ? CB0[14].xyz.x : f62.x, f63.y ? CB0[14].xyz.y : f62.y, f63.z ? CB0[14].xyz.z : f62.z), f60.xyz, vec3(f61)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f65 = vec4(f64.x, f64.y, f64.z, f60.w);
    f65.w = VARYING2.w;
    _entryPointOutput = f65;
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrecomputedBRDFTexture=s11
//$$DiffuseMapTexture=s3
//$$NormalMapTexture=s4
//$$NormalDetailMapTexture=s8
