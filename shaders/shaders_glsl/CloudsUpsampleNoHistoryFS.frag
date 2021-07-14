#version 110
#extension GL_ARB_shader_texture_lod : require

#extension GL_ARB_shading_language_include : require
#include <RayFrame.h>
#include <Params.h>
#include <Globals.h>
uniform vec4 CB4[1];
uniform vec4 CB1[8];
uniform vec4 CB0[53];
uniform sampler2D dist;
uniform sampler2D cloudColor;

varying vec2 VARYING0;

void main()
{
    vec2 f0 = CB4[0].zw * (((VARYING0 * CB1[0].xy) * CB4[0].xy) - vec2(1.0));
    if (normalize(((CB0[4].xyz * f0.x) + (CB0[5].xyz * f0.y)) - CB0[6].xyz).y < (-0.5))
    {
        discard;
    }
    vec4 f1 = vec4(1.0, 1.0, -1.0, 0.0) * CB1[0].zwzw;
    vec2 f2 = f1.xy;
    vec2 f3 = f1.wy;
    vec2 f4 = f1.zy;
    vec4 f5 = (((((((((texture2DLod(cloudColor, VARYING0, 0.0) * 4.0) + texture2DLod(cloudColor, VARYING0 - f2, 0.0)) + (texture2DLod(cloudColor, VARYING0 - f3, 0.0) * 2.0)) + texture2DLod(cloudColor, VARYING0 - f4, 0.0)) + (texture2DLod(cloudColor, VARYING0 + f1.zw, 0.0) * 2.0)) + (texture2DLod(cloudColor, VARYING0 + f1.xw, 0.0) * 2.0)) + texture2DLod(cloudColor, VARYING0 + f4, 0.0)) + (texture2DLod(cloudColor, VARYING0 + f3, 0.0) * 2.0)) + texture2DLod(cloudColor, VARYING0 + f2, 0.0)) * vec4(0.0625);
    float f6 = clamp(((texture2DLod(dist, VARYING0, 0.0).x * 500.0) - 227.4499969482421875) * 0.0975609719753265380859375, 0.0, 1.0);
    vec4 f7 = f5;
    f7.w = mix(f5.w, 0.0, f6 * f6);
    gl_FragData[0] = f7;
}

//$$dist=s3
//$$cloudColor=s0
