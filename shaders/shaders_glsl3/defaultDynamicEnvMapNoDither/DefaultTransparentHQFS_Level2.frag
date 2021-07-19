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
    vec4 f4 = mix(f3, f2, vec4(f2.w)) * VARYING2;
    vec3 f5 = normalize(VARYING5.xyz) * (gl_FrontFacing ? 1.0 : (-1.0));
    vec3 f6 = f4.xyz;
    vec3 f7 = VARYING6.xyz - (CB0[11].xyz * VARYING3.w);
    float f8 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f9 = VARYING3.yzx - (VARYING3.yzx * f8);
    vec4 f10 = texture(LightMapTexture, f9);
    vec4 f11 = texture(LightGridSkylightTexture, f9);
    vec4 f12 = vec4(clamp(f8, 0.0, 1.0));
    vec4 f13 = mix(f10, vec4(0.0), f12);
    vec4 f14 = mix(f11, vec4(1.0), f12);
    float f15 = f14.x;
    vec4 f16 = texture(ShadowMapTexture, f7.xy);
    float f17 = f7.z;
    vec3 f18 = (f6 * f6).xyz;
    float f19 = CB0[26].w * clamp(1.0 - (VARYING4.w * CB0[23].y), 0.0, 1.0);
    float f20 = max(VARYING5.w, 0.04500000178813934326171875);
    vec3 f21 = reflect(-f1, f5);
    float f22 = f20 * 5.0;
    vec3 f23 = vec4(f21, f22).xyz;
    vec3 f24 = textureLod(PrefilteredEnvIndoorTexture, f23, f22).xyz;
    vec3 f25;
    if (CB0[27].w == 0.0)
    {
        f25 = f24;
    }
    else
    {
        f25 = mix(f24, textureLod(PrefilteredEnvBlendTargetTexture, f23, f22).xyz, vec3(CB0[27].w));
    }
    vec4 f26 = texture(PrecomputedBRDFTexture, vec2(f20, max(9.9999997473787516355514526367188e-05, dot(f5, f1))));
    float f27 = VARYING6.w * f19;
    vec3 f28 = mix(vec3(0.039999999105930328369140625), f18, vec3(f27));
    vec3 f29 = -CB0[11].xyz;
    float f30 = dot(f5, f29) * ((1.0 - ((step(f16.x, f17) * clamp(CB0[24].z + (CB0[24].w * abs(f17 - 0.5)), 0.0, 1.0)) * f16.y)) * f14.y);
    vec3 f31 = normalize(f29 + f1);
    float f32 = clamp(f30, 0.0, 1.0);
    float f33 = f20 * f20;
    float f34 = max(0.001000000047497451305389404296875, dot(f5, f31));
    float f35 = dot(f29, f31);
    float f36 = 1.0 - f35;
    float f37 = f36 * f36;
    float f38 = (f37 * f37) * f36;
    vec3 f39 = vec3(f38) + (f28 * (1.0 - f38));
    float f40 = f33 * f33;
    float f41 = (((f34 * f40) - f34) * f34) + 1.0;
    float f42 = 1.0 - f27;
    float f43 = f19 * f42;
    vec3 f44 = vec3(f42);
    float f45 = f26.x;
    float f46 = f26.y;
    vec3 f47 = ((f28 * f45) + vec3(f46)) / vec3(f45 + f46);
    vec3 f48 = f5 * f5;
    bvec3 f49 = lessThan(f5, vec3(0.0));
    vec3 f50 = vec3(f49.x ? f48.x : vec3(0.0).x, f49.y ? f48.y : vec3(0.0).y, f49.z ? f48.z : vec3(0.0).z);
    vec3 f51 = f48 - f50;
    float f52 = f51.x;
    float f53 = f51.y;
    float f54 = f51.z;
    float f55 = f50.x;
    float f56 = f50.y;
    float f57 = f50.z;
    vec3 f58 = ((((((((f44 - (f39 * f43)) * CB0[10].xyz) * f32) + (CB0[12].xyz * (f42 * clamp(-f30, 0.0, 1.0)))) + ((f13.xyz * (f13.w * 120.0)).xyz * 1.0)) + ((f44 - (f47 * f43)) * (((((((CB0[35].xyz * f52) + (CB0[37].xyz * f53)) + (CB0[39].xyz * f54)) + (CB0[36].xyz * f55)) + (CB0[38].xyz * f56)) + (CB0[40].xyz * f57)) + (((((((CB0[29].xyz * f52) + (CB0[31].xyz * f53)) + (CB0[33].xyz * f54)) + (CB0[30].xyz * f55)) + (CB0[32].xyz * f56)) + (CB0[34].xyz * f57)) * f15)))) + (CB0[27].xyz + (CB0[28].xyz * f15))) * f18) + (((f39 * (((f40 + (f40 * f40)) / (((f41 * f41) * ((f35 * 3.0) + 0.5)) * ((f34 * 0.75) + 0.25))) * f32)) * CB0[10].xyz) + ((mix(f25, textureLod(PrefilteredEnvTexture, f23, f22).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f21.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f15)) * f47) * f19));
    float f59 = f4.w;
    vec4 f60 = vec4(f58.x, f58.y, f58.z, vec4(0.0).w);
    f60.w = f59;
    float f61 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f62 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f61) * 5.0).xyz;
    bvec3 f63 = bvec3(CB0[13].w != 0.0);
    vec3 f64 = sqrt(clamp(mix(vec3(f63.x ? CB0[14].xyz.x : f62.x, f63.y ? CB0[14].xyz.y : f62.y, f63.z ? CB0[14].xyz.z : f62.z), f60.xyz, vec3(f61)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f65 = vec4(f64.x, f64.y, f64.z, f60.w);
    f65.w = f59;
    _entryPointOutput = f65;
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
