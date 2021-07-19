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
    vec4 f3 = texture(DiffuseMapTexture, VARYING0);
    vec3 f4 = normalize(VARYING5.xyz) * (gl_FrontFacing ? 1.0 : (-1.0));
    vec3 f5 = -CB0[11].xyz;
    float f6 = dot(f4, f5);
    vec3 f7 = (mix(f3, f2, vec4(f2.w)) * VARYING2).xyz;
    vec3 f8 = VARYING6.xyz - (CB0[11].xyz * VARYING3.w);
    float f9 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f10 = VARYING3.yzx - (VARYING3.yzx * f9);
    vec4 f11 = texture(LightMapTexture, f10);
    vec4 f12 = texture(LightGridSkylightTexture, f10);
    vec4 f13 = vec4(clamp(f9, 0.0, 1.0));
    vec4 f14 = mix(f11, vec4(0.0), f13);
    vec4 f15 = mix(f12, vec4(1.0), f13);
    float f16 = f15.x;
    float f17 = f15.y;
    vec3 f18 = f8 - CB0[41].xyz;
    vec3 f19 = f8 - CB0[42].xyz;
    vec3 f20 = f8 - CB0[43].xyz;
    vec4 f21 = vec4(f8, 1.0) * mat4(CB8[((dot(f18, f18) < CB0[41].w) ? 0 : ((dot(f19, f19) < CB0[42].w) ? 1 : ((dot(f20, f20) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f18, f18) < CB0[41].w) ? 0 : ((dot(f19, f19) < CB0[42].w) ? 1 : ((dot(f20, f20) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f18, f18) < CB0[41].w) ? 0 : ((dot(f19, f19) < CB0[42].w) ? 1 : ((dot(f20, f20) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f18, f18) < CB0[41].w) ? 0 : ((dot(f19, f19) < CB0[42].w) ? 1 : ((dot(f20, f20) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f22 = textureLod(ShadowAtlasTexture, f21.xy, 0.0);
    vec2 f23 = vec2(0.0);
    f23.x = CB0[46].z;
    vec2 f24 = f23;
    f24.y = CB0[46].w;
    float f25 = (2.0 * f21.z) - 1.0;
    float f26 = exp(CB0[46].z * f25);
    float f27 = -exp((-CB0[46].w) * f25);
    vec2 f28 = (f24 * CB0[47].y) * vec2(f26, f27);
    vec2 f29 = f28 * f28;
    float f30 = f22.x;
    float f31 = max(f22.y - (f30 * f30), f29.x);
    float f32 = f26 - f30;
    float f33 = f22.z;
    float f34 = max(f22.w - (f33 * f33), f29.y);
    float f35 = f27 - f33;
    vec3 f36 = (f7 * f7).xyz;
    float f37 = CB0[26].w * clamp(1.0 - (VARYING4.w * CB0[23].y), 0.0, 1.0);
    float f38 = max(VARYING5.w, 0.04500000178813934326171875);
    vec3 f39 = reflect(-f1, f4);
    float f40 = f38 * 5.0;
    vec3 f41 = vec4(f39, f40).xyz;
    vec3 f42 = textureLod(PrefilteredEnvIndoorTexture, f41, f40).xyz;
    vec3 f43;
    if (CB0[27].w == 0.0)
    {
        f43 = f42;
    }
    else
    {
        f43 = mix(f42, textureLod(PrefilteredEnvBlendTargetTexture, f41, f40).xyz, vec3(CB0[27].w));
    }
    vec4 f44 = texture(PrecomputedBRDFTexture, vec2(f38, max(9.9999997473787516355514526367188e-05, dot(f4, f1))));
    float f45 = VARYING6.w * f37;
    vec3 f46 = mix(vec3(0.039999999105930328369140625), f36, vec3(f45));
    vec3 f47 = normalize(f5 + f1);
    float f48 = clamp(f6 * (((f6 * CB0[47].x) > 0.0) ? mix(min((f26 <= f30) ? 1.0 : clamp(((f31 / (f31 + (f32 * f32))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f27 <= f33) ? 1.0 : clamp(((f34 / (f34 + (f35 * f35))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f17, clamp((length(f8 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f17), 0.0, 1.0);
    float f49 = f38 * f38;
    float f50 = max(0.001000000047497451305389404296875, dot(f4, f47));
    float f51 = dot(f5, f47);
    float f52 = 1.0 - f51;
    float f53 = f52 * f52;
    float f54 = (f53 * f53) * f52;
    vec3 f55 = vec3(f54) + (f46 * (1.0 - f54));
    float f56 = f49 * f49;
    float f57 = (((f50 * f56) - f50) * f50) + 1.0;
    float f58 = 1.0 - f45;
    float f59 = f37 * f58;
    vec3 f60 = vec3(f58);
    float f61 = f44.x;
    float f62 = f44.y;
    vec3 f63 = ((f46 * f61) + vec3(f62)) / vec3(f61 + f62);
    vec3 f64 = f4 * f4;
    bvec3 f65 = lessThan(f4, vec3(0.0));
    vec3 f66 = vec3(f65.x ? f64.x : vec3(0.0).x, f65.y ? f64.y : vec3(0.0).y, f65.z ? f64.z : vec3(0.0).z);
    vec3 f67 = f64 - f66;
    float f68 = f67.x;
    float f69 = f67.y;
    float f70 = f67.z;
    float f71 = f66.x;
    float f72 = f66.y;
    float f73 = f66.z;
    vec3 f74 = (((((((f60 - (f55 * f59)) * CB0[10].xyz) * f48) + ((f14.xyz * (f14.w * 120.0)).xyz * 1.0)) + ((f60 - (f63 * f59)) * (((((((CB0[35].xyz * f68) + (CB0[37].xyz * f69)) + (CB0[39].xyz * f70)) + (CB0[36].xyz * f71)) + (CB0[38].xyz * f72)) + (CB0[40].xyz * f73)) + (((((((CB0[29].xyz * f68) + (CB0[31].xyz * f69)) + (CB0[33].xyz * f70)) + (CB0[30].xyz * f71)) + (CB0[32].xyz * f72)) + (CB0[34].xyz * f73)) * f16)))) + (CB0[27].xyz + (CB0[28].xyz * f16))) * f36) + (((f55 * (((f56 + (f56 * f56)) / (((f57 * f57) * ((f51 * 3.0) + 0.5)) * ((f50 * 0.75) + 0.25))) * f48)) * CB0[10].xyz) + ((mix(f43, textureLod(PrefilteredEnvTexture, f41, f40).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f39.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f16)) * f63) * f37));
    vec4 f75 = vec4(f74.x, f74.y, f74.z, vec4(0.0).w);
    f75.w = 1.0;
    float f76 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f77 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f76) * 5.0).xyz;
    bvec3 f78 = bvec3(CB0[13].w != 0.0);
    vec3 f79 = sqrt(clamp(mix(vec3(f78.x ? CB0[14].xyz.x : f77.x, f78.y ? CB0[14].xyz.y : f77.y, f78.z ? CB0[14].xyz.z : f77.z), f75.xyz, vec3(f76)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f80 = vec4(f79.x, f79.y, f79.z, f75.w);
    f80.w = 1.0;
    _entryPointOutput = f80;
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrefilteredEnvBlendTargetTexture=s2
//$$PrecomputedBRDFTexture=s11
//$$Tc2DiffuseMapTexture=s0
//$$DiffuseMapTexture=s3
