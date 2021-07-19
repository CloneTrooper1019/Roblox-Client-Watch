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
uniform sampler2D PrecomputedBRDFTexture;
uniform sampler2D WangTileMapTexture;
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
    vec2 f4 = f3 * 4.0;
    vec2 f5 = f4 * 0.25;
    vec4 f6 = vec4(dFdx(f5), dFdy(f5));
    vec2 f7 = (texture(WangTileMapTexture, f4 * vec2(0.0078125)).xy * 0.99609375) + (fract(f4) * 0.25);
    vec2 f8 = f6.xy;
    vec2 f9 = f6.zw;
    vec4 f10 = textureGrad(DiffuseMapTexture, f7, f8, f9);
    vec2 f11 = textureGrad(NormalMapTexture, f7, f8, f9).wy * 2.0;
    vec2 f12 = f11 - vec2(1.0);
    float f13 = sqrt(clamp(1.0 + dot(vec2(1.0) - f11, f12), 0.0, 1.0));
    vec2 f14 = (vec3(f12, f13).xy + (vec3((texture(NormalDetailMapTexture, f3 * CB2[0].w).wy * 2.0) - vec2(1.0), 0.0).xy * CB2[1].x)).xy * f2;
    float f15 = f14.x;
    vec4 f16 = textureGrad(SpecularMapTexture, f7, f8, f9);
    float f17 = gl_FrontFacing ? 1.0 : (-1.0);
    vec3 f18 = VARYING6.xyz * f17;
    vec3 f19 = VARYING5.xyz * f17;
    vec3 f20 = normalize(((f18 * f15) + (cross(f19, f18) * f14.y)) + (f19 * f13));
    vec3 f21 = vec4((mix(vec3(1.0), VARYING2.xyz, vec3(clamp(f10.w + CB2[2].w, 0.0, 1.0))) * f10.xyz) * (1.0 + (f15 * CB2[0].z)), VARYING2.w).xyz;
    vec3 f22 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f23 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f24 = VARYING3.yzx - (VARYING3.yzx * f23);
    vec4 f25 = vec4(clamp(f23, 0.0, 1.0));
    vec4 f26 = mix(texture(LightMapTexture, f24), vec4(0.0), f25);
    vec4 f27 = mix(texture(LightGridSkylightTexture, f24), vec4(1.0), f25);
    vec3 f28 = (f26.xyz * (f26.w * 120.0)).xyz;
    float f29 = f27.x;
    vec4 f30 = texture(ShadowMapTexture, f22.xy);
    float f31 = f22.z;
    vec3 f32 = (f21 * f21).xyz;
    float f33 = CB0[26].w * f2;
    float f34 = max(f16.y, 0.04500000178813934326171875);
    vec3 f35 = reflect(-f1, f20);
    float f36 = f34 * 5.0;
    vec3 f37 = vec4(f35, f36).xyz;
    vec4 f38 = texture(PrecomputedBRDFTexture, vec2(f34, max(9.9999997473787516355514526367188e-05, dot(f20, f1))));
    float f39 = f16.x * f33;
    vec3 f40 = mix(vec3(0.039999999105930328369140625), f32, vec3(f39));
    vec3 f41 = -CB0[11].xyz;
    float f42 = dot(f20, f41) * ((1.0 - ((step(f30.x, f31) * clamp(CB0[24].z + (CB0[24].w * abs(f31 - 0.5)), 0.0, 1.0)) * f30.y)) * f27.y);
    vec3 f43 = normalize(f41 + f1);
    float f44 = clamp(f42, 0.0, 1.0);
    float f45 = f34 * f34;
    float f46 = max(0.001000000047497451305389404296875, dot(f20, f43));
    float f47 = dot(f41, f43);
    float f48 = 1.0 - f47;
    float f49 = f48 * f48;
    float f50 = (f49 * f49) * f48;
    vec3 f51 = vec3(f50) + (f40 * (1.0 - f50));
    float f52 = f45 * f45;
    float f53 = (((f46 * f52) - f46) * f46) + 1.0;
    float f54 = 1.0 - f39;
    float f55 = f33 * f54;
    vec3 f56 = vec3(f54);
    float f57 = f38.x;
    float f58 = f38.y;
    vec3 f59 = ((f40 * f57) + vec3(f58)) / vec3(f57 + f58);
    vec3 f60 = f56 - (f59 * f55);
    vec3 f61 = f20 * f20;
    bvec3 f62 = lessThan(f20, vec3(0.0));
    vec3 f63 = vec3(f62.x ? f61.x : vec3(0.0).x, f62.y ? f61.y : vec3(0.0).y, f62.z ? f61.z : vec3(0.0).z);
    vec3 f64 = f61 - f63;
    float f65 = f64.x;
    float f66 = f64.y;
    float f67 = f64.z;
    float f68 = f63.x;
    float f69 = f63.y;
    float f70 = f63.z;
    vec3 f71 = (mix(textureLod(PrefilteredEnvIndoorTexture, f37, f36).xyz * f28, textureLod(PrefilteredEnvTexture, f37, f36).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f35.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f29)) * f59) * f33;
    vec3 f72 = ((((((((f56 - (f51 * f55)) * CB0[10].xyz) * f44) + (CB0[12].xyz * (f54 * clamp(-f42, 0.0, 1.0)))) + (f60 * (((((((CB0[35].xyz * f65) + (CB0[37].xyz * f66)) + (CB0[39].xyz * f67)) + (CB0[36].xyz * f68)) + (CB0[38].xyz * f69)) + (CB0[40].xyz * f70)) + (((((((CB0[29].xyz * f65) + (CB0[31].xyz * f66)) + (CB0[33].xyz * f67)) + (CB0[30].xyz * f68)) + (CB0[32].xyz * f69)) + (CB0[34].xyz * f70)) * f29)))) + (CB0[27].xyz + (CB0[28].xyz * f29))) * f32) + (((f51 * (((f52 + (f52 * f52)) / (((f53 * f53) * ((f47 * 3.0) + 0.5)) * ((f46 * 0.75) + 0.25))) * f44)) * CB0[10].xyz) + f71)) + ((f28 * mix(f32, f71 * (1.0 / (max(max(f71.x, f71.y), f71.z) + 0.00999999977648258209228515625)), (vec3(1.0) - f60) * (f33 * (1.0 - f29)))) * 1.0);
    vec4 f73 = vec4(f72.x, f72.y, f72.z, vec4(0.0).w);
    f73.w = VARYING2.w;
    float f74 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f75 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f74) * 5.0).xyz;
    bvec3 f76 = bvec3(CB0[13].w != 0.0);
    vec3 f77 = sqrt(clamp(mix(vec3(f76.x ? CB0[14].xyz.x : f75.x, f76.y ? CB0[14].xyz.y : f75.y, f76.z ? CB0[14].xyz.z : f75.z), f73.xyz, vec3(f74)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f78 = vec4(f77.x, f77.y, f77.z, f73.w);
    f78.w = VARYING2.w;
    _entryPointOutput = f78;
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrecomputedBRDFTexture=s11
//$$WangTileMapTexture=s9
//$$DiffuseMapTexture=s3
//$$NormalMapTexture=s4
//$$NormalDetailMapTexture=s8
//$$SpecularMapTexture=s5
