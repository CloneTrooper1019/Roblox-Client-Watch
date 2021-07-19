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
    vec2 f11 = texture(NormalMapTexture, VARYING1).wy * 2.0;
    vec2 f12 = f11 - vec2(1.0);
    float f13 = sqrt(clamp(1.0 + dot(vec2(1.0) - f11, f12), 0.0, 1.0));
    vec2 f14 = vec3(f12, f13).xy * f2;
    vec4 f15 = texture(SpecularMapTexture, VARYING1);
    float f16 = gl_FrontFacing ? 1.0 : (-1.0);
    vec3 f17 = VARYING6.xyz * f16;
    vec3 f18 = VARYING5.xyz * f16;
    vec3 f19 = normalize(((f17 * f14.x) + ((cross(f18, f17) * VARYING6.w) * f14.y)) + (f18 * f13));
    vec3 f20 = f10.xyz;
    vec3 f21 = VARYING7.xyz - (CB0[11].xyz * VARYING3.w);
    float f22 = clamp(dot(step(CB0[19].xyz, abs(VARYING3.xyz - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f23 = VARYING3.yzx - (VARYING3.yzx * f22);
    vec4 f24 = vec4(clamp(f22, 0.0, 1.0));
    vec4 f25 = mix(texture(LightMapTexture, f23), vec4(0.0), f24);
    vec4 f26 = mix(texture(LightGridSkylightTexture, f23), vec4(1.0), f24);
    vec3 f27 = (f25.xyz * (f25.w * 120.0)).xyz;
    float f28 = f26.x;
    vec4 f29 = texture(ShadowMapTexture, f21.xy);
    float f30 = f21.z;
    vec3 f31 = (f20 * f20).xyz;
    float f32 = CB0[26].w * f2;
    float f33 = max(f15.y, 0.04500000178813934326171875);
    vec3 f34 = reflect(-f1, f19);
    float f35 = f33 * 5.0;
    vec3 f36 = vec4(f34, f35).xyz;
    vec4 f37 = texture(PrecomputedBRDFTexture, vec2(f33, max(9.9999997473787516355514526367188e-05, dot(f19, f1))));
    float f38 = f15.x * f32;
    vec3 f39 = mix(vec3(0.039999999105930328369140625), f31, vec3(f38));
    vec3 f40 = -CB0[11].xyz;
    float f41 = dot(f19, f40) * ((1.0 - ((step(f29.x, f30) * clamp(CB0[24].z + (CB0[24].w * abs(f30 - 0.5)), 0.0, 1.0)) * f29.y)) * f26.y);
    vec3 f42 = normalize(f40 + f1);
    float f43 = clamp(f41, 0.0, 1.0);
    float f44 = f33 * f33;
    float f45 = max(0.001000000047497451305389404296875, dot(f19, f42));
    float f46 = dot(f40, f42);
    float f47 = 1.0 - f46;
    float f48 = f47 * f47;
    float f49 = (f48 * f48) * f47;
    vec3 f50 = vec3(f49) + (f39 * (1.0 - f49));
    float f51 = f44 * f44;
    float f52 = (((f45 * f51) - f45) * f45) + 1.0;
    float f53 = 1.0 - f38;
    float f54 = f32 * f53;
    vec3 f55 = vec3(f53);
    float f56 = f37.x;
    float f57 = f37.y;
    vec3 f58 = ((f39 * f56) + vec3(f57)) / vec3(f56 + f57);
    vec3 f59 = f55 - (f58 * f54);
    vec3 f60 = f19 * f19;
    bvec3 f61 = lessThan(f19, vec3(0.0));
    vec3 f62 = vec3(f61.x ? f60.x : vec3(0.0).x, f61.y ? f60.y : vec3(0.0).y, f61.z ? f60.z : vec3(0.0).z);
    vec3 f63 = f60 - f62;
    float f64 = f63.x;
    float f65 = f63.y;
    float f66 = f63.z;
    float f67 = f62.x;
    float f68 = f62.y;
    float f69 = f62.z;
    vec3 f70 = (mix(textureLod(PrefilteredEnvIndoorTexture, f36, f35).xyz * f27, textureLod(PrefilteredEnvTexture, f36, f35).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f34.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f28)) * f58) * f32;
    vec3 f71 = ((((((((f55 - (f50 * f54)) * CB0[10].xyz) * f43) + (CB0[12].xyz * (f53 * clamp(-f41, 0.0, 1.0)))) + (f59 * (((((((CB0[35].xyz * f64) + (CB0[37].xyz * f65)) + (CB0[39].xyz * f66)) + (CB0[36].xyz * f67)) + (CB0[38].xyz * f68)) + (CB0[40].xyz * f69)) + (((((((CB0[29].xyz * f64) + (CB0[31].xyz * f65)) + (CB0[33].xyz * f66)) + (CB0[30].xyz * f67)) + (CB0[32].xyz * f68)) + (CB0[34].xyz * f69)) * f28)))) + (CB0[27].xyz + (CB0[28].xyz * f28))) * f31) + (((f50 * (((f51 + (f51 * f51)) / (((f52 * f52) * ((f46 * 3.0) + 0.5)) * ((f45 * 0.75) + 0.25))) * f43)) * CB0[10].xyz) + f70)) + ((f27 * mix(f31, f70 * (1.0 / (max(max(f70.x, f70.y), f70.z) + 0.00999999977648258209228515625)), (vec3(1.0) - f59) * (f32 * (1.0 - f28)))) * 1.0);
    float f72 = f10.w;
    vec4 f73 = vec4(f71.x, f71.y, f71.z, vec4(0.0).w);
    f73.w = f72;
    float f74 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f75 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f74) * 5.0).xyz;
    bvec3 f76 = bvec3(CB0[13].w != 0.0);
    vec3 f77 = sqrt(clamp(mix(vec3(f76.x ? CB0[14].xyz.x : f75.x, f76.y ? CB0[14].xyz.y : f75.y, f76.z ? CB0[14].xyz.z : f75.z), f73.xyz, vec3(f74)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * f6));
    vec4 f78 = vec4(f77.x, f77.y, f77.z, f73.w);
    f78.w = f72;
    _entryPointOutput = f78;
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrecomputedBRDFTexture=s11
//$$DiffuseMapTexture=s3
//$$Tc2DiffuseMapTexture=s0
//$$NormalMapTexture=s4
//$$SpecularMapTexture=s5
