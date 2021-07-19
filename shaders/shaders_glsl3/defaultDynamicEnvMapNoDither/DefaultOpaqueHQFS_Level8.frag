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
uniform samplerCube PrefilteredEnvBlendTargetTexture;
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
    vec4 f2 = texture(DiffuseMapTexture, VARYING0);
    vec3 f3 = normalize(VARYING5.xyz) * (gl_FrontFacing ? 1.0 : (-1.0));
    vec3 f4 = -CB0[11].xyz;
    float f5 = dot(f3, f4);
    vec3 f6 = (f2 * VARYING2).xyz;
    vec3 f7 = VARYING6.xyz - (CB0[11].xyz * VARYING3.w);
    float f8 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f9 = VARYING3.yzx - (VARYING3.yzx * f8);
    vec4 f10 = texture(LightMapTexture, f9);
    vec4 f11 = texture(LightGridSkylightTexture, f9);
    vec4 f12 = vec4(clamp(f8, 0.0, 1.0));
    vec4 f13 = mix(f10, vec4(0.0), f12);
    vec4 f14 = mix(f11, vec4(1.0), f12);
    float f15 = f14.x;
    float f16 = f14.y;
    vec3 f17 = f7 - CB0[41].xyz;
    vec3 f18 = f7 - CB0[42].xyz;
    vec3 f19 = f7 - CB0[43].xyz;
    vec4 f20 = vec4(f7, 1.0) * mat4(CB8[((dot(f17, f17) < CB0[41].w) ? 0 : ((dot(f18, f18) < CB0[42].w) ? 1 : ((dot(f19, f19) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f17, f17) < CB0[41].w) ? 0 : ((dot(f18, f18) < CB0[42].w) ? 1 : ((dot(f19, f19) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f17, f17) < CB0[41].w) ? 0 : ((dot(f18, f18) < CB0[42].w) ? 1 : ((dot(f19, f19) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f17, f17) < CB0[41].w) ? 0 : ((dot(f18, f18) < CB0[42].w) ? 1 : ((dot(f19, f19) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f21 = textureLod(ShadowAtlasTexture, f20.xy, 0.0);
    vec2 f22 = vec2(0.0);
    f22.x = CB0[46].z;
    vec2 f23 = f22;
    f23.y = CB0[46].w;
    float f24 = (2.0 * f20.z) - 1.0;
    float f25 = exp(CB0[46].z * f24);
    float f26 = -exp((-CB0[46].w) * f24);
    vec2 f27 = (f23 * CB0[47].y) * vec2(f25, f26);
    vec2 f28 = f27 * f27;
    float f29 = f21.x;
    float f30 = max(f21.y - (f29 * f29), f28.x);
    float f31 = f25 - f29;
    float f32 = f21.z;
    float f33 = max(f21.w - (f32 * f32), f28.y);
    float f34 = f26 - f32;
    vec3 f35 = (f6 * f6).xyz;
    float f36 = CB0[26].w * clamp(1.0 - (VARYING4.w * CB0[23].y), 0.0, 1.0);
    float f37 = max(VARYING5.w, 0.04500000178813934326171875);
    vec3 f38 = reflect(-f1, f3);
    float f39 = f37 * 5.0;
    vec3 f40 = vec4(f38, f39).xyz;
    vec3 f41 = textureLod(PrefilteredEnvIndoorTexture, f40, f39).xyz;
    vec3 f42;
    if (CB0[27].w == 0.0)
    {
        f42 = f41;
    }
    else
    {
        f42 = mix(f41, textureLod(PrefilteredEnvBlendTargetTexture, f40, f39).xyz, vec3(CB0[27].w));
    }
    vec4 f43 = texture(PrecomputedBRDFTexture, vec2(f37, max(9.9999997473787516355514526367188e-05, dot(f3, f1))));
    float f44 = VARYING6.w * f36;
    vec3 f45 = mix(vec3(0.039999999105930328369140625), f35, vec3(f44));
    vec3 f46 = normalize(f4 + f1);
    float f47 = clamp(f5 * (((f5 * CB0[47].x) > 0.0) ? mix(min((f25 <= f29) ? 1.0 : clamp(((f30 / (f30 + (f31 * f31))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f26 <= f32) ? 1.0 : clamp(((f33 / (f33 + (f34 * f34))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f16, clamp((length(f7 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f16), 0.0, 1.0);
    float f48 = f37 * f37;
    float f49 = max(0.001000000047497451305389404296875, dot(f3, f46));
    float f50 = dot(f4, f46);
    float f51 = 1.0 - f50;
    float f52 = f51 * f51;
    float f53 = (f52 * f52) * f51;
    vec3 f54 = vec3(f53) + (f45 * (1.0 - f53));
    float f55 = f48 * f48;
    float f56 = (((f49 * f55) - f49) * f49) + 1.0;
    float f57 = 1.0 - f44;
    float f58 = f36 * f57;
    vec3 f59 = vec3(f57);
    float f60 = f43.x;
    float f61 = f43.y;
    vec3 f62 = ((f45 * f60) + vec3(f61)) / vec3(f60 + f61);
    vec3 f63 = f3 * f3;
    bvec3 f64 = lessThan(f3, vec3(0.0));
    vec3 f65 = vec3(f64.x ? f63.x : vec3(0.0).x, f64.y ? f63.y : vec3(0.0).y, f64.z ? f63.z : vec3(0.0).z);
    vec3 f66 = f63 - f65;
    float f67 = f66.x;
    float f68 = f66.y;
    float f69 = f66.z;
    float f70 = f65.x;
    float f71 = f65.y;
    float f72 = f65.z;
    vec3 f73 = (((((((f59 - (f54 * f58)) * CB0[10].xyz) * f47) + ((f13.xyz * (f13.w * 120.0)).xyz * 1.0)) + ((f59 - (f62 * f58)) * (((((((CB0[35].xyz * f67) + (CB0[37].xyz * f68)) + (CB0[39].xyz * f69)) + (CB0[36].xyz * f70)) + (CB0[38].xyz * f71)) + (CB0[40].xyz * f72)) + (((((((CB0[29].xyz * f67) + (CB0[31].xyz * f68)) + (CB0[33].xyz * f69)) + (CB0[30].xyz * f70)) + (CB0[32].xyz * f71)) + (CB0[34].xyz * f72)) * f15)))) + (CB0[27].xyz + (CB0[28].xyz * f15))) * f35) + (((f54 * (((f55 + (f55 * f55)) / (((f56 * f56) * ((f50 * 3.0) + 0.5)) * ((f49 * 0.75) + 0.25))) * f47)) * CB0[10].xyz) + ((mix(f42, textureLod(PrefilteredEnvTexture, f40, f39).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f38.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f15)) * f62) * f36));
    vec4 f74 = vec4(f73.x, f73.y, f73.z, vec4(0.0).w);
    f74.w = 1.0;
    float f75 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f76 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f75) * 5.0).xyz;
    bvec3 f77 = bvec3(CB0[13].w != 0.0);
    vec3 f78 = sqrt(clamp(mix(vec3(f77.x ? CB0[14].xyz.x : f76.x, f77.y ? CB0[14].xyz.y : f76.y, f77.z ? CB0[14].xyz.z : f76.z), f74.xyz, vec3(f75)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f79 = vec4(f78.x, f78.y, f78.z, f74.w);
    f79.w = 1.0;
    _entryPointOutput = f79;
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrefilteredEnvBlendTargetTexture=s2
//$$PrecomputedBRDFTexture=s11
//$$DiffuseMapTexture=s3
