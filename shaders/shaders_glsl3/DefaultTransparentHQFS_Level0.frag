#version 150

#extension GL_ARB_shading_language_include : require
#include <Globals.h>
uniform vec4 CB0[53];
uniform sampler2D ShadowMapTexture;
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
    vec4 f2 = texture(DiffuseMapTexture, VARYING0) * VARYING2;
    vec3 f3 = normalize(VARYING5.xyz) * (gl_FrontFacing ? 1.0 : (-1.0));
    vec3 f4 = f2.xyz;
    vec3 f5 = VARYING6.xyz - (CB0[11].xyz * VARYING3.w);
    float f6 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f7 = VARYING3.yzx - (VARYING3.yzx * f6);
    vec4 f8 = vec4(clamp(f6, 0.0, 1.0));
    vec4 f9 = mix(texture(LightMapTexture, f7), vec4(0.0), f8);
    vec4 f10 = mix(texture(LightGridSkylightTexture, f7), vec4(1.0), f8);
    vec3 f11 = (f9.xyz * (f9.w * 120.0)).xyz;
    float f12 = f10.x;
    vec4 f13 = texture(ShadowMapTexture, f5.xy);
    float f14 = f5.z;
    vec3 f15 = (f4 * f4).xyz;
    float f16 = CB0[26].w * clamp(1.0 - (VARYING4.w * CB0[23].y), 0.0, 1.0);
    float f17 = max(VARYING5.w, 0.04500000178813934326171875);
    vec3 f18 = reflect(-f1, f3);
    float f19 = f17 * 5.0;
    vec3 f20 = vec4(f18, f19).xyz;
    vec4 f21 = texture(PrecomputedBRDFTexture, vec2(f17, max(9.9999997473787516355514526367188e-05, dot(f3, f1))));
    float f22 = VARYING6.w * f16;
    vec3 f23 = mix(vec3(0.039999999105930328369140625), f15, vec3(f22));
    vec3 f24 = -CB0[11].xyz;
    float f25 = dot(f3, f24) * ((1.0 - ((step(f13.x, f14) * clamp(CB0[24].z + (CB0[24].w * abs(f14 - 0.5)), 0.0, 1.0)) * f13.y)) * f10.y);
    vec3 f26 = normalize(f24 + f1);
    float f27 = clamp(f25, 0.0, 1.0);
    float f28 = f17 * f17;
    float f29 = max(0.001000000047497451305389404296875, dot(f3, f26));
    float f30 = dot(f24, f26);
    float f31 = 1.0 - f30;
    float f32 = f31 * f31;
    float f33 = (f32 * f32) * f31;
    vec3 f34 = vec3(f33) + (f23 * (1.0 - f33));
    float f35 = f28 * f28;
    float f36 = (((f29 * f35) - f29) * f29) + 1.0;
    float f37 = 1.0 - f22;
    float f38 = f16 * f37;
    vec3 f39 = vec3(f37);
    float f40 = f21.x;
    float f41 = f21.y;
    vec3 f42 = ((f23 * f40) + vec3(f41)) / vec3(f40 + f41);
    vec3 f43 = f39 - (f42 * f38);
    vec3 f44 = f3 * f3;
    bvec3 f45 = lessThan(f3, vec3(0.0));
    vec3 f46 = vec3(f45.x ? f44.x : vec3(0.0).x, f45.y ? f44.y : vec3(0.0).y, f45.z ? f44.z : vec3(0.0).z);
    vec3 f47 = f44 - f46;
    float f48 = f47.x;
    float f49 = f47.y;
    float f50 = f47.z;
    float f51 = f46.x;
    float f52 = f46.y;
    float f53 = f46.z;
    vec3 f54 = (mix(textureLod(PrefilteredEnvIndoorTexture, f20, f19).xyz * f11, textureLod(PrefilteredEnvTexture, f20, f19).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f18.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f12)) * f42) * f16;
    vec3 f55 = ((((((((f39 - (f34 * f38)) * CB0[10].xyz) * f27) + (CB0[12].xyz * (f37 * clamp(-f25, 0.0, 1.0)))) + (f43 * (((((((CB0[35].xyz * f48) + (CB0[37].xyz * f49)) + (CB0[39].xyz * f50)) + (CB0[36].xyz * f51)) + (CB0[38].xyz * f52)) + (CB0[40].xyz * f53)) + (((((((CB0[29].xyz * f48) + (CB0[31].xyz * f49)) + (CB0[33].xyz * f50)) + (CB0[30].xyz * f51)) + (CB0[32].xyz * f52)) + (CB0[34].xyz * f53)) * f12)))) + (CB0[27].xyz + (CB0[28].xyz * f12))) * f15) + (((f34 * (((f35 + (f35 * f35)) / (((f36 * f36) * ((f30 * 3.0) + 0.5)) * ((f29 * 0.75) + 0.25))) * f27)) * CB0[10].xyz) + f54)) + ((f11 * mix(f15, f54 * (1.0 / (max(max(f54.x, f54.y), f54.z) + 0.00999999977648258209228515625)), (vec3(1.0) - f43) * (f16 * (1.0 - f12)))) * 1.0);
    float f56 = f2.w;
    vec4 f57 = vec4(f55.x, f55.y, f55.z, vec4(0.0).w);
    f57.w = f56;
    float f58 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f59 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f58) * 5.0).xyz;
    bvec3 f60 = bvec3(CB0[13].w != 0.0);
    vec3 f61 = sqrt(clamp(mix(vec3(f60.x ? CB0[14].xyz.x : f59.x, f60.y ? CB0[14].xyz.y : f59.y, f60.z ? CB0[14].xyz.z : f59.z), f57.xyz, vec3(f58)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))));
    vec4 f62 = vec4(f61.x, f61.y, f61.z, f57.w);
    f62.w = f56;
    _entryPointOutput = f62;
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrecomputedBRDFTexture=s11
//$$DiffuseMapTexture=s3
