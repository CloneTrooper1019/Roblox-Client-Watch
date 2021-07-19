#version 150

#extension GL_ARB_shading_language_include : require
#include <Globals.h>
#include <LightShadowGPUTransform.h>
#include <GridParam.h>
uniform vec4 CB0[53];
uniform vec4 CB8[24];
uniform vec4 CB3[1];
uniform sampler2D ShadowAtlasTexture;
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform samplerCube PrefilteredEnvTexture;
uniform sampler2D DiffuseMapTexture;

in vec4 VARYING2;
in vec4 VARYING3;
in vec4 VARYING4;
in vec4 VARYING5;
in vec4 VARYING6;
in vec4 VARYING7;
out vec4 _entryPointOutput;

void main()
{
    vec3 f0 = (CB0[7].xyz - VARYING4.xyz) * CB3[0].x;
    vec3 f1 = abs(VARYING5.xyz);
    float f2 = f1.x;
    float f3 = f1.y;
    float f4 = f1.z;
    vec2 f5;
    if ((f2 >= f3) && (f2 >= f4))
    {
        f5 = f0.yz;
    }
    else
    {
        vec2 f6;
        if ((f3 >= f2) && (f3 >= f4))
        {
            f6 = f0.xz;
        }
        else
        {
            f6 = f0.xy;
        }
        f5 = f6;
    }
    vec4 f7 = texture(DiffuseMapTexture, f5) * VARYING2;
    vec3 f8 = f7.xyz;
    vec3 f9 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f10 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f11 = VARYING3.yzx - (VARYING3.yzx * f10);
    vec4 f12 = vec4(clamp(f10, 0.0, 1.0));
    vec4 f13 = mix(texture(LightMapTexture, f11), vec4(0.0), f12);
    vec4 f14 = mix(texture(LightGridSkylightTexture, f11), vec4(1.0), f12);
    float f15 = f14.y;
    vec3 f16 = f9 - CB0[41].xyz;
    vec3 f17 = f9 - CB0[42].xyz;
    vec3 f18 = f9 - CB0[43].xyz;
    vec4 f19 = vec4(f9, 1.0) * mat4(CB8[((dot(f16, f16) < CB0[41].w) ? 0 : ((dot(f17, f17) < CB0[42].w) ? 1 : ((dot(f18, f18) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f16, f16) < CB0[41].w) ? 0 : ((dot(f17, f17) < CB0[42].w) ? 1 : ((dot(f18, f18) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f16, f16) < CB0[41].w) ? 0 : ((dot(f17, f17) < CB0[42].w) ? 1 : ((dot(f18, f18) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f16, f16) < CB0[41].w) ? 0 : ((dot(f17, f17) < CB0[42].w) ? 1 : ((dot(f18, f18) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f20 = textureLod(ShadowAtlasTexture, f19.xy, 0.0);
    vec2 f21 = vec2(0.0);
    f21.x = CB0[46].z;
    vec2 f22 = f21;
    f22.y = CB0[46].w;
    float f23 = (2.0 * f19.z) - 1.0;
    float f24 = exp(CB0[46].z * f23);
    float f25 = -exp((-CB0[46].w) * f23);
    vec2 f26 = (f22 * CB0[47].y) * vec2(f24, f25);
    vec2 f27 = f26 * f26;
    float f28 = f20.x;
    float f29 = max(f20.y - (f28 * f28), f27.x);
    float f30 = f24 - f28;
    float f31 = f20.z;
    float f32 = max(f20.w - (f31 * f31), f27.y);
    float f33 = f25 - f31;
    float f34 = ((dot(normalize(VARYING5.xyz) * (gl_FrontFacing ? 1.0 : (-1.0)), -CB0[11].xyz) * CB0[47].x) > 0.0) ? mix(min((f24 <= f28) ? 1.0 : clamp(((f29 / (f29 + (f30 * f30))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f25 <= f31) ? 1.0 : clamp(((f32 / (f32 + (f33 * f33))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f15, clamp((length(f9 - CB0[7].xyz) * CB0[46].y) - (CB0[46].x * CB0[46].y), 0.0, 1.0)) : f15;
    vec3 f35 = (((VARYING6.xyz * f34) + min((f13.xyz * (f13.w * 120.0)).xyz + (CB0[8].xyz + (CB0[9].xyz * f14.x)), vec3(CB0[16].w))) * (f8 * f8).xyz) + (CB0[10].xyz * ((VARYING6.w * f34) * 0.100000001490116119384765625));
    float f36 = f7.w;
    vec4 f37 = vec4(f35.x, f35.y, f35.z, vec4(0.0).w);
    f37.w = f36;
    float f38 = clamp(exp2((CB0[13].z * length(VARYING4.xyz)) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f39 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f38) * 5.0).xyz;
    bvec3 f40 = bvec3(CB0[13].w != 0.0);
    vec3 f41 = sqrt(clamp(mix(vec3(f40.x ? CB0[14].xyz.x : f39.x, f40.y ? CB0[14].xyz.y : f39.y, f40.z ? CB0[14].xyz.z : f39.z), f37.xyz, vec3(f38)).xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    vec4 f42 = vec4(f41.x, f41.y, f41.z, f37.w);
    f42.w = f36;
    _entryPointOutput = f42;
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$DiffuseMapTexture=s3
