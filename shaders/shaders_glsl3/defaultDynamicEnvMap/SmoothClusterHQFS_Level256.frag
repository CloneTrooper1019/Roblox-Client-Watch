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
    vec4 f1 = texture(SpecularMapTexture, f0);
    vec3 f2 = vec3(VARYING1.zw, VARYING2.z);
    vec4 f3 = texture(SpecularMapTexture, f2);
    vec4 f4 = texture(SpecularMapTexture, VARYING3.xyz);
    vec4 f5 = ((f1 * VARYING0.x) + (f3 * VARYING0.y)) + (f4 * VARYING0.z);
    vec4 f6 = texture(AlbedoMapTexture, f0);
    vec4 f7 = texture(AlbedoMapTexture, f2);
    vec4 f8 = texture(AlbedoMapTexture, VARYING3.xyz);
    vec4 f9 = ((f6.yxzw * VARYING0.x) + (f7.yxzw * VARYING0.y)) + (f8.yxzw * VARYING0.z);
    vec2 f10 = f9.yz - vec2(0.5);
    float f11 = VARYING9.x * f9.x;
    float f12 = f10.x;
    float f13 = f10.y;
    float f14 = (VARYING9.y * f12) - (VARYING9.z * f13);
    float f15 = (VARYING9.z * f12) + (VARYING9.y * f13);
    float f16 = f11 - f15;
    vec3 f17 = vec4(vec3(f16, f11, f16) + (vec3(f14, f15, f14) * vec3(1.0, 1.0, -1.0)), 0.0).xyz;
    float f18 = clamp(1.0 - (VARYING5.w * CB0[23].y), 0.0, 1.0);
    vec3 f19 = normalize(VARYING6);
    vec3 f20 = VARYING5.xyz - (CB0[11].xyz * 0.001000000047497451305389404296875);
    float f21 = clamp(dot(step(CB0[19].xyz, abs(VARYING4 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f22 = VARYING4.yzx - (VARYING4.yzx * f21);
    vec4 f23 = texture(LightMapTexture, f22);
    vec4 f24 = texture(LightGridSkylightTexture, f22);
    vec4 f25 = vec4(clamp(f21, 0.0, 1.0));
    vec4 f26 = mix(f23, vec4(0.0), f25);
    vec4 f27 = mix(f24, vec4(1.0), f25);
    float f28 = f27.x;
    vec4 f29 = texture(ShadowMapTexture, f20.xy);
    float f30 = f20.z;
    vec3 f31 = normalize(VARYING8);
    float f32 = f5.y;
    float f33 = CB0[26].w * f18;
    vec3 f34 = reflect(-f31, f19);
    vec3 f35 = -CB0[11].xyz;
    float f36 = dot(f19, f35) * ((1.0 - ((step(f29.x, f30) * clamp(CB0[24].z + (CB0[24].w * abs(f30 - 0.5)), 0.0, 1.0)) * f29.y)) * f27.y);
    vec3 f37 = normalize(f35 + f31);
    float f38 = clamp(f36, 0.0, 1.0);
    float f39 = f32 * f32;
    float f40 = max(0.001000000047497451305389404296875, dot(f19, f37));
    float f41 = dot(f35, f37);
    float f42 = 1.0 - f41;
    float f43 = f42 * f42;
    float f44 = (f43 * f43) * f42;
    vec3 f45 = vec3(f44) + (vec3(0.039999999105930328369140625) * (1.0 - f44));
    float f46 = f39 * f39;
    float f47 = (((f40 * f46) - f40) * f40) + 1.0;
    float f48 = f32 * 5.0;
    vec3 f49 = vec4(f34, f48).xyz;
    vec3 f50 = textureLod(PrefilteredEnvIndoorTexture, f49, f48).xyz;
    vec3 f51;
    if (CB0[27].w == 0.0)
    {
        f51 = f50;
    }
    else
    {
        f51 = mix(f50, textureLod(PrefilteredEnvBlendTargetTexture, f49, f48).xyz, vec3(CB0[27].w));
    }
    vec4 f52 = texture(PrecomputedBRDFTexture, vec2(f32, max(9.9999997473787516355514526367188e-05, dot(f19, f31))));
    float f53 = f52.x;
    float f54 = f52.y;
    vec3 f55 = ((vec3(0.039999999105930328369140625) * f53) + vec3(f54)) / vec3(f53 + f54);
    vec3 f56 = f19 * f19;
    bvec3 f57 = lessThan(f19, vec3(0.0));
    vec3 f58 = vec3(f57.x ? f56.x : vec3(0.0).x, f57.y ? f56.y : vec3(0.0).y, f57.z ? f56.z : vec3(0.0).z);
    vec3 f59 = f56 - f58;
    float f60 = f59.x;
    float f61 = f59.y;
    float f62 = f59.z;
    float f63 = f58.x;
    float f64 = f58.y;
    float f65 = f58.z;
    vec3 f66 = (((((((((vec3(1.0) - (f45 * f33)) * CB0[10].xyz) * f38) + (CB0[12].xyz * clamp(-f36, 0.0, 1.0))) + ((f26.xyz * (f26.w * 120.0)).xyz * 1.0)) + ((vec3(1.0) - (f55 * f33)) * (((((((CB0[35].xyz * f60) + (CB0[37].xyz * f61)) + (CB0[39].xyz * f62)) + (CB0[36].xyz * f63)) + (CB0[38].xyz * f64)) + (CB0[40].xyz * f65)) + (((((((CB0[29].xyz * f60) + (CB0[31].xyz * f61)) + (CB0[33].xyz * f62)) + (CB0[30].xyz * f63)) + (CB0[32].xyz * f64)) + (CB0[34].xyz * f65)) * f28)))) + (CB0[27].xyz + (CB0[28].xyz * f28))) + vec3((f5.z * 2.0) * f18)) * (f17 * f17).xyz) + (((((f45 * (((f46 + (f46 * f46)) / (((f47 * f47) * ((f41 * 3.0) + 0.5)) * ((f40 * 0.75) + 0.25))) * f38)) * CB0[10].xyz) * f18) * VARYING0.w) + ((mix(f51, textureLod(PrefilteredEnvTexture, f49, f48).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f34.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f28)) * f55) * f33));
    vec4 f67 = vec4(f66.x, f66.y, f66.z, vec4(0.0).w);
    f67.w = 1.0;
    float f68 = clamp(exp2((CB0[13].z * VARYING5.w) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f69 = textureLod(PrefilteredEnvTexture, vec4(-VARYING8, 0.0).xyz, max(CB0[13].y, f68) * 5.0).xyz;
    bvec3 f70 = bvec3(CB0[13].w != 0.0);
    vec3 f71 = sqrt(clamp(mix(vec3(f70.x ? CB0[14].xyz.x : f69.x, f70.y ? CB0[14].xyz.y : f69.y, f70.z ? CB0[14].xyz.z : f69.z), f67.xyz, vec3(f68)).xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    _entryPointOutput = vec4(f71.x, f71.y, f71.z, f67.w);
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrefilteredEnvBlendTargetTexture=s2
//$$PrecomputedBRDFTexture=s11
//$$SpecularMapTexture=s3
//$$AlbedoMapTexture=s0
