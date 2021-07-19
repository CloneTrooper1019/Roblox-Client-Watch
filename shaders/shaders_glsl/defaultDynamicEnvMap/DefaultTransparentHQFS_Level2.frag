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
    vec4 f2 = mix(texture2D(DiffuseMapTexture, VARYING0), f1, vec4(f1.w)) * VARYING2;
    vec3 f3 = normalize(VARYING5.xyz) * (gl_FrontFacing ? 1.0 : (-1.0));
    vec3 f4 = f2.xyz;
    vec3 f5 = VARYING6.xyz - (CB0[11].xyz * VARYING3.w);
    float f6 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f7 = VARYING3.yzx - (VARYING3.yzx * f6);
    vec4 f8 = vec4(clamp(f6, 0.0, 1.0));
    vec4 f9 = mix(texture3D(LightMapTexture, f7), vec4(0.0), f8);
    vec4 f10 = mix(texture3D(LightGridSkylightTexture, f7), vec4(1.0), f8);
    vec4 f11 = texture2D(ShadowMapTexture, f5.xy);
    float f12 = f5.z;
    vec3 f13 = (f4 * f4).xyz;
    float f14 = CB0[26].w * clamp(1.0 - (VARYING4.w * CB0[23].y), 0.0, 1.0);
    float f15 = max(VARYING5.w, 0.04500000178813934326171875);
    float f16 = VARYING6.w * f14;
    vec3 f17 = -CB0[11].xyz;
    float f18 = dot(f3, f17) * ((1.0 - ((step(f11.x, f12) * clamp(CB0[24].z + (CB0[24].w * abs(f12 - 0.5)), 0.0, 1.0)) * f11.y)) * f10.y);
    vec3 f19 = normalize(f17 + (VARYING4.xyz / vec3(f0)));
    float f20 = clamp(f18, 0.0, 1.0);
    float f21 = f15 * f15;
    float f22 = max(0.001000000047497451305389404296875, dot(f3, f19));
    float f23 = dot(f17, f19);
    float f24 = 1.0 - f23;
    float f25 = f24 * f24;
    float f26 = (f25 * f25) * f24;
    vec3 f27 = vec3(f26) + (mix(vec3(0.039999999105930328369140625), f13, vec3(f16)) * (1.0 - f26));
    float f28 = f21 * f21;
    float f29 = (((f22 * f28) - f22) * f22) + 1.0;
    float f30 = 1.0 - f16;
    vec3 f31 = ((((((vec3(f30) - (f27 * (f14 * f30))) * CB0[10].xyz) * f20) + (CB0[12].xyz * (f30 * clamp(-f18, 0.0, 1.0)))) + min((f9.xyz * (f9.w * 120.0)).xyz + (CB0[8].xyz + (CB0[9].xyz * f10.x)), vec3(CB0[16].w))) * f13) + ((f27 * (((f28 + (f28 * f28)) / (((f29 * f29) * ((f23 * 3.0) + 0.5)) * ((f22 * 0.75) + 0.25))) * f20)) * CB0[10].xyz);
    float f32 = f2.w;
    vec4 f33 = vec4(f31.x, f31.y, f31.z, vec4(0.0).w);
    f33.w = f32;
    vec3 f34 = sqrt(clamp(mix(CB0[14].xyz, f33.xyz, vec3(clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0))).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f35 = vec4(f34.x, f34.y, f34.z, f33.w);
    f35.w = f32;
    gl_FragData[0] = f35;
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$Tc2DiffuseMapTexture=s0
//$$DiffuseMapTexture=s3
