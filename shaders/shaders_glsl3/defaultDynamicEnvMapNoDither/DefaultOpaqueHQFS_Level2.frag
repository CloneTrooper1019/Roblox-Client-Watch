#version 150

#extension GL_ARB_shading_language_include : require
#include <Globals.h>
uniform vec4 CB0[53];
uniform sampler2D ShadowMapTexture;
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
    vec3 f4 = normalize(VARYING5.xyz) * (gl_FrontFacing ? 1.0 : (-1.0));
    vec3 f5 = (mix(f3, f2, vec4(f2.w)) * VARYING2).xyz;
    vec3 f6 = VARYING6.xyz - (CB0[11].xyz * VARYING3.w);
    float f7 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f8 = VARYING3.yzx - (VARYING3.yzx * f7);
    vec4 f9 = texture(LightMapTexture, f8);
    vec4 f10 = texture(LightGridSkylightTexture, f8);
    vec4 f11 = vec4(clamp(f7, 0.0, 1.0));
    vec4 f12 = mix(f9, vec4(0.0), f11);
    vec4 f13 = mix(f10, vec4(1.0), f11);
    float f14 = f13.x;
    vec4 f15 = texture(ShadowMapTexture, f6.xy);
    float f16 = f6.z;
    vec3 f17 = (f5 * f5).xyz;
    float f18 = CB0[26].w * clamp(1.0 - (VARYING4.w * CB0[23].y), 0.0, 1.0);
    float f19 = max(VARYING5.w, 0.04500000178813934326171875);
    vec3 f20 = reflect(-f1, f4);
    float f21 = f19 * 5.0;
    vec3 f22 = vec4(f20, f21).xyz;
    vec3 f23 = textureLod(PrefilteredEnvIndoorTexture, f22, f21).xyz;
    vec3 f24;
    if (CB0[27].w == 0.0)
    {
        f24 = f23;
    }
    else
    {
        f24 = mix(f23, textureLod(PrefilteredEnvBlendTargetTexture, f22, f21).xyz, vec3(CB0[27].w));
    }
    vec4 f25 = texture(PrecomputedBRDFTexture, vec2(f19, max(9.9999997473787516355514526367188e-05, dot(f4, f1))));
    float f26 = VARYING6.w * f18;
    vec3 f27 = mix(vec3(0.039999999105930328369140625), f17, vec3(f26));
    vec3 f28 = -CB0[11].xyz;
    float f29 = dot(f4, f28) * ((1.0 - ((step(f15.x, f16) * clamp(CB0[24].z + (CB0[24].w * abs(f16 - 0.5)), 0.0, 1.0)) * f15.y)) * f13.y);
    vec3 f30 = normalize(f28 + f1);
    float f31 = clamp(f29, 0.0, 1.0);
    float f32 = f19 * f19;
    float f33 = max(0.001000000047497451305389404296875, dot(f4, f30));
    float f34 = dot(f28, f30);
    float f35 = 1.0 - f34;
    float f36 = f35 * f35;
    float f37 = (f36 * f36) * f35;
    vec3 f38 = vec3(f37) + (f27 * (1.0 - f37));
    float f39 = f32 * f32;
    float f40 = (((f33 * f39) - f33) * f33) + 1.0;
    float f41 = 1.0 - f26;
    float f42 = f18 * f41;
    vec3 f43 = vec3(f41);
    float f44 = f25.x;
    float f45 = f25.y;
    vec3 f46 = ((f27 * f44) + vec3(f45)) / vec3(f44 + f45);
    vec3 f47 = f4 * f4;
    bvec3 f48 = lessThan(f4, vec3(0.0));
    vec3 f49 = vec3(f48.x ? f47.x : vec3(0.0).x, f48.y ? f47.y : vec3(0.0).y, f48.z ? f47.z : vec3(0.0).z);
    vec3 f50 = f47 - f49;
    float f51 = f50.x;
    float f52 = f50.y;
    float f53 = f50.z;
    float f54 = f49.x;
    float f55 = f49.y;
    float f56 = f49.z;
    vec3 f57 = ((((((((f43 - (f38 * f42)) * CB0[10].xyz) * f31) + (CB0[12].xyz * (f41 * clamp(-f29, 0.0, 1.0)))) + ((f12.xyz * (f12.w * 120.0)).xyz * 1.0)) + ((f43 - (f46 * f42)) * (((((((CB0[35].xyz * f51) + (CB0[37].xyz * f52)) + (CB0[39].xyz * f53)) + (CB0[36].xyz * f54)) + (CB0[38].xyz * f55)) + (CB0[40].xyz * f56)) + (((((((CB0[29].xyz * f51) + (CB0[31].xyz * f52)) + (CB0[33].xyz * f53)) + (CB0[30].xyz * f54)) + (CB0[32].xyz * f55)) + (CB0[34].xyz * f56)) * f14)))) + (CB0[27].xyz + (CB0[28].xyz * f14))) * f17) + (((f38 * (((f39 + (f39 * f39)) / (((f40 * f40) * ((f34 * 3.0) + 0.5)) * ((f33 * 0.75) + 0.25))) * f31)) * CB0[10].xyz) + ((mix(f24, textureLod(PrefilteredEnvTexture, f22, f21).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f20.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f14)) * f46) * f18));
    vec4 f58 = vec4(f57.x, f57.y, f57.z, vec4(0.0).w);
    f58.w = 1.0;
    float f59 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f60 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f59) * 5.0).xyz;
    bvec3 f61 = bvec3(CB0[13].w != 0.0);
    vec3 f62 = sqrt(clamp(mix(vec3(f61.x ? CB0[14].xyz.x : f60.x, f61.y ? CB0[14].xyz.y : f60.y, f61.z ? CB0[14].xyz.z : f60.z), f58.xyz, vec3(f59)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f63 = vec4(f62.x, f62.y, f62.z, f58.w);
    f63.w = 1.0;
    _entryPointOutput = f63;
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrefilteredEnvBlendTargetTexture=s2
//$$PrecomputedBRDFTexture=s11
//$$Tc2DiffuseMapTexture=s0
//$$DiffuseMapTexture=s3
