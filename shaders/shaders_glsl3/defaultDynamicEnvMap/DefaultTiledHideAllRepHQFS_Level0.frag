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
    vec4 f4 = texture(DiffuseMapTexture, f3 * CB2[1].y);
    vec4 f5 = texture(DiffuseMapTexture, f3);
    vec4 f6 = mix(f4, f5, vec4(clamp((clamp(1.0 - (VARYING4.w * 0.0033333334140479564666748046875), 0.0, 1.0) * CB2[3].x) - (CB2[2].x * CB2[3].x), 0.0, 1.0)));
    vec4 f7 = texture(NormalMapTexture, f3 * CB2[1].z);
    vec4 f8 = texture(NormalMapTexture, f3);
    vec2 f9 = mix(f7, f8, vec4(clamp((f2 * CB2[3].y) - (CB2[2].y * CB2[3].y), 0.0, 1.0))).wy * 2.0;
    vec2 f10 = f9 - vec2(1.0);
    float f11 = sqrt(clamp(1.0 + dot(vec2(1.0) - f9, f10), 0.0, 1.0));
    vec4 f12 = texture(NormalDetailMapTexture, f3 * CB2[0].w);
    vec2 f13 = (vec3(f10, f11).xy + (vec3((f12.wy * 2.0) - vec2(1.0), 0.0).xy * CB2[1].x)).xy * f2;
    float f14 = f13.x;
    vec4 f15 = texture(SpecularMapTexture, f3 * CB2[1].w);
    vec4 f16 = texture(SpecularMapTexture, f3);
    vec4 f17 = mix(f15, f16, vec4(clamp((f2 * CB2[3].z) - (CB2[2].z * CB2[3].z), 0.0, 1.0)));
    float f18 = gl_FrontFacing ? 1.0 : (-1.0);
    vec3 f19 = VARYING6.xyz * f18;
    vec3 f20 = VARYING5.xyz * f18;
    vec3 f21 = normalize(((f19 * f14) + (cross(f20, f19) * f13.y)) + (f20 * f11));
    vec3 f22 = vec4((mix(vec3(1.0), VARYING2.xyz, vec3(clamp(f6.w + CB2[2].w, 0.0, 1.0))) * f6.xyz) * (1.0 + (f14 * CB2[0].z)), VARYING2.w).xyz;
    vec3 f23 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f24 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f25 = VARYING3.yzx - (VARYING3.yzx * f24);
    vec4 f26 = texture(LightMapTexture, f25);
    vec4 f27 = texture(LightGridSkylightTexture, f25);
    vec4 f28 = vec4(clamp(f24, 0.0, 1.0));
    vec4 f29 = mix(f26, vec4(0.0), f28);
    vec4 f30 = mix(f27, vec4(1.0), f28);
    float f31 = f30.x;
    vec4 f32 = texture(ShadowMapTexture, f23.xy);
    float f33 = f23.z;
    vec3 f34 = (f22 * f22).xyz;
    float f35 = CB0[26].w * f2;
    float f36 = max(f17.y, 0.04500000178813934326171875);
    vec3 f37 = reflect(-f1, f21);
    float f38 = f36 * 5.0;
    vec3 f39 = vec4(f37, f38).xyz;
    vec3 f40 = textureLod(PrefilteredEnvIndoorTexture, f39, f38).xyz;
    vec3 f41;
    if (CB0[27].w == 0.0)
    {
        f41 = f40;
    }
    else
    {
        f41 = mix(f40, textureLod(PrefilteredEnvBlendTargetTexture, f39, f38).xyz, vec3(CB0[27].w));
    }
    vec4 f42 = texture(PrecomputedBRDFTexture, vec2(f36, max(9.9999997473787516355514526367188e-05, dot(f21, f1))));
    float f43 = f17.x * f35;
    vec3 f44 = mix(vec3(0.039999999105930328369140625), f34, vec3(f43));
    vec3 f45 = -CB0[11].xyz;
    float f46 = dot(f21, f45) * ((1.0 - ((step(f32.x, f33) * clamp(CB0[24].z + (CB0[24].w * abs(f33 - 0.5)), 0.0, 1.0)) * f32.y)) * f30.y);
    vec3 f47 = normalize(f45 + f1);
    float f48 = clamp(f46, 0.0, 1.0);
    float f49 = f36 * f36;
    float f50 = max(0.001000000047497451305389404296875, dot(f21, f47));
    float f51 = dot(f45, f47);
    float f52 = 1.0 - f51;
    float f53 = f52 * f52;
    float f54 = (f53 * f53) * f52;
    vec3 f55 = vec3(f54) + (f44 * (1.0 - f54));
    float f56 = f49 * f49;
    float f57 = (((f50 * f56) - f50) * f50) + 1.0;
    float f58 = 1.0 - f43;
    float f59 = f35 * f58;
    vec3 f60 = vec3(f58);
    float f61 = f42.x;
    float f62 = f42.y;
    vec3 f63 = ((f44 * f61) + vec3(f62)) / vec3(f61 + f62);
    vec3 f64 = f21 * f21;
    bvec3 f65 = lessThan(f21, vec3(0.0));
    vec3 f66 = vec3(f65.x ? f64.x : vec3(0.0).x, f65.y ? f64.y : vec3(0.0).y, f65.z ? f64.z : vec3(0.0).z);
    vec3 f67 = f64 - f66;
    float f68 = f67.x;
    float f69 = f67.y;
    float f70 = f67.z;
    float f71 = f66.x;
    float f72 = f66.y;
    float f73 = f66.z;
    vec3 f74 = ((((((((f60 - (f55 * f59)) * CB0[10].xyz) * f48) + (CB0[12].xyz * (f58 * clamp(-f46, 0.0, 1.0)))) + ((f29.xyz * (f29.w * 120.0)).xyz * 1.0)) + ((f60 - (f63 * f59)) * (((((((CB0[35].xyz * f68) + (CB0[37].xyz * f69)) + (CB0[39].xyz * f70)) + (CB0[36].xyz * f71)) + (CB0[38].xyz * f72)) + (CB0[40].xyz * f73)) + (((((((CB0[29].xyz * f68) + (CB0[31].xyz * f69)) + (CB0[33].xyz * f70)) + (CB0[30].xyz * f71)) + (CB0[32].xyz * f72)) + (CB0[34].xyz * f73)) * f31)))) + (CB0[27].xyz + (CB0[28].xyz * f31))) * f34) + (((f55 * (((f56 + (f56 * f56)) / (((f57 * f57) * ((f51 * 3.0) + 0.5)) * ((f50 * 0.75) + 0.25))) * f48)) * CB0[10].xyz) + ((mix(f41, textureLod(PrefilteredEnvTexture, f39, f38).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f37.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f31)) * f63) * f35));
    vec4 f75 = vec4(f74.x, f74.y, f74.z, vec4(0.0).w);
    f75.w = VARYING2.w;
    float f76 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f77 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f76) * 5.0).xyz;
    bvec3 f78 = bvec3(CB0[13].w != 0.0);
    vec3 f79 = sqrt(clamp(mix(vec3(f78.x ? CB0[14].xyz.x : f77.x, f78.y ? CB0[14].xyz.y : f77.y, f78.z ? CB0[14].xyz.z : f77.z), f75.xyz, vec3(f76)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f80 = vec4(f79.x, f79.y, f79.z, f75.w);
    f80.w = VARYING2.w;
    _entryPointOutput = f80;
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
