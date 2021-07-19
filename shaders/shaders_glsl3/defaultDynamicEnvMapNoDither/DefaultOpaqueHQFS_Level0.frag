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
    vec4 f2 = texture(DiffuseMapTexture, VARYING0);
    vec3 f3 = normalize(VARYING5.xyz) * (gl_FrontFacing ? 1.0 : (-1.0));
    vec3 f4 = (f2 * VARYING2).xyz;
    vec3 f5 = VARYING6.xyz - (CB0[11].xyz * VARYING3.w);
    float f6 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f7 = VARYING3.yzx - (VARYING3.yzx * f6);
    vec4 f8 = texture(LightMapTexture, f7);
    vec4 f9 = texture(LightGridSkylightTexture, f7);
    vec4 f10 = vec4(clamp(f6, 0.0, 1.0));
    vec4 f11 = mix(f8, vec4(0.0), f10);
    vec4 f12 = mix(f9, vec4(1.0), f10);
    float f13 = f12.x;
    vec4 f14 = texture(ShadowMapTexture, f5.xy);
    float f15 = f5.z;
    vec3 f16 = (f4 * f4).xyz;
    float f17 = CB0[26].w * clamp(1.0 - (VARYING4.w * CB0[23].y), 0.0, 1.0);
    float f18 = max(VARYING5.w, 0.04500000178813934326171875);
    vec3 f19 = reflect(-f1, f3);
    float f20 = f18 * 5.0;
    vec3 f21 = vec4(f19, f20).xyz;
    vec3 f22 = textureLod(PrefilteredEnvIndoorTexture, f21, f20).xyz;
    vec3 f23;
    if (CB0[27].w == 0.0)
    {
        f23 = f22;
    }
    else
    {
        f23 = mix(f22, textureLod(PrefilteredEnvBlendTargetTexture, f21, f20).xyz, vec3(CB0[27].w));
    }
    vec4 f24 = texture(PrecomputedBRDFTexture, vec2(f18, max(9.9999997473787516355514526367188e-05, dot(f3, f1))));
    float f25 = VARYING6.w * f17;
    vec3 f26 = mix(vec3(0.039999999105930328369140625), f16, vec3(f25));
    vec3 f27 = -CB0[11].xyz;
    float f28 = dot(f3, f27) * ((1.0 - ((step(f14.x, f15) * clamp(CB0[24].z + (CB0[24].w * abs(f15 - 0.5)), 0.0, 1.0)) * f14.y)) * f12.y);
    vec3 f29 = normalize(f27 + f1);
    float f30 = clamp(f28, 0.0, 1.0);
    float f31 = f18 * f18;
    float f32 = max(0.001000000047497451305389404296875, dot(f3, f29));
    float f33 = dot(f27, f29);
    float f34 = 1.0 - f33;
    float f35 = f34 * f34;
    float f36 = (f35 * f35) * f34;
    vec3 f37 = vec3(f36) + (f26 * (1.0 - f36));
    float f38 = f31 * f31;
    float f39 = (((f32 * f38) - f32) * f32) + 1.0;
    float f40 = 1.0 - f25;
    float f41 = f17 * f40;
    vec3 f42 = vec3(f40);
    float f43 = f24.x;
    float f44 = f24.y;
    vec3 f45 = ((f26 * f43) + vec3(f44)) / vec3(f43 + f44);
    vec3 f46 = f3 * f3;
    bvec3 f47 = lessThan(f3, vec3(0.0));
    vec3 f48 = vec3(f47.x ? f46.x : vec3(0.0).x, f47.y ? f46.y : vec3(0.0).y, f47.z ? f46.z : vec3(0.0).z);
    vec3 f49 = f46 - f48;
    float f50 = f49.x;
    float f51 = f49.y;
    float f52 = f49.z;
    float f53 = f48.x;
    float f54 = f48.y;
    float f55 = f48.z;
    vec3 f56 = ((((((((f42 - (f37 * f41)) * CB0[10].xyz) * f30) + (CB0[12].xyz * (f40 * clamp(-f28, 0.0, 1.0)))) + ((f11.xyz * (f11.w * 120.0)).xyz * 1.0)) + ((f42 - (f45 * f41)) * (((((((CB0[35].xyz * f50) + (CB0[37].xyz * f51)) + (CB0[39].xyz * f52)) + (CB0[36].xyz * f53)) + (CB0[38].xyz * f54)) + (CB0[40].xyz * f55)) + (((((((CB0[29].xyz * f50) + (CB0[31].xyz * f51)) + (CB0[33].xyz * f52)) + (CB0[30].xyz * f53)) + (CB0[32].xyz * f54)) + (CB0[34].xyz * f55)) * f13)))) + (CB0[27].xyz + (CB0[28].xyz * f13))) * f16) + (((f37 * (((f38 + (f38 * f38)) / (((f39 * f39) * ((f33 * 3.0) + 0.5)) * ((f32 * 0.75) + 0.25))) * f30)) * CB0[10].xyz) + ((mix(f23, textureLod(PrefilteredEnvTexture, f21, f20).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f19.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f13)) * f45) * f17));
    vec4 f57 = vec4(f56.x, f56.y, f56.z, vec4(0.0).w);
    f57.w = 1.0;
    float f58 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f59 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f58) * 5.0).xyz;
    bvec3 f60 = bvec3(CB0[13].w != 0.0);
    vec3 f61 = sqrt(clamp(mix(vec3(f60.x ? CB0[14].xyz.x : f59.x, f60.y ? CB0[14].xyz.y : f59.y, f60.z ? CB0[14].xyz.z : f59.z), f57.xyz, vec3(f58)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f62 = vec4(f61.x, f61.y, f61.z, f57.w);
    f62.w = 1.0;
    _entryPointOutput = f62;
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrefilteredEnvBlendTargetTexture=s2
//$$PrecomputedBRDFTexture=s11
//$$DiffuseMapTexture=s3
