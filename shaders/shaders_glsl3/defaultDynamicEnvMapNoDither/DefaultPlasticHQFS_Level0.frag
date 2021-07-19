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
    vec3 f15 = vec4(VARYING2.xyz * (f4.x * 2.0), VARYING2.w).xyz;
    vec3 f16 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f17 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f18 = VARYING3.yzx - (VARYING3.yzx * f17);
    vec4 f19 = texture(LightMapTexture, f18);
    vec4 f20 = texture(LightGridSkylightTexture, f18);
    vec4 f21 = vec4(clamp(f17, 0.0, 1.0));
    vec4 f22 = mix(f19, vec4(0.0), f21);
    vec4 f23 = mix(f20, vec4(1.0), f21);
    float f24 = f23.x;
    vec4 f25 = texture(ShadowMapTexture, f16.xy);
    float f26 = f16.z;
    float f27 = CB0[26].w * f3;
    float f28 = max(CB2[0].y, 0.04500000178813934326171875);
    vec3 f29 = reflect(-f1, f14);
    float f30 = (VARYING7.w != 0.0) ? 0.0 : (f28 * 5.0);
    vec3 f31 = vec4(f29, f30).xyz;
    vec3 f32 = textureLod(PrefilteredEnvTexture, f31, f30).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f29.y * 1.58823525905609130859375, 0.0, 1.0)));
    vec3 f33 = textureLod(PrefilteredEnvIndoorTexture, f31, f30).xyz;
    vec3 f34;
    if (CB0[27].w == 0.0)
    {
        f34 = f33;
    }
    else
    {
        f34 = mix(f33, textureLod(PrefilteredEnvBlendTargetTexture, f31, f30).xyz, vec3(CB0[27].w));
    }
    vec4 f35 = texture(PrecomputedBRDFTexture, vec2(f28, max(9.9999997473787516355514526367188e-05, dot(f14, f1))));
    vec3 f36 = -CB0[11].xyz;
    float f37 = dot(f14, f36) * ((1.0 - ((step(f25.x, f26) * clamp(CB0[24].z + (CB0[24].w * abs(f26 - 0.5)), 0.0, 1.0)) * f25.y)) * f23.y);
    vec3 f38 = normalize(f36 + f1);
    float f39 = clamp(f37, 0.0, 1.0);
    float f40 = f28 * f28;
    float f41 = max(0.001000000047497451305389404296875, dot(f14, f38));
    float f42 = dot(f36, f38);
    float f43 = 1.0 - f42;
    float f44 = f43 * f43;
    float f45 = (f44 * f44) * f43;
    vec3 f46 = vec3(f45) + (vec3(0.039999999105930328369140625) * (1.0 - f45));
    float f47 = f40 * f40;
    float f48 = (((f41 * f47) - f41) * f41) + 1.0;
    float f49 = f35.x;
    float f50 = f35.y;
    vec3 f51 = ((vec3(0.039999999105930328369140625) * f49) + vec3(f50)) / vec3(f49 + f50);
    vec3 f52 = f14 * f14;
    bvec3 f53 = lessThan(f14, vec3(0.0));
    vec3 f54 = vec3(f53.x ? f52.x : vec3(0.0).x, f53.y ? f52.y : vec3(0.0).y, f53.z ? f52.z : vec3(0.0).z);
    vec3 f55 = f52 - f54;
    float f56 = f55.x;
    float f57 = f55.y;
    float f58 = f55.z;
    float f59 = f54.x;
    float f60 = f54.y;
    float f61 = f54.z;
    vec3 f62 = ((((((((vec3(1.0) - (f46 * f27)) * CB0[10].xyz) * f39) + (CB0[12].xyz * clamp(-f37, 0.0, 1.0))) + ((f22.xyz * (f22.w * 120.0)).xyz * 1.0)) + ((vec3(1.0) - (f51 * f27)) * (((((((CB0[35].xyz * f56) + (CB0[37].xyz * f57)) + (CB0[39].xyz * f58)) + (CB0[36].xyz * f59)) + (CB0[38].xyz * f60)) + (CB0[40].xyz * f61)) + (((((((CB0[29].xyz * f56) + (CB0[31].xyz * f57)) + (CB0[33].xyz * f58)) + (CB0[30].xyz * f59)) + (CB0[32].xyz * f60)) + (CB0[34].xyz * f61)) * f24)))) + (CB0[27].xyz + (CB0[28].xyz * f24))) * mix((f15 * f15).xyz, f32, vec3(VARYING7.w))) + (((f46 * (((f47 + (f47 * f47)) / (((f48 * f48) * ((f42 * 3.0) + 0.5)) * ((f41 * 0.75) + 0.25))) * f39)) * CB0[10].xyz) + ((mix(f34, f32, vec3(f24)) * f51) * f27));
    vec4 f63 = vec4(f62.x, f62.y, f62.z, vec4(0.0).w);
    f63.w = VARYING2.w;
    float f64 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f65 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f64) * 5.0).xyz;
    bvec3 f66 = bvec3(CB0[13].w != 0.0);
    vec3 f67 = sqrt(clamp(mix(vec3(f66.x ? CB0[14].xyz.x : f65.x, f66.y ? CB0[14].xyz.y : f65.y, f66.z ? CB0[14].xyz.z : f65.z), f63.xyz, vec3(f64)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f68 = vec4(f67.x, f67.y, f67.z, f63.w);
    f68.w = VARYING2.w;
    _entryPointOutput = f68;
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrefilteredEnvBlendTargetTexture=s2
//$$PrecomputedBRDFTexture=s11
//$$DiffuseMapTexture=s3
//$$NormalMapTexture=s4
//$$NormalDetailMapTexture=s8
