#version 150

#extension GL_ARB_shading_language_include : require
#include <Globals.h>
#include <SAParams.h>
uniform vec4 CB0[53];
uniform vec4 CB3[1];
uniform sampler2D ShadowMapTexture;
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform samplerCube PrefilteredEnvTexture;
uniform samplerCube PrefilteredEnvIndoorTexture;
uniform samplerCube PrefilteredEnvBlendTargetTexture;
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
    vec4 f6 = vec4(mix(vec4(f3.xyz * VARYING2.xyz, f5).xyz, f4.xyz, vec3(f5)), f5);
    vec4 f7 = vec4(f4.xyz, f5 * f5);
    bvec4 f8 = bvec4(CB3[0].x != 0.0);
    vec4 f9 = vec4(f8.x ? f6.x : f7.x, f8.y ? f6.y : f7.y, f8.z ? f6.z : f7.z, f8.w ? f6.w : f7.w);
    vec4 f10 = texture(NormalMapTexture, VARYING1);
    vec2 f11 = f10.wy * 2.0;
    vec2 f12 = f11 - vec2(1.0);
    float f13 = sqrt(clamp(1.0 + dot(vec2(1.0) - f11, f12), 0.0, 1.0));
    vec2 f14 = vec3(f12, f13).xy * f2;
    vec4 f15 = texture(SpecularMapTexture, VARYING1);
    float f16 = gl_FrontFacing ? 1.0 : (-1.0);
    vec3 f17 = VARYING6.xyz * f16;
    vec3 f18 = VARYING5.xyz * f16;
    vec3 f19 = normalize(((f17 * f14.x) + ((cross(f18, f17) * VARYING6.w) * f14.y)) + (f18 * f13));
    vec3 f20 = f9.xyz;
    vec3 f21 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f22 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f23 = VARYING3.yzx - (VARYING3.yzx * f22);
    vec4 f24 = texture(LightMapTexture, f23);
    vec4 f25 = texture(LightGridSkylightTexture, f23);
    vec4 f26 = vec4(clamp(f22, 0.0, 1.0));
    vec4 f27 = mix(f24, vec4(0.0), f26);
    vec4 f28 = mix(f25, vec4(1.0), f26);
    float f29 = f28.x;
    vec4 f30 = texture(ShadowMapTexture, f21.xy);
    float f31 = f21.z;
    vec3 f32 = (f20 * f20).xyz;
    float f33 = CB0[26].w * f2;
    float f34 = max(f15.y, 0.04500000178813934326171875);
    vec3 f35 = reflect(-f1, f19);
    float f36 = f34 * 5.0;
    vec3 f37 = vec4(f35, f36).xyz;
    vec3 f38 = textureLod(PrefilteredEnvIndoorTexture, f37, f36).xyz;
    vec3 f39;
    if (CB0[27].w == 0.0)
    {
        f39 = f38;
    }
    else
    {
        f39 = mix(f38, textureLod(PrefilteredEnvBlendTargetTexture, f37, f36).xyz, vec3(CB0[27].w));
    }
    vec4 f40 = texture(PrecomputedBRDFTexture, vec2(f34, max(9.9999997473787516355514526367188e-05, dot(f19, f1))));
    float f41 = f15.x * f33;
    vec3 f42 = mix(vec3(0.039999999105930328369140625), f32, vec3(f41));
    vec3 f43 = -CB0[11].xyz;
    float f44 = dot(f19, f43) * ((1.0 - ((step(f30.x, f31) * clamp(CB0[24].z + (CB0[24].w * abs(f31 - 0.5)), 0.0, 1.0)) * f30.y)) * f28.y);
    vec3 f45 = normalize(f43 + f1);
    float f46 = clamp(f44, 0.0, 1.0);
    float f47 = f34 * f34;
    float f48 = max(0.001000000047497451305389404296875, dot(f19, f45));
    float f49 = dot(f43, f45);
    float f50 = 1.0 - f49;
    float f51 = f50 * f50;
    float f52 = (f51 * f51) * f50;
    vec3 f53 = vec3(f52) + (f42 * (1.0 - f52));
    float f54 = f47 * f47;
    float f55 = (((f48 * f54) - f48) * f48) + 1.0;
    float f56 = 1.0 - f41;
    float f57 = f33 * f56;
    vec3 f58 = vec3(f56);
    float f59 = f40.x;
    float f60 = f40.y;
    vec3 f61 = ((f42 * f59) + vec3(f60)) / vec3(f59 + f60);
    vec3 f62 = f19 * f19;
    bvec3 f63 = lessThan(f19, vec3(0.0));
    vec3 f64 = vec3(f63.x ? f62.x : vec3(0.0).x, f63.y ? f62.y : vec3(0.0).y, f63.z ? f62.z : vec3(0.0).z);
    vec3 f65 = f62 - f64;
    float f66 = f65.x;
    float f67 = f65.y;
    float f68 = f65.z;
    float f69 = f64.x;
    float f70 = f64.y;
    float f71 = f64.z;
    vec3 f72 = ((((((((f58 - (f53 * f57)) * CB0[10].xyz) * f46) + (CB0[12].xyz * (f56 * clamp(-f44, 0.0, 1.0)))) + ((f27.xyz * (f27.w * 120.0)).xyz * 1.0)) + ((f58 - (f61 * f57)) * (((((((CB0[35].xyz * f66) + (CB0[37].xyz * f67)) + (CB0[39].xyz * f68)) + (CB0[36].xyz * f69)) + (CB0[38].xyz * f70)) + (CB0[40].xyz * f71)) + (((((((CB0[29].xyz * f66) + (CB0[31].xyz * f67)) + (CB0[33].xyz * f68)) + (CB0[30].xyz * f69)) + (CB0[32].xyz * f70)) + (CB0[34].xyz * f71)) * f29)))) + (CB0[27].xyz + (CB0[28].xyz * f29))) * f32) + (((f53 * (((f54 + (f54 * f54)) / (((f55 * f55) * ((f49 * 3.0) + 0.5)) * ((f48 * 0.75) + 0.25))) * f46)) * CB0[10].xyz) + ((mix(f39, textureLod(PrefilteredEnvTexture, f37, f36).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f35.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f29)) * f61) * f33));
    float f73 = f9.w;
    vec4 f74 = vec4(f72.x, f72.y, f72.z, vec4(0.0).w);
    f74.w = f73;
    float f75 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f76 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f75) * 5.0).xyz;
    bvec3 f77 = bvec3(CB0[13].w != 0.0);
    vec3 f78 = sqrt(clamp(mix(vec3(f77.x ? CB0[14].xyz.x : f76.x, f77.y ? CB0[14].xyz.y : f76.y, f77.z ? CB0[14].xyz.z : f76.z), f74.xyz, vec3(f75)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f79 = vec4(f78.x, f78.y, f78.z, f74.w);
    f79.w = f73;
    _entryPointOutput = f79;
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrefilteredEnvBlendTargetTexture=s2
//$$PrecomputedBRDFTexture=s11
//$$DiffuseMapTexture=s3
//$$Tc2DiffuseMapTexture=s0
//$$NormalMapTexture=s4
//$$SpecularMapTexture=s5
