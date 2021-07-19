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
    vec4 f0 = texture2D(Tc2DiffuseMapTexture, VARYING1);
    vec3 f1 = (mix(texture2D(DiffuseMapTexture, VARYING0), f0, vec4(f0.w)) * VARYING2).xyz;
    vec3 f2 = VARYING6.xyz - (CB0[11].xyz * VARYING3.w);
    float f3 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f4 = VARYING3.yzx - (VARYING3.yzx * f3);
    vec4 f5 = vec4(clamp(f3, 0.0, 1.0));
    vec4 f6 = mix(texture3D(LightMapTexture, f4), vec4(0.0), f5);
    vec4 f7 = mix(texture3D(LightGridSkylightTexture, f4), vec4(1.0), f5);
    vec4 f8 = texture2D(ShadowMapTexture, f2.xy);
    float f9 = f2.z;
    float f10 = (1.0 - ((step(f8.x, f9) * clamp(CB0[24].z + (CB0[24].w * abs(f9 - 0.5)), 0.0, 1.0)) * f8.y)) * f7.y;
    vec3 f11 = (f1 * f1).xyz;
    vec3 f12 = (((VARYING5.xyz * f10) + min((f6.xyz * (f6.w * 120.0)).xyz + (CB0[8].xyz + (CB0[9].xyz * f7.x)), vec3(CB0[16].w))) * f11) + ((CB0[10].xyz * mix(vec3(0.100000001490116119384765625), f11, vec3(VARYING6.w * CB0[26].w))) * (VARYING5.w * f10));
    vec4 f13 = vec4(f12.x, f12.y, f12.z, vec4(0.0).w);
    f13.w = 1.0;
    vec3 f14 = sqrt(clamp(mix(CB0[14].xyz, f13.xyz, vec3(clamp(exp2((CB0[13].z * length(VARYING4.xyz)) + CB0[13].x) - CB0[13].w, 0.0, 1.0))).xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    vec4 f15 = vec4(f14.x, f14.y, f14.z, f13.w);
    f15.w = 1.0;
    gl_FragData[0] = f15;
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$Tc2DiffuseMapTexture=s0
//$$DiffuseMapTexture=s3
