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
uniform sampler2DArray SpecularMapTexture;
uniform sampler2DArray AlbedoMapTexture;

in vec4 VARYING0;
in vec4 VARYING1;
in vec4 VARYING2;
in vec4 VARYING3;
in vec3 VARYING4;
in vec4 VARYING5;
in vec3 VARYING6;
in vec3 VARYING8;
out vec4 _entryPointOutput;

void main()
{
    vec3 f0 = vec3(VARYING1.xy, VARYING2.x);
    vec3 f1 = vec3(VARYING1.zw, VARYING2.z);
    vec4 f2 = ((texture(SpecularMapTexture, f0) * VARYING0.x) + (texture(SpecularMapTexture, f1) * VARYING0.y)) + (texture(SpecularMapTexture, VARYING3.xyz) * VARYING0.z);
    vec4 f3 = ((texture(AlbedoMapTexture, f0).yxzw * VARYING0.x) + (texture(AlbedoMapTexture, f1).yxzw * VARYING0.y)) + (texture(AlbedoMapTexture, VARYING3.xyz).yxzw * VARYING0.z);
    vec2 f4 = f3.yz - vec2(0.5);
    float f5 = f3.x;
    float f6 = f5 - f4.y;
    vec3 f7 = vec4(vec3(f6, f5, f6) + (vec3(f4.xyx) * vec3(1.0, 1.0, -1.0)), 0.0).xyz;
    float f8 = clamp(1.0 - (VARYING5.w * CB0[23].y), 0.0, 1.0);
    vec3 f9 = normalize(VARYING6);
    vec3 f10 = VARYING5.xyz - (CB0[11].xyz * 0.001000000047497451305389404296875);
    float f11 = clamp(dot(step(CB0[19].xyz, abs(VARYING4 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f12 = VARYING4.yzx - (VARYING4.yzx * f11);
    vec4 f13 = vec4(clamp(f11, 0.0, 1.0));
    vec4 f14 = mix(texture(LightMapTexture, f12), vec4(0.0), f13);
    vec4 f15 = mix(texture(LightGridSkylightTexture, f12), vec4(1.0), f13);
    vec3 f16 = (f14.xyz * (f14.w * 120.0)).xyz;
    float f17 = f15.x;
    vec4 f18 = texture(ShadowMapTexture, f10.xy);
    float f19 = f10.z;
    vec3 f20 = normalize(VARYING8);
    vec3 f21 = (f7 * f7).xyz;
    float f22 = f2.y;
    float f23 = CB0[26].w * f8;
    vec3 f24 = reflect(-f20, f9);
    vec3 f25 = -CB0[11].xyz;
    float f26 = dot(f9, f25) * ((1.0 - ((step(f18.x, f19) * clamp(CB0[24].z + (CB0[24].w * abs(f19 - 0.5)), 0.0, 1.0)) * f18.y)) * f15.y);
    vec3 f27 = normalize(f25 + f20);
    float f28 = clamp(f26, 0.0, 1.0);
    float f29 = f22 * f22;
    float f30 = max(0.001000000047497451305389404296875, dot(f9, f27));
    float f31 = dot(f25, f27);
    float f32 = 1.0 - f31;
    float f33 = f32 * f32;
    float f34 = (f33 * f33) * f32;
    vec3 f35 = vec3(f34) + (vec3(0.039999999105930328369140625) * (1.0 - f34));
    float f36 = f29 * f29;
    float f37 = (((f30 * f36) - f30) * f30) + 1.0;
    float f38 = f22 * 5.0;
    vec3 f39 = vec4(f24, f38).xyz;
    vec4 f40 = texture(PrecomputedBRDFTexture, vec2(f22, max(9.9999997473787516355514526367188e-05, dot(f9, f20))));
    float f41 = f40.x;
    float f42 = f40.y;
    vec3 f43 = ((vec3(0.039999999105930328369140625) * f41) + vec3(f42)) / vec3(f41 + f42);
    vec3 f44 = f43 * f23;
    vec3 f45 = f9 * f9;
    bvec3 f46 = lessThan(f9, vec3(0.0));
    vec3 f47 = vec3(f46.x ? f45.x : vec3(0.0).x, f46.y ? f45.y : vec3(0.0).y, f46.z ? f45.z : vec3(0.0).z);
    vec3 f48 = f45 - f47;
    float f49 = f48.x;
    float f50 = f48.y;
    float f51 = f48.z;
    float f52 = f47.x;
    float f53 = f47.y;
    float f54 = f47.z;
    vec3 f55 = (mix(textureLod(PrefilteredEnvIndoorTexture, f39, f38).xyz * f16, textureLod(PrefilteredEnvTexture, f39, f38).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f24.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f17)) * f43) * f23;
    vec3 f56 = (((((((((vec3(1.0) - (f35 * f23)) * CB0[10].xyz) * f28) + (CB0[12].xyz * clamp(-f26, 0.0, 1.0))) + ((vec3(1.0) - f44) * (((((((CB0[35].xyz * f49) + (CB0[37].xyz * f50)) + (CB0[39].xyz * f51)) + (CB0[36].xyz * f52)) + (CB0[38].xyz * f53)) + (CB0[40].xyz * f54)) + (((((((CB0[29].xyz * f49) + (CB0[31].xyz * f50)) + (CB0[33].xyz * f51)) + (CB0[30].xyz * f52)) + (CB0[32].xyz * f53)) + (CB0[34].xyz * f54)) * f17)))) + (CB0[27].xyz + (CB0[28].xyz * f17))) + vec3((f2.z * 2.0) * f8)) * f21) + (((((f35 * (((f36 + (f36 * f36)) / (((f37 * f37) * ((f31 * 3.0) + 0.5)) * ((f30 * 0.75) + 0.25))) * f28)) * CB0[10].xyz) * f8) * VARYING0.w) + f55)) + ((f16 * mix(f21, f55 * (1.0 / (max(max(f55.x, f55.y), f55.z) + 0.00999999977648258209228515625)), f44 * (f23 * (1.0 - f17)))) * 1.0);
    vec4 f57 = vec4(f56.x, f56.y, f56.z, vec4(0.0).w);
    f57.w = 1.0;
    float f58 = clamp(exp2((CB0[13].z * VARYING5.w) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f59 = textureLod(PrefilteredEnvTexture, vec4(-VARYING8, 0.0).xyz, max(CB0[13].y, f58) * 5.0).xyz;
    bvec3 f60 = bvec3(CB0[13].w != 0.0);
    vec3 f61 = sqrt(clamp(mix(vec3(f60.x ? CB0[14].xyz.x : f59.x, f60.y ? CB0[14].xyz.y : f59.y, f60.z ? CB0[14].xyz.z : f59.z), f57.xyz, vec3(f58)).xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    _entryPointOutput = vec4(f61.x, f61.y, f61.z, f57.w);
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrecomputedBRDFTexture=s11
//$$SpecularMapTexture=s2
//$$AlbedoMapTexture=s0
