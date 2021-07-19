#version 150

#extension GL_ARB_shading_language_include : require
#include <Globals.h>
#include <LightShadowGPUTransform.h>
#include <SAParams.h>
uniform vec4 CB0[53];
uniform vec4 CB8[24];
uniform vec4 CB3[1];
uniform sampler2D ShadowAtlasTexture;
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
    if (f4 < (0.5 * CB0[47].z))
    {
        discard;
    }
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
    vec3 f18 = -CB0[11].xyz;
    float f19 = dot(f17, f18);
    vec3 f20 = f8.xyz;
    vec3 f21 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f22 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f23 = VARYING3.yzx - (VARYING3.yzx * f22);
    vec4 f24 = vec4(clamp(f22, 0.0, 1.0));
    vec4 f25 = mix(texture(LightMapTexture, f23), vec4(0.0), f24);
    vec4 f26 = mix(texture(LightGridSkylightTexture, f23), vec4(1.0), f24);
    vec3 f27 = (f25.xyz * (f25.w * 120.0)).xyz;
    float f28 = f26.x;
    float f29 = f26.y;
    vec3 f30 = f21 - CB0[41].xyz;
    vec3 f31 = f21 - CB0[42].xyz;
    vec3 f32 = f21 - CB0[43].xyz;
    vec4 f33 = vec4(f21, 1.0) * mat4(CB8[((dot(f30, f30) < CB0[41].w) ? 0 : ((dot(f31, f31) < CB0[42].w) ? 1 : ((dot(f32, f32) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f30, f30) < CB0[41].w) ? 0 : ((dot(f31, f31) < CB0[42].w) ? 1 : ((dot(f32, f32) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f30, f30) < CB0[41].w) ? 0 : ((dot(f31, f31) < CB0[42].w) ? 1 : ((dot(f32, f32) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f30, f30) < CB0[41].w) ? 0 : ((dot(f31, f31) < CB0[42].w) ? 1 : ((dot(f32, f32) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f34 = textureLod(ShadowAtlasTexture, f33.xy, 0.0);
    vec2 f35 = vec2(0.0);
    f35.x = CB0[46].z;
    vec2 f36 = f35;
    f36.y = CB0[46].w;
    float f37 = (2.0 * f33.z) - 1.0;
    float f38 = exp(CB0[46].z * f37);
    float f39 = -exp((-CB0[46].w) * f37);
    vec2 f40 = (f36 * CB0[47].y) * vec2(f38, f39);
    vec2 f41 = f40 * f40;
    float f42 = f34.x;
    float f43 = max(f34.y - (f42 * f42), f41.x);
    float f44 = f38 - f42;
    float f45 = f34.z;
    float f46 = max(f34.w - (f45 * f45), f41.y);
    float f47 = f39 - f45;
    vec3 f48 = (f20 * f20).xyz;
    float f49 = CB0[26].w * f2;
    float f50 = max(f13.y, 0.04500000178813934326171875);
    vec3 f51 = reflect(-f1, f17);
    float f52 = f50 * 5.0;
    vec3 f53 = vec4(f51, f52).xyz;
    vec4 f54 = texture(PrecomputedBRDFTexture, vec2(f50, max(9.9999997473787516355514526367188e-05, dot(f17, f1))));
    float f55 = f13.x * f49;
    vec3 f56 = mix(vec3(0.039999999105930328369140625), f48, vec3(f55));
    vec3 f57 = normalize(f18 + f1);
    float f58 = clamp(f19 * (((f19 * CB0[47].x) > 0.0) ? mix(min((f38 <= f42) ? 1.0 : clamp(((f43 / (f43 + (f44 * f44))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f39 <= f45) ? 1.0 : clamp(((f46 / (f46 + (f47 * f47))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f29, clamp((length(f21 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f29), 0.0, 1.0);
    float f59 = f50 * f50;
    float f60 = max(0.001000000047497451305389404296875, dot(f17, f57));
    float f61 = dot(f18, f57);
    float f62 = 1.0 - f61;
    float f63 = f62 * f62;
    float f64 = (f63 * f63) * f62;
    vec3 f65 = vec3(f64) + (f56 * (1.0 - f64));
    float f66 = f59 * f59;
    float f67 = (((f60 * f66) - f60) * f60) + 1.0;
    float f68 = 1.0 - f55;
    float f69 = f49 * f68;
    vec3 f70 = vec3(f68);
    float f71 = f54.x;
    float f72 = f54.y;
    vec3 f73 = ((f56 * f71) + vec3(f72)) / vec3(f71 + f72);
    vec3 f74 = f70 - (f73 * f69);
    vec3 f75 = f17 * f17;
    bvec3 f76 = lessThan(f17, vec3(0.0));
    vec3 f77 = vec3(f76.x ? f75.x : vec3(0.0).x, f76.y ? f75.y : vec3(0.0).y, f76.z ? f75.z : vec3(0.0).z);
    vec3 f78 = f75 - f77;
    float f79 = f78.x;
    float f80 = f78.y;
    float f81 = f78.z;
    float f82 = f77.x;
    float f83 = f77.y;
    float f84 = f77.z;
    vec3 f85 = (mix(textureLod(PrefilteredEnvIndoorTexture, f53, f52).xyz * f27, textureLod(PrefilteredEnvTexture, f53, f52).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f51.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f28)) * f73) * f49;
    vec3 f86 = (((((((f70 - (f65 * f69)) * CB0[10].xyz) * f58) + (f74 * (((((((CB0[35].xyz * f79) + (CB0[37].xyz * f80)) + (CB0[39].xyz * f81)) + (CB0[36].xyz * f82)) + (CB0[38].xyz * f83)) + (CB0[40].xyz * f84)) + (((((((CB0[29].xyz * f79) + (CB0[31].xyz * f80)) + (CB0[33].xyz * f81)) + (CB0[30].xyz * f82)) + (CB0[32].xyz * f83)) + (CB0[34].xyz * f84)) * f28)))) + (CB0[27].xyz + (CB0[28].xyz * f28))) * f48) + (((f65 * (((f66 + (f66 * f66)) / (((f67 * f67) * ((f61 * 3.0) + 0.5)) * ((f60 * 0.75) + 0.25))) * f58)) * CB0[10].xyz) + f85)) + ((f27 * mix(f48, f85 * (1.0 / (max(max(f85.x, f85.y), f85.z) + 0.00999999977648258209228515625)), (vec3(1.0) - f74) * (f49 * (1.0 - f28)))) * 1.0);
    float f87 = f8.w;
    vec4 f88 = vec4(f86.x, f86.y, f86.z, vec4(0.0).w);
    f88.w = f87;
    float f89 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f90 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f89) * 5.0).xyz;
    bvec3 f91 = bvec3(CB0[13].w != 0.0);
    vec3 f92 = sqrt(clamp(mix(vec3(f91.x ? CB0[14].xyz.x : f90.x, f91.y ? CB0[14].xyz.y : f90.y, f91.z ? CB0[14].xyz.z : f90.z), f88.xyz, vec3(f89)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f93 = vec4(f92.x, f92.y, f92.z, f88.w);
    f93.w = f87;
    _entryPointOutput = f93;
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrecomputedBRDFTexture=s11
//$$DiffuseMapTexture=s3
//$$NormalMapTexture=s4
//$$SpecularMapTexture=s5
