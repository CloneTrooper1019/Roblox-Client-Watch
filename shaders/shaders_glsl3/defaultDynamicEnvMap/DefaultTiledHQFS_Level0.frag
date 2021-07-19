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
    vec2 f3 = VARYING0 * CB2[0].x;
    vec4 f4 = texture(DiffuseMapTexture, f3);
    vec4 f5 = texture(NormalMapTexture, f3);
    vec2 f6 = f5.wy * 2.0;
    vec2 f7 = f6 - vec2(1.0);
    float f8 = sqrt(clamp(1.0 + dot(vec2(1.0) - f6, f7), 0.0, 1.0));
    vec4 f9 = texture(NormalDetailMapTexture, f3 * CB2[0].w);
    vec2 f10 = (vec3(f7, f8).xy + (vec3((f9.wy * 2.0) - vec2(1.0), 0.0).xy * CB2[1].x)).xy * f2;
    float f11 = f10.x;
    vec4 f12 = texture(SpecularMapTexture, f3);
    float f13 = gl_FrontFacing ? 1.0 : (-1.0);
    vec3 f14 = VARYING6.xyz * f13;
    vec3 f15 = VARYING5.xyz * f13;
    vec3 f16 = normalize(((f14 * f11) + (cross(f15, f14) * f10.y)) + (f15 * f8));
    vec3 f17 = vec4((mix(vec3(1.0), VARYING2.xyz, vec3(clamp(f4.w + CB2[2].w, 0.0, 1.0))) * f4.xyz) * (1.0 + (f11 * CB2[0].z)), VARYING2.w).xyz;
    vec3 f18 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f19 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f20 = VARYING3.yzx - (VARYING3.yzx * f19);
    vec4 f21 = texture(LightMapTexture, f20);
    vec4 f22 = texture(LightGridSkylightTexture, f20);
    vec4 f23 = vec4(clamp(f19, 0.0, 1.0));
    vec4 f24 = mix(f21, vec4(0.0), f23);
    vec4 f25 = mix(f22, vec4(1.0), f23);
    float f26 = f25.x;
    vec4 f27 = texture(ShadowMapTexture, f18.xy);
    float f28 = f18.z;
    vec3 f29 = (f17 * f17).xyz;
    float f30 = CB0[26].w * f2;
    float f31 = max(f12.y, 0.04500000178813934326171875);
    vec3 f32 = reflect(-f1, f16);
    float f33 = f31 * 5.0;
    vec3 f34 = vec4(f32, f33).xyz;
    vec3 f35 = textureLod(PrefilteredEnvIndoorTexture, f34, f33).xyz;
    vec3 f36;
    if (CB0[27].w == 0.0)
    {
        f36 = f35;
    }
    else
    {
        f36 = mix(f35, textureLod(PrefilteredEnvBlendTargetTexture, f34, f33).xyz, vec3(CB0[27].w));
    }
    vec4 f37 = texture(PrecomputedBRDFTexture, vec2(f31, max(9.9999997473787516355514526367188e-05, dot(f16, f1))));
    float f38 = f12.x * f30;
    vec3 f39 = mix(vec3(0.039999999105930328369140625), f29, vec3(f38));
    vec3 f40 = -CB0[11].xyz;
    float f41 = dot(f16, f40) * ((1.0 - ((step(f27.x, f28) * clamp(CB0[24].z + (CB0[24].w * abs(f28 - 0.5)), 0.0, 1.0)) * f27.y)) * f25.y);
    vec3 f42 = normalize(f40 + f1);
    float f43 = clamp(f41, 0.0, 1.0);
    float f44 = f31 * f31;
    float f45 = max(0.001000000047497451305389404296875, dot(f16, f42));
    float f46 = dot(f40, f42);
    float f47 = 1.0 - f46;
    float f48 = f47 * f47;
    float f49 = (f48 * f48) * f47;
    vec3 f50 = vec3(f49) + (f39 * (1.0 - f49));
    float f51 = f44 * f44;
    float f52 = (((f45 * f51) - f45) * f45) + 1.0;
    float f53 = 1.0 - f38;
    float f54 = f30 * f53;
    vec3 f55 = vec3(f53);
    float f56 = f37.x;
    float f57 = f37.y;
    vec3 f58 = ((f39 * f56) + vec3(f57)) / vec3(f56 + f57);
    vec3 f59 = f16 * f16;
    bvec3 f60 = lessThan(f16, vec3(0.0));
    vec3 f61 = vec3(f60.x ? f59.x : vec3(0.0).x, f60.y ? f59.y : vec3(0.0).y, f60.z ? f59.z : vec3(0.0).z);
    vec3 f62 = f59 - f61;
    float f63 = f62.x;
    float f64 = f62.y;
    float f65 = f62.z;
    float f66 = f61.x;
    float f67 = f61.y;
    float f68 = f61.z;
    vec3 f69 = ((((((((f55 - (f50 * f54)) * CB0[10].xyz) * f43) + (CB0[12].xyz * (f53 * clamp(-f41, 0.0, 1.0)))) + ((f24.xyz * (f24.w * 120.0)).xyz * 1.0)) + ((f55 - (f58 * f54)) * (((((((CB0[35].xyz * f63) + (CB0[37].xyz * f64)) + (CB0[39].xyz * f65)) + (CB0[36].xyz * f66)) + (CB0[38].xyz * f67)) + (CB0[40].xyz * f68)) + (((((((CB0[29].xyz * f63) + (CB0[31].xyz * f64)) + (CB0[33].xyz * f65)) + (CB0[30].xyz * f66)) + (CB0[32].xyz * f67)) + (CB0[34].xyz * f68)) * f26)))) + (CB0[27].xyz + (CB0[28].xyz * f26))) * f29) + (((f50 * (((f51 + (f51 * f51)) / (((f52 * f52) * ((f46 * 3.0) + 0.5)) * ((f45 * 0.75) + 0.25))) * f43)) * CB0[10].xyz) + ((mix(f36, textureLod(PrefilteredEnvTexture, f34, f33).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f32.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f26)) * f58) * f30));
    vec4 f70 = vec4(f69.x, f69.y, f69.z, vec4(0.0).w);
    f70.w = VARYING2.w;
    float f71 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f72 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f71) * 5.0).xyz;
    bvec3 f73 = bvec3(CB0[13].w != 0.0);
    vec3 f74 = sqrt(clamp(mix(vec3(f73.x ? CB0[14].xyz.x : f72.x, f73.y ? CB0[14].xyz.y : f72.y, f73.z ? CB0[14].xyz.z : f72.z), f70.xyz, vec3(f71)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f75 = vec4(f74.x, f74.y, f74.z, f70.w);
    f75.w = VARYING2.w;
    _entryPointOutput = f75;
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
//$$SpecularMapTexture=s5
