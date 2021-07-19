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
in vec4 VARYING9;
out vec4 _entryPointOutput;

void main()
{
    vec3 f0 = vec3(VARYING1.xy, VARYING2.x);
    vec3 f1 = vec3(VARYING1.zw, VARYING2.z);
    vec4 f2 = ((texture(SpecularMapTexture, f0) * VARYING0.x) + (texture(SpecularMapTexture, f1) * VARYING0.y)) + (texture(SpecularMapTexture, VARYING3.xyz) * VARYING0.z);
    vec4 f3 = ((texture(AlbedoMapTexture, f0).yxzw * VARYING0.x) + (texture(AlbedoMapTexture, f1).yxzw * VARYING0.y)) + (texture(AlbedoMapTexture, VARYING3.xyz).yxzw * VARYING0.z);
    vec2 f4 = f3.yz - vec2(0.5);
    float f5 = VARYING9.x * f3.x;
    float f6 = f4.x;
    float f7 = f4.y;
    float f8 = (VARYING9.y * f6) - (VARYING9.z * f7);
    float f9 = (VARYING9.z * f6) + (VARYING9.y * f7);
    float f10 = f5 - f9;
    vec3 f11 = vec4(vec3(f10, f5, f10) + (vec3(f8, f9, f8) * vec3(1.0, 1.0, -1.0)), 0.0).xyz;
    float f12 = clamp(1.0 - (VARYING5.w * CB0[23].y), 0.0, 1.0);
    vec3 f13 = normalize(VARYING6);
    vec3 f14 = VARYING5.xyz - (CB0[11].xyz * 0.001000000047497451305389404296875);
    float f15 = clamp(dot(step(CB0[19].xyz, abs(VARYING4 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f16 = VARYING4.yzx - (VARYING4.yzx * f15);
    vec4 f17 = vec4(clamp(f15, 0.0, 1.0));
    vec4 f18 = mix(texture(LightMapTexture, f16), vec4(0.0), f17);
    vec4 f19 = mix(texture(LightGridSkylightTexture, f16), vec4(1.0), f17);
    vec3 f20 = (f18.xyz * (f18.w * 120.0)).xyz;
    float f21 = f19.x;
    vec4 f22 = texture(ShadowMapTexture, f14.xy);
    float f23 = f14.z;
    vec3 f24 = normalize(VARYING8);
    vec3 f25 = (f11 * f11).xyz;
    float f26 = f2.y;
    float f27 = CB0[26].w * f12;
    vec3 f28 = reflect(-f24, f13);
    vec3 f29 = -CB0[11].xyz;
    float f30 = dot(f13, f29) * ((1.0 - ((step(f22.x, f23) * clamp(CB0[24].z + (CB0[24].w * abs(f23 - 0.5)), 0.0, 1.0)) * f22.y)) * f19.y);
    vec3 f31 = normalize(f29 + f24);
    float f32 = clamp(f30, 0.0, 1.0);
    float f33 = f26 * f26;
    float f34 = max(0.001000000047497451305389404296875, dot(f13, f31));
    float f35 = dot(f29, f31);
    float f36 = 1.0 - f35;
    float f37 = f36 * f36;
    float f38 = (f37 * f37) * f36;
    vec3 f39 = vec3(f38) + (vec3(0.039999999105930328369140625) * (1.0 - f38));
    float f40 = f33 * f33;
    float f41 = (((f34 * f40) - f34) * f34) + 1.0;
    float f42 = f26 * 5.0;
    vec3 f43 = vec4(f28, f42).xyz;
    vec4 f44 = texture(PrecomputedBRDFTexture, vec2(f26, max(9.9999997473787516355514526367188e-05, dot(f13, f24))));
    float f45 = f44.x;
    float f46 = f44.y;
    vec3 f47 = ((vec3(0.039999999105930328369140625) * f45) + vec3(f46)) / vec3(f45 + f46);
    vec3 f48 = f47 * f27;
    vec3 f49 = f13 * f13;
    bvec3 f50 = lessThan(f13, vec3(0.0));
    vec3 f51 = vec3(f50.x ? f49.x : vec3(0.0).x, f50.y ? f49.y : vec3(0.0).y, f50.z ? f49.z : vec3(0.0).z);
    vec3 f52 = f49 - f51;
    float f53 = f52.x;
    float f54 = f52.y;
    float f55 = f52.z;
    float f56 = f51.x;
    float f57 = f51.y;
    float f58 = f51.z;
    vec3 f59 = (mix(textureLod(PrefilteredEnvIndoorTexture, f43, f42).xyz * f20, textureLod(PrefilteredEnvTexture, f43, f42).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f28.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f21)) * f47) * f27;
    vec3 f60 = (((((((((vec3(1.0) - (f39 * f27)) * CB0[10].xyz) * f32) + (CB0[12].xyz * clamp(-f30, 0.0, 1.0))) + ((vec3(1.0) - f48) * (((((((CB0[35].xyz * f53) + (CB0[37].xyz * f54)) + (CB0[39].xyz * f55)) + (CB0[36].xyz * f56)) + (CB0[38].xyz * f57)) + (CB0[40].xyz * f58)) + (((((((CB0[29].xyz * f53) + (CB0[31].xyz * f54)) + (CB0[33].xyz * f55)) + (CB0[30].xyz * f56)) + (CB0[32].xyz * f57)) + (CB0[34].xyz * f58)) * f21)))) + (CB0[27].xyz + (CB0[28].xyz * f21))) + vec3((f2.z * 2.0) * f12)) * f25) + (((((f39 * (((f40 + (f40 * f40)) / (((f41 * f41) * ((f35 * 3.0) + 0.5)) * ((f34 * 0.75) + 0.25))) * f32)) * CB0[10].xyz) * f12) * VARYING0.w) + f59)) + ((f20 * mix(f25, f59 * (1.0 / (max(max(f59.x, f59.y), f59.z) + 0.00999999977648258209228515625)), f48 * (f27 * (1.0 - f21)))) * 1.0);
    vec4 f61 = vec4(f60.x, f60.y, f60.z, vec4(0.0).w);
    f61.w = 1.0;
    float f62 = clamp(exp2((CB0[13].z * VARYING5.w) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f63 = textureLod(PrefilteredEnvTexture, vec4(-VARYING8, 0.0).xyz, max(CB0[13].y, f62) * 5.0).xyz;
    bvec3 f64 = bvec3(CB0[13].w != 0.0);
    vec3 f65 = sqrt(clamp(mix(vec3(f64.x ? CB0[14].xyz.x : f63.x, f64.y ? CB0[14].xyz.y : f63.y, f64.z ? CB0[14].xyz.z : f63.z), f61.xyz, vec3(f62)).xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    _entryPointOutput = vec4(f65.x, f65.y, f65.z, f61.w);
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrecomputedBRDFTexture=s11
//$$SpecularMapTexture=s2
//$$AlbedoMapTexture=s0
