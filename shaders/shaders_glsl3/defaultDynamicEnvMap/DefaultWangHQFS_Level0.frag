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
    vec4 f5 = texture(WangTileMapTexture, f4 * vec2(0.0078125));
    vec2 f6 = f4 * 0.25;
    vec2 f7 = dFdx(f6);
    vec2 f8 = dFdy(f6);
    vec4 f9 = vec4(f7, f8);
    vec2 f10 = (f5.xy * 0.99609375) + (fract(f4) * 0.25);
    vec2 f11 = f9.xy;
    vec2 f12 = f9.zw;
    vec4 f13 = textureGrad(DiffuseMapTexture, f10, f11, f12);
    vec2 f14 = textureGrad(NormalMapTexture, f10, f11, f12).wy * 2.0;
    vec2 f15 = f14 - vec2(1.0);
    float f16 = sqrt(clamp(1.0 + dot(vec2(1.0) - f14, f15), 0.0, 1.0));
    vec4 f17 = texture(NormalDetailMapTexture, f3 * CB2[0].w);
    vec2 f18 = (vec3(f15, f16).xy + (vec3((f17.wy * 2.0) - vec2(1.0), 0.0).xy * CB2[1].x)).xy * f2;
    float f19 = f18.x;
    vec4 f20 = textureGrad(SpecularMapTexture, f10, f11, f12);
    float f21 = gl_FrontFacing ? 1.0 : (-1.0);
    vec3 f22 = VARYING6.xyz * f21;
    vec3 f23 = VARYING5.xyz * f21;
    vec3 f24 = normalize(((f22 * f19) + (cross(f23, f22) * f18.y)) + (f23 * f16));
    vec3 f25 = vec4((mix(vec3(1.0), VARYING2.xyz, vec3(clamp(f13.w + CB2[2].w, 0.0, 1.0))) * f13.xyz) * (1.0 + (f19 * CB2[0].z)), VARYING2.w).xyz;
    vec3 f26 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f27 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f28 = VARYING3.yzx - (VARYING3.yzx * f27);
    vec4 f29 = texture(LightMapTexture, f28);
    vec4 f30 = texture(LightGridSkylightTexture, f28);
    vec4 f31 = vec4(clamp(f27, 0.0, 1.0));
    vec4 f32 = mix(f29, vec4(0.0), f31);
    vec4 f33 = mix(f30, vec4(1.0), f31);
    float f34 = f33.x;
    vec4 f35 = texture(ShadowMapTexture, f26.xy);
    float f36 = f26.z;
    vec3 f37 = (f25 * f25).xyz;
    float f38 = CB0[26].w * f2;
    float f39 = max(f20.y, 0.04500000178813934326171875);
    vec3 f40 = reflect(-f1, f24);
    float f41 = f39 * 5.0;
    vec3 f42 = vec4(f40, f41).xyz;
    vec3 f43 = textureLod(PrefilteredEnvIndoorTexture, f42, f41).xyz;
    vec3 f44;
    if (CB0[27].w == 0.0)
    {
        f44 = f43;
    }
    else
    {
        f44 = mix(f43, textureLod(PrefilteredEnvBlendTargetTexture, f42, f41).xyz, vec3(CB0[27].w));
    }
    vec4 f45 = texture(PrecomputedBRDFTexture, vec2(f39, max(9.9999997473787516355514526367188e-05, dot(f24, f1))));
    float f46 = f20.x * f38;
    vec3 f47 = mix(vec3(0.039999999105930328369140625), f37, vec3(f46));
    vec3 f48 = -CB0[11].xyz;
    float f49 = dot(f24, f48) * ((1.0 - ((step(f35.x, f36) * clamp(CB0[24].z + (CB0[24].w * abs(f36 - 0.5)), 0.0, 1.0)) * f35.y)) * f33.y);
    vec3 f50 = normalize(f48 + f1);
    float f51 = clamp(f49, 0.0, 1.0);
    float f52 = f39 * f39;
    float f53 = max(0.001000000047497451305389404296875, dot(f24, f50));
    float f54 = dot(f48, f50);
    float f55 = 1.0 - f54;
    float f56 = f55 * f55;
    float f57 = (f56 * f56) * f55;
    vec3 f58 = vec3(f57) + (f47 * (1.0 - f57));
    float f59 = f52 * f52;
    float f60 = (((f53 * f59) - f53) * f53) + 1.0;
    float f61 = 1.0 - f46;
    float f62 = f38 * f61;
    vec3 f63 = vec3(f61);
    float f64 = f45.x;
    float f65 = f45.y;
    vec3 f66 = ((f47 * f64) + vec3(f65)) / vec3(f64 + f65);
    vec3 f67 = f24 * f24;
    bvec3 f68 = lessThan(f24, vec3(0.0));
    vec3 f69 = vec3(f68.x ? f67.x : vec3(0.0).x, f68.y ? f67.y : vec3(0.0).y, f68.z ? f67.z : vec3(0.0).z);
    vec3 f70 = f67 - f69;
    float f71 = f70.x;
    float f72 = f70.y;
    float f73 = f70.z;
    float f74 = f69.x;
    float f75 = f69.y;
    float f76 = f69.z;
    vec3 f77 = ((((((((f63 - (f58 * f62)) * CB0[10].xyz) * f51) + (CB0[12].xyz * (f61 * clamp(-f49, 0.0, 1.0)))) + ((f32.xyz * (f32.w * 120.0)).xyz * 1.0)) + ((f63 - (f66 * f62)) * (((((((CB0[35].xyz * f71) + (CB0[37].xyz * f72)) + (CB0[39].xyz * f73)) + (CB0[36].xyz * f74)) + (CB0[38].xyz * f75)) + (CB0[40].xyz * f76)) + (((((((CB0[29].xyz * f71) + (CB0[31].xyz * f72)) + (CB0[33].xyz * f73)) + (CB0[30].xyz * f74)) + (CB0[32].xyz * f75)) + (CB0[34].xyz * f76)) * f34)))) + (CB0[27].xyz + (CB0[28].xyz * f34))) * f37) + (((f58 * (((f59 + (f59 * f59)) / (((f60 * f60) * ((f54 * 3.0) + 0.5)) * ((f53 * 0.75) + 0.25))) * f51)) * CB0[10].xyz) + ((mix(f44, textureLod(PrefilteredEnvTexture, f42, f41).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f40.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f34)) * f66) * f38));
    vec4 f78 = vec4(f77.x, f77.y, f77.z, vec4(0.0).w);
    f78.w = VARYING2.w;
    float f79 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f80 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f79) * 5.0).xyz;
    bvec3 f81 = bvec3(CB0[13].w != 0.0);
    vec3 f82 = sqrt(clamp(mix(vec3(f81.x ? CB0[14].xyz.x : f80.x, f81.y ? CB0[14].xyz.y : f80.y, f81.z ? CB0[14].xyz.z : f80.z), f78.xyz, vec3(f79)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f83 = vec4(f82.x, f82.y, f82.z, f78.w);
    f83.w = VARYING2.w;
    _entryPointOutput = f83;
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrefilteredEnvBlendTargetTexture=s2
//$$PrecomputedBRDFTexture=s11
//$$WangTileMapTexture=s9
//$$DiffuseMapTexture=s3
//$$NormalMapTexture=s4
//$$NormalDetailMapTexture=s8
//$$SpecularMapTexture=s5
