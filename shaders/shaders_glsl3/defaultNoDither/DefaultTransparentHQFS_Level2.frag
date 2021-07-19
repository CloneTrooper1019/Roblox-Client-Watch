#version 150

#extension GL_ARB_shading_language_include : require
#include <Globals.h>
uniform vec4 CB0[53];
uniform sampler2D ShadowMapTexture;
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
    vec3 f5 = f3.xyz;
    vec3 f6 = VARYING6.xyz - (CB0[11].xyz * VARYING3.w);
    float f7 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f8 = VARYING3.yzx - (VARYING3.yzx * f7);
    vec4 f9 = vec4(clamp(f7, 0.0, 1.0));
    vec4 f10 = mix(texture(LightMapTexture, f8), vec4(0.0), f9);
    vec4 f11 = mix(texture(LightGridSkylightTexture, f8), vec4(1.0), f9);
    vec3 f12 = (f10.xyz * (f10.w * 120.0)).xyz;
    float f13 = f11.x;
    vec4 f14 = texture(ShadowMapTexture, f6.xy);
    float f15 = f6.z;
    vec3 f16 = (f5 * f5).xyz;
    float f17 = CB0[26].w * clamp(1.0 - (VARYING4.w * CB0[23].y), 0.0, 1.0);
    float f18 = max(VARYING5.w, 0.04500000178813934326171875);
    vec3 f19 = reflect(-f1, f4);
    float f20 = f18 * 5.0;
    vec3 f21 = vec4(f19, f20).xyz;
    vec4 f22 = texture(PrecomputedBRDFTexture, vec2(f18, max(9.9999997473787516355514526367188e-05, dot(f4, f1))));
    float f23 = VARYING6.w * f17;
    vec3 f24 = mix(vec3(0.039999999105930328369140625), f16, vec3(f23));
    vec3 f25 = -CB0[11].xyz;
    float f26 = dot(f4, f25) * ((1.0 - ((step(f14.x, f15) * clamp(CB0[24].z + (CB0[24].w * abs(f15 - 0.5)), 0.0, 1.0)) * f14.y)) * f11.y);
    vec3 f27 = normalize(f25 + f1);
    float f28 = clamp(f26, 0.0, 1.0);
    float f29 = f18 * f18;
    float f30 = max(0.001000000047497451305389404296875, dot(f4, f27));
    float f31 = dot(f25, f27);
    float f32 = 1.0 - f31;
    float f33 = f32 * f32;
    float f34 = (f33 * f33) * f32;
    vec3 f35 = vec3(f34) + (f24 * (1.0 - f34));
    float f36 = f29 * f29;
    float f37 = (((f30 * f36) - f30) * f30) + 1.0;
    float f38 = 1.0 - f23;
    float f39 = f17 * f38;
    vec3 f40 = vec3(f38);
    float f41 = f22.x;
    float f42 = f22.y;
    vec3 f43 = ((f24 * f41) + vec3(f42)) / vec3(f41 + f42);
    vec3 f44 = f40 - (f43 * f39);
    vec3 f45 = f4 * f4;
    bvec3 f46 = lessThan(f4, vec3(0.0));
    vec3 f47 = vec3(f46.x ? f45.x : vec3(0.0).x, f46.y ? f45.y : vec3(0.0).y, f46.z ? f45.z : vec3(0.0).z);
    vec3 f48 = f45 - f47;
    float f49 = f48.x;
    float f50 = f48.y;
    float f51 = f48.z;
    float f52 = f47.x;
    float f53 = f47.y;
    float f54 = f47.z;
    vec3 f55 = (mix(textureLod(PrefilteredEnvIndoorTexture, f21, f20).xyz * f12, textureLod(PrefilteredEnvTexture, f21, f20).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f19.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f13)) * f43) * f17;
    vec3 f56 = ((((((((f40 - (f35 * f39)) * CB0[10].xyz) * f28) + (CB0[12].xyz * (f38 * clamp(-f26, 0.0, 1.0)))) + (f44 * (((((((CB0[35].xyz * f49) + (CB0[37].xyz * f50)) + (CB0[39].xyz * f51)) + (CB0[36].xyz * f52)) + (CB0[38].xyz * f53)) + (CB0[40].xyz * f54)) + (((((((CB0[29].xyz * f49) + (CB0[31].xyz * f50)) + (CB0[33].xyz * f51)) + (CB0[30].xyz * f52)) + (CB0[32].xyz * f53)) + (CB0[34].xyz * f54)) * f13)))) + (CB0[27].xyz + (CB0[28].xyz * f13))) * f16) + (((f35 * (((f36 + (f36 * f36)) / (((f37 * f37) * ((f31 * 3.0) + 0.5)) * ((f30 * 0.75) + 0.25))) * f28)) * CB0[10].xyz) + f55)) + ((f12 * mix(f16, f55 * (1.0 / (max(max(f55.x, f55.y), f55.z) + 0.00999999977648258209228515625)), (vec3(1.0) - f44) * (f17 * (1.0 - f13)))) * 1.0);
    float f57 = f3.w;
    vec4 f58 = vec4(f56.x, f56.y, f56.z, vec4(0.0).w);
    f58.w = f57;
    float f59 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f60 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f59) * 5.0).xyz;
    bvec3 f61 = bvec3(CB0[13].w != 0.0);
    vec3 f62 = sqrt(clamp(mix(vec3(f61.x ? CB0[14].xyz.x : f60.x, f61.y ? CB0[14].xyz.y : f60.y, f61.z ? CB0[14].xyz.z : f60.z), f58.xyz, vec3(f59)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f63 = vec4(f62.x, f62.y, f62.z, f58.w);
    f63.w = f57;
    _entryPointOutput = f63;
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrecomputedBRDFTexture=s11
//$$Tc2DiffuseMapTexture=s0
//$$DiffuseMapTexture=s3
