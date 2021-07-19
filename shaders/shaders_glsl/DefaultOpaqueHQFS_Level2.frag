#version 110

#extension GL_ARB_shading_language_include : require
#include <Globals.h>
uniform vec4 CB0[53];
uniform sampler2D ShadowMapTexture;
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform sampler2D Tc2DiffuseMapTexture;
uniform sampler2D DiffuseMapTexture;

varying vec2 VARYING0;
varying vec2 VARYING1;
varying vec4 VARYING2;
varying vec4 VARYING3;
varying vec4 VARYING4;
varying vec4 VARYING5;
varying vec4 VARYING6;

void main()
{
    float f0 = length(VARYING4.xyz);
    vec4 f1 = texture2D(Tc2DiffuseMapTexture, VARYING1);
    vec3 f2 = normalize(VARYING5.xyz) * (gl_FrontFacing ? 1.0 : (-1.0));
    vec3 f3 = (mix(texture2D(DiffuseMapTexture, VARYING0), f1, vec4(f1.w)) * VARYING2).xyz;
    vec3 f4 = VARYING6.xyz - (CB0[11].xyz * VARYING3.w);
    float f5 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f6 = VARYING3.yzx - (VARYING3.yzx * f5);
    vec4 f7 = vec4(clamp(f5, 0.0, 1.0));
    vec4 f8 = mix(texture3D(LightMapTexture, f6), vec4(0.0), f7);
    vec4 f9 = mix(texture3D(LightGridSkylightTexture, f6), vec4(1.0), f7);
    vec4 f10 = texture2D(ShadowMapTexture, f4.xy);
    float f11 = f4.z;
    vec3 f12 = (f3 * f3).xyz;
    float f13 = CB0[26].w * clamp(1.0 - (VARYING4.w * CB0[23].y), 0.0, 1.0);
    float f14 = max(VARYING5.w, 0.04500000178813934326171875);
    float f15 = VARYING6.w * f13;
    vec3 f16 = -CB0[11].xyz;
    float f17 = dot(f2, f16) * ((1.0 - ((step(f10.x, f11) * clamp(CB0[24].z + (CB0[24].w * abs(f11 - 0.5)), 0.0, 1.0)) * f10.y)) * f9.y);
    vec3 f18 = normalize(f16 + (VARYING4.xyz / vec3(f0)));
    float f19 = clamp(f17, 0.0, 1.0);
    float f20 = f14 * f14;
    float f21 = max(0.001000000047497451305389404296875, dot(f2, f18));
    float f22 = dot(f16, f18);
    float f23 = 1.0 - f22;
    float f24 = f23 * f23;
    float f25 = (f24 * f24) * f23;
    vec3 f26 = vec3(f25) + (mix(vec3(0.039999999105930328369140625), f12, vec3(f15)) * (1.0 - f25));
    float f27 = f20 * f20;
    float f28 = (((f21 * f27) - f21) * f21) + 1.0;
    float f29 = 1.0 - f15;
    vec3 f30 = ((((((vec3(f29) - (f26 * (f13 * f29))) * CB0[10].xyz) * f19) + (CB0[12].xyz * (f29 * clamp(-f17, 0.0, 1.0)))) + min((f8.xyz * (f8.w * 120.0)).xyz + (CB0[8].xyz + (CB0[9].xyz * f9.x)), vec3(CB0[16].w))) * f12) + ((f26 * (((f27 + (f27 * f27)) / (((f28 * f28) * ((f22 * 3.0) + 0.5)) * ((f21 * 0.75) + 0.25))) * f19)) * CB0[10].xyz);
    vec4 f31 = vec4(f30.x, f30.y, f30.z, vec4(0.0).w);
    f31.w = 1.0;
    vec3 f32 = sqrt(clamp(mix(CB0[14].xyz, f31.xyz, vec3(clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0))).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f33 = vec4(f32.x, f32.y, f32.z, f31.w);
    f33.w = 1.0;
    gl_FragData[0] = f33;
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$Tc2DiffuseMapTexture=s0
//$$DiffuseMapTexture=s3
