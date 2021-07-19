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
uniform sampler2D PrecomputedBRDFTexture;
uniform sampler2D DiffuseMapTexture;
uniform sampler2D NormalMapTexture;
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
    vec4 f3 = texture(DiffuseMapTexture, VARYING0);
    float f4 = f3.w;
    vec4 f5 = vec4(mix(VARYING2.xyz, f3.xyz, vec3(f4)), VARYING2.w);
    vec4 f6 = vec4(f3.xyz, VARYING2.w * f4);
    bvec4 f7 = bvec4(CB3[0].x != 0.0);
    vec4 f8 = vec4(f7.x ? f5.x : f6.x, f7.y ? f5.y : f6.y, f7.z ? f5.z : f6.z, f7.w ? f5.w : f6.w);
    vec2 f9 = texture(NormalMapTexture, VARYING0).wy * 2.0;
    vec2 f10 = f9 - vec2(1.0);
    float f11 = sqrt(clamp(1.0 + dot(vec2(1.0) - f9, f10), 0.0, 1.0));
    vec2 f12 = vec3(f10, f11).xy * f2;
    vec4 f13 = texture(SpecularMapTexture, VARYING0);
    float f14 = gl_FrontFacing ? 1.0 : (-1.0);
    vec3 f15 = VARYING6.xyz * f14;
    vec3 f16 = VARYING5.xyz * f14;
    vec3 f17 = normalize(((f15 * f12.x) + ((cross(f16, f15) * VARYING6.w) * f12.y)) + (f16 * f11));
    vec3 f18 = f8.xyz;
    vec3 f19 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f20 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f21 = VARYING3.yzx - (VARYING3.yzx * f20);
    vec4 f22 = vec4(clamp(f20, 0.0, 1.0));
    vec4 f23 = mix(texture(LightMapTexture, f21), vec4(0.0), f22);
    vec4 f24 = mix(texture(LightGridSkylightTexture, f21), vec4(1.0), f22);
    vec3 f25 = (f23.xyz * (f23.w * 120.0)).xyz;
    float f26 = f24.x;
    vec4 f27 = texture(ShadowMapTexture, f19.xy);
    float f28 = f19.z;
    vec3 f29 = (f18 * f18).xyz;
    float f30 = CB0[26].w * f2;
    float f31 = max(f13.y, 0.04500000178813934326171875);
    vec3 f32 = reflect(-f1, f17);
    float f33 = f31 * 5.0;
    vec3 f34 = vec4(f32, f33).xyz;
    vec4 f35 = texture(PrecomputedBRDFTexture, vec2(f31, max(9.9999997473787516355514526367188e-05, dot(f17, f1))));
    float f36 = f13.x * f30;
    vec3 f37 = mix(vec3(0.039999999105930328369140625), f29, vec3(f36));
    vec3 f38 = -CB0[11].xyz;
    float f39 = dot(f17, f38) * ((1.0 - ((step(f27.x, f28) * clamp(CB0[24].z + (CB0[24].w * abs(f28 - 0.5)), 0.0, 1.0)) * f27.y)) * f24.y);
    vec3 f40 = normalize(f38 + f1);
    float f41 = clamp(f39, 0.0, 1.0);
    float f42 = f31 * f31;
    float f43 = max(0.001000000047497451305389404296875, dot(f17, f40));
    float f44 = dot(f38, f40);
    float f45 = 1.0 - f44;
    float f46 = f45 * f45;
    float f47 = (f46 * f46) * f45;
    vec3 f48 = vec3(f47) + (f37 * (1.0 - f47));
    float f49 = f42 * f42;
    float f50 = (((f43 * f49) - f43) * f43) + 1.0;
    float f51 = 1.0 - f36;
    float f52 = f30 * f51;
    vec3 f53 = vec3(f51);
    float f54 = f35.x;
    float f55 = f35.y;
    vec3 f56 = ((f37 * f54) + vec3(f55)) / vec3(f54 + f55);
    vec3 f57 = f53 - (f56 * f52);
    vec3 f58 = f17 * f17;
    bvec3 f59 = lessThan(f17, vec3(0.0));
    vec3 f60 = vec3(f59.x ? f58.x : vec3(0.0).x, f59.y ? f58.y : vec3(0.0).y, f59.z ? f58.z : vec3(0.0).z);
    vec3 f61 = f58 - f60;
    float f62 = f61.x;
    float f63 = f61.y;
    float f64 = f61.z;
    float f65 = f60.x;
    float f66 = f60.y;
    float f67 = f60.z;
    vec3 f68 = (mix(textureLod(PrefilteredEnvIndoorTexture, f34, f33).xyz * f25, textureLod(PrefilteredEnvTexture, f34, f33).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f32.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f26)) * f56) * f30;
    vec3 f69 = ((((((((f53 - (f48 * f52)) * CB0[10].xyz) * f41) + (CB0[12].xyz * (f51 * clamp(-f39, 0.0, 1.0)))) + (f57 * (((((((CB0[35].xyz * f62) + (CB0[37].xyz * f63)) + (CB0[39].xyz * f64)) + (CB0[36].xyz * f65)) + (CB0[38].xyz * f66)) + (CB0[40].xyz * f67)) + (((((((CB0[29].xyz * f62) + (CB0[31].xyz * f63)) + (CB0[33].xyz * f64)) + (CB0[30].xyz * f65)) + (CB0[32].xyz * f66)) + (CB0[34].xyz * f67)) * f26)))) + (CB0[27].xyz + (CB0[28].xyz * f26))) * f29) + (((f48 * (((f49 + (f49 * f49)) / (((f50 * f50) * ((f44 * 3.0) + 0.5)) * ((f43 * 0.75) + 0.25))) * f41)) * CB0[10].xyz) + f68)) + ((f25 * mix(f29, f68 * (1.0 / (max(max(f68.x, f68.y), f68.z) + 0.00999999977648258209228515625)), (vec3(1.0) - f57) * (f30 * (1.0 - f26)))) * 1.0);
    float f70 = f8.w;
    vec4 f71 = vec4(f69.x, f69.y, f69.z, vec4(0.0).w);
    f71.w = f70;
    float f72 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f73 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f72) * 5.0).xyz;
    bvec3 f74 = bvec3(CB0[13].w != 0.0);
    vec3 f75 = sqrt(clamp(mix(vec3(f74.x ? CB0[14].xyz.x : f73.x, f74.y ? CB0[14].xyz.y : f73.y, f74.z ? CB0[14].xyz.z : f73.z), f71.xyz, vec3(f72)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f76 = vec4(f75.x, f75.y, f75.z, f71.w);
    f76.w = f70;
    _entryPointOutput = f76;
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrecomputedBRDFTexture=s11
//$$DiffuseMapTexture=s3
//$$NormalMapTexture=s4
//$$SpecularMapTexture=s5
