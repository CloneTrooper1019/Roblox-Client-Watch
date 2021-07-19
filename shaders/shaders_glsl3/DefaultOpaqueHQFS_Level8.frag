#version 150

#extension GL_ARB_shading_language_include : require
#include <Globals.h>
#include <LightShadowGPUTransform.h>
uniform vec4 CB0[53];
uniform vec4 CB8[24];
uniform sampler2D ShadowAtlasTexture;
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform samplerCube PrefilteredEnvTexture;
uniform samplerCube PrefilteredEnvIndoorTexture;
uniform sampler2D PrecomputedBRDFTexture;
uniform sampler2D DiffuseMapTexture;

in vec2 VARYING0;
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
    vec3 f2 = normalize(VARYING5.xyz) * (gl_FrontFacing ? 1.0 : (-1.0));
    vec3 f3 = -CB0[11].xyz;
    float f4 = dot(f2, f3);
    vec3 f5 = (texture(DiffuseMapTexture, VARYING0) * VARYING2).xyz;
    vec3 f6 = VARYING6.xyz - (CB0[11].xyz * VARYING3.w);
    float f7 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f8 = VARYING3.yzx - (VARYING3.yzx * f7);
    vec4 f9 = vec4(clamp(f7, 0.0, 1.0));
    vec4 f10 = mix(texture(LightMapTexture, f8), vec4(0.0), f9);
    vec4 f11 = mix(texture(LightGridSkylightTexture, f8), vec4(1.0), f9);
    vec3 f12 = (f10.xyz * (f10.w * 120.0)).xyz;
    float f13 = f11.x;
    float f14 = f11.y;
    vec3 f15 = f6 - CB0[41].xyz;
    vec3 f16 = f6 - CB0[42].xyz;
    vec3 f17 = f6 - CB0[43].xyz;
    vec4 f18 = vec4(f6, 1.0) * mat4(CB8[((dot(f15, f15) < CB0[41].w) ? 0 : ((dot(f16, f16) < CB0[42].w) ? 1 : ((dot(f17, f17) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f15, f15) < CB0[41].w) ? 0 : ((dot(f16, f16) < CB0[42].w) ? 1 : ((dot(f17, f17) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f15, f15) < CB0[41].w) ? 0 : ((dot(f16, f16) < CB0[42].w) ? 1 : ((dot(f17, f17) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f15, f15) < CB0[41].w) ? 0 : ((dot(f16, f16) < CB0[42].w) ? 1 : ((dot(f17, f17) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f19 = textureLod(ShadowAtlasTexture, f18.xy, 0.0);
    vec2 f20 = vec2(0.0);
    f20.x = CB0[46].z;
    vec2 f21 = f20;
    f21.y = CB0[46].w;
    float f22 = (2.0 * f18.z) - 1.0;
    float f23 = exp(CB0[46].z * f22);
    float f24 = -exp((-CB0[46].w) * f22);
    vec2 f25 = (f21 * CB0[47].y) * vec2(f23, f24);
    vec2 f26 = f25 * f25;
    float f27 = f19.x;
    float f28 = max(f19.y - (f27 * f27), f26.x);
    float f29 = f23 - f27;
    float f30 = f19.z;
    float f31 = max(f19.w - (f30 * f30), f26.y);
    float f32 = f24 - f30;
    vec3 f33 = (f5 * f5).xyz;
    float f34 = CB0[26].w * clamp(1.0 - (VARYING4.w * CB0[23].y), 0.0, 1.0);
    float f35 = max(VARYING5.w, 0.04500000178813934326171875);
    vec3 f36 = reflect(-f1, f2);
    float f37 = f35 * 5.0;
    vec3 f38 = vec4(f36, f37).xyz;
    vec4 f39 = texture(PrecomputedBRDFTexture, vec2(f35, max(9.9999997473787516355514526367188e-05, dot(f2, f1))));
    float f40 = VARYING6.w * f34;
    vec3 f41 = mix(vec3(0.039999999105930328369140625), f33, vec3(f40));
    vec3 f42 = normalize(f3 + f1);
    float f43 = clamp(f4 * (((f4 * CB0[47].x) > 0.0) ? mix(min((f23 <= f27) ? 1.0 : clamp(((f28 / (f28 + (f29 * f29))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f24 <= f30) ? 1.0 : clamp(((f31 / (f31 + (f32 * f32))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f14, clamp((length(f6 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f14), 0.0, 1.0);
    float f44 = f35 * f35;
    float f45 = max(0.001000000047497451305389404296875, dot(f2, f42));
    float f46 = dot(f3, f42);
    float f47 = 1.0 - f46;
    float f48 = f47 * f47;
    float f49 = (f48 * f48) * f47;
    vec3 f50 = vec3(f49) + (f41 * (1.0 - f49));
    float f51 = f44 * f44;
    float f52 = (((f45 * f51) - f45) * f45) + 1.0;
    float f53 = 1.0 - f40;
    float f54 = f34 * f53;
    vec3 f55 = vec3(f53);
    float f56 = f39.x;
    float f57 = f39.y;
    vec3 f58 = ((f41 * f56) + vec3(f57)) / vec3(f56 + f57);
    vec3 f59 = f55 - (f58 * f54);
    vec3 f60 = f2 * f2;
    bvec3 f61 = lessThan(f2, vec3(0.0));
    vec3 f62 = vec3(f61.x ? f60.x : vec3(0.0).x, f61.y ? f60.y : vec3(0.0).y, f61.z ? f60.z : vec3(0.0).z);
    vec3 f63 = f60 - f62;
    float f64 = f63.x;
    float f65 = f63.y;
    float f66 = f63.z;
    float f67 = f62.x;
    float f68 = f62.y;
    float f69 = f62.z;
    vec3 f70 = (mix(textureLod(PrefilteredEnvIndoorTexture, f38, f37).xyz * f12, textureLod(PrefilteredEnvTexture, f38, f37).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f36.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f13)) * f58) * f34;
    vec3 f71 = (((((((f55 - (f50 * f54)) * CB0[10].xyz) * f43) + (f59 * (((((((CB0[35].xyz * f64) + (CB0[37].xyz * f65)) + (CB0[39].xyz * f66)) + (CB0[36].xyz * f67)) + (CB0[38].xyz * f68)) + (CB0[40].xyz * f69)) + (((((((CB0[29].xyz * f64) + (CB0[31].xyz * f65)) + (CB0[33].xyz * f66)) + (CB0[30].xyz * f67)) + (CB0[32].xyz * f68)) + (CB0[34].xyz * f69)) * f13)))) + (CB0[27].xyz + (CB0[28].xyz * f13))) * f33) + (((f50 * (((f51 + (f51 * f51)) / (((f52 * f52) * ((f46 * 3.0) + 0.5)) * ((f45 * 0.75) + 0.25))) * f43)) * CB0[10].xyz) + f70)) + ((f12 * mix(f33, f70 * (1.0 / (max(max(f70.x, f70.y), f70.z) + 0.00999999977648258209228515625)), (vec3(1.0) - f59) * (f34 * (1.0 - f13)))) * 1.0);
    vec4 f72 = vec4(f71.x, f71.y, f71.z, vec4(0.0).w);
    f72.w = 1.0;
    float f73 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f74 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f73) * 5.0).xyz;
    bvec3 f75 = bvec3(CB0[13].w != 0.0);
    vec3 f76 = sqrt(clamp(mix(vec3(f75.x ? CB0[14].xyz.x : f74.x, f75.y ? CB0[14].xyz.y : f74.y, f75.z ? CB0[14].xyz.z : f74.z), f72.xyz, vec3(f73)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f77 = vec4(f76.x, f76.y, f76.z, f72.w);
    f77.w = 1.0;
    _entryPointOutput = f77;
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrecomputedBRDFTexture=s11
//$$DiffuseMapTexture=s3
