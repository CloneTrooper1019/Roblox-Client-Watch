#version 150

#extension GL_ARB_shading_language_include : require
#include <Globals.h>
#include <SAParams.h>
uniform vec4 CB0[53];
uniform vec4 CB3[1];
uniform sampler2D ShadowMapTexture;
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform samplerCube PrefilteredEnvTexture;
uniform samplerCube PrefilteredEnvIndoorTexture;
uniform samplerCube PrefilteredEnvBlendTargetTexture;
uniform sampler2D PrecomputedBRDFTexture;
uniform sampler2D DiffuseMapTexture;
uniform sampler2D Tc2DiffuseMapTexture;
uniform sampler2D NormalMapTexture;
uniform sampler2D SpecularMapTexture;

in vec2 VARYING0;
in vec2 VARYING1;
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
    vec4 f4 = texture(Tc2DiffuseMapTexture, VARYING1);
    float f5 = f4.w;
    float f6 = fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))));
    if (smoothstep(0.0, 1.0, f5) < (f6 * CB0[47].z))
    {
        discard;
    }
    vec4 f7 = vec4(mix(vec4(f3.xyz * VARYING2.xyz, f5).xyz, f4.xyz, vec3(f5)), f5);
    vec4 f8 = vec4(f4.xyz, f5 * f5);
    bvec4 f9 = bvec4(CB3[0].x != 0.0);
    vec4 f10 = vec4(f9.x ? f7.x : f8.x, f9.y ? f7.y : f8.y, f9.z ? f7.z : f8.z, f9.w ? f7.w : f8.w);
    vec4 f11 = texture(NormalMapTexture, VARYING1);
    vec2 f12 = f11.wy * 2.0;
    vec2 f13 = f12 - vec2(1.0);
    float f14 = sqrt(clamp(1.0 + dot(vec2(1.0) - f12, f13), 0.0, 1.0));
    vec2 f15 = vec3(f13, f14).xy * f2;
    vec4 f16 = texture(SpecularMapTexture, VARYING1);
    float f17 = gl_FrontFacing ? 1.0 : (-1.0);
    vec3 f18 = VARYING6.xyz * f17;
    vec3 f19 = VARYING5.xyz * f17;
    vec3 f20 = normalize(((f18 * f15.x) + ((cross(f19, f18) * VARYING6.w) * f15.y)) + (f19 * f14));
    vec3 f21 = f10.xyz;
    vec3 f22 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f23 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f24 = VARYING3.yzx - (VARYING3.yzx * f23);
    vec4 f25 = texture(LightMapTexture, f24);
    vec4 f26 = texture(LightGridSkylightTexture, f24);
    vec4 f27 = vec4(clamp(f23, 0.0, 1.0));
    vec4 f28 = mix(f25, vec4(0.0), f27);
    vec4 f29 = mix(f26, vec4(1.0), f27);
    float f30 = f29.x;
    vec4 f31 = texture(ShadowMapTexture, f22.xy);
    float f32 = f22.z;
    vec3 f33 = (f21 * f21).xyz;
    float f34 = CB0[26].w * f2;
    float f35 = max(f16.y, 0.04500000178813934326171875);
    vec3 f36 = reflect(-f1, f20);
    float f37 = f35 * 5.0;
    vec3 f38 = vec4(f36, f37).xyz;
    vec3 f39 = textureLod(PrefilteredEnvIndoorTexture, f38, f37).xyz;
    vec3 f40;
    if (CB0[27].w == 0.0)
    {
        f40 = f39;
    }
    else
    {
        f40 = mix(f39, textureLod(PrefilteredEnvBlendTargetTexture, f38, f37).xyz, vec3(CB0[27].w));
    }
    vec4 f41 = texture(PrecomputedBRDFTexture, vec2(f35, max(9.9999997473787516355514526367188e-05, dot(f20, f1))));
    float f42 = f16.x * f34;
    vec3 f43 = mix(vec3(0.039999999105930328369140625), f33, vec3(f42));
    vec3 f44 = -CB0[11].xyz;
    float f45 = dot(f20, f44) * ((1.0 - ((step(f31.x, f32) * clamp(CB0[24].z + (CB0[24].w * abs(f32 - 0.5)), 0.0, 1.0)) * f31.y)) * f29.y);
    vec3 f46 = normalize(f44 + f1);
    float f47 = clamp(f45, 0.0, 1.0);
    float f48 = f35 * f35;
    float f49 = max(0.001000000047497451305389404296875, dot(f20, f46));
    float f50 = dot(f44, f46);
    float f51 = 1.0 - f50;
    float f52 = f51 * f51;
    float f53 = (f52 * f52) * f51;
    vec3 f54 = vec3(f53) + (f43 * (1.0 - f53));
    float f55 = f48 * f48;
    float f56 = (((f49 * f55) - f49) * f49) + 1.0;
    float f57 = 1.0 - f42;
    float f58 = f34 * f57;
    vec3 f59 = vec3(f57);
    float f60 = f41.x;
    float f61 = f41.y;
    vec3 f62 = ((f43 * f60) + vec3(f61)) / vec3(f60 + f61);
    vec3 f63 = f20 * f20;
    bvec3 f64 = lessThan(f20, vec3(0.0));
    vec3 f65 = vec3(f64.x ? f63.x : vec3(0.0).x, f64.y ? f63.y : vec3(0.0).y, f64.z ? f63.z : vec3(0.0).z);
    vec3 f66 = f63 - f65;
    float f67 = f66.x;
    float f68 = f66.y;
    float f69 = f66.z;
    float f70 = f65.x;
    float f71 = f65.y;
    float f72 = f65.z;
    vec3 f73 = ((((((((f59 - (f54 * f58)) * CB0[10].xyz) * f47) + (CB0[12].xyz * (f57 * clamp(-f45, 0.0, 1.0)))) + ((f28.xyz * (f28.w * 120.0)).xyz * 1.0)) + ((f59 - (f62 * f58)) * (((((((CB0[35].xyz * f67) + (CB0[37].xyz * f68)) + (CB0[39].xyz * f69)) + (CB0[36].xyz * f70)) + (CB0[38].xyz * f71)) + (CB0[40].xyz * f72)) + (((((((CB0[29].xyz * f67) + (CB0[31].xyz * f68)) + (CB0[33].xyz * f69)) + (CB0[30].xyz * f70)) + (CB0[32].xyz * f71)) + (CB0[34].xyz * f72)) * f30)))) + (CB0[27].xyz + (CB0[28].xyz * f30))) * f33) + (((f54 * (((f55 + (f55 * f55)) / (((f56 * f56) * ((f50 * 3.0) + 0.5)) * ((f49 * 0.75) + 0.25))) * f47)) * CB0[10].xyz) + ((mix(f40, textureLod(PrefilteredEnvTexture, f38, f37).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f36.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f30)) * f62) * f34));
    float f74 = f10.w;
    vec4 f75 = vec4(f73.x, f73.y, f73.z, vec4(0.0).w);
    f75.w = f74;
    float f76 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f77 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f76) * 5.0).xyz;
    bvec3 f78 = bvec3(CB0[13].w != 0.0);
    vec3 f79 = sqrt(clamp(mix(vec3(f78.x ? CB0[14].xyz.x : f77.x, f78.y ? CB0[14].xyz.y : f77.y, f78.z ? CB0[14].xyz.z : f77.z), f75.xyz, vec3(f76)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * f6));
    vec4 f80 = vec4(f79.x, f79.y, f79.z, f75.w);
    f80.w = f74;
    _entryPointOutput = f80;
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrefilteredEnvBlendTargetTexture=s2
//$$PrecomputedBRDFTexture=s11
//$$DiffuseMapTexture=s3
//$$Tc2DiffuseMapTexture=s0
//$$NormalMapTexture=s4
//$$SpecularMapTexture=s5
