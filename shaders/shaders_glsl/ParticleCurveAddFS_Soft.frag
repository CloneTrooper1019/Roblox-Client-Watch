#version 110

struct Globals
{
    mat4 ViewProjection;
    vec4 ViewRight;
    vec4 ViewUp;
    vec4 ViewDir;
    vec3 CameraPosition;
    vec3 AmbientColor;
    vec3 SkyAmbient;
    vec3 Lamp0Color;
    vec3 Lamp0Dir;
    vec3 Lamp1Color;
    vec4 FogParams;
    vec4 FogColor_GlobalForceFieldTime;
    vec4 Technology_Exposure;
    vec4 LightBorder;
    vec4 LightConfig0;
    vec4 LightConfig1;
    vec4 LightConfig2;
    vec4 LightConfig3;
    vec4 ShadowMatrix0;
    vec4 ShadowMatrix1;
    vec4 ShadowMatrix2;
    vec4 RefractionBias_FadeDistance_GlowFactor_SpecMul;
    vec4 OutlineBrightness_ShadowInfo;
    vec4 CascadeSphere0;
    vec4 CascadeSphere1;
    vec4 CascadeSphere2;
    vec4 CascadeSphere3;
    float hybridLerpDist;
    float hybridLerpSlope;
    float evsmPosExp;
    float evsmNegExp;
    float globalShadow;
    float shadowBias;
    float shadowAlphaRef;
    float debugFlagsShadows;
};

struct EmitterParams
{
    vec4 ModulateColor;
    vec4 Params;
    vec4 AtlasParams;
};

uniform vec4 CB0[32];
uniform vec4 CB1[3];
uniform sampler2D depthTexTexture;
uniform sampler2D texTexture;

varying vec3 VARYING0;
varying vec4 VARYING1;
varying vec4 VARYING3;

void main()
{
    vec4 _227 = texture2D(texTexture, VARYING0.xy);
    vec3 _249 = ((_227.xyz + VARYING1.xyz) * CB1[0].xyz).xyz;
    vec3 _306 = mix(_249, sqrt(clamp((_249 * _249) * CB0[15].z, vec3(0.0), vec3(1.0))), vec3(CB0[15].x));
    float _263 = (_227.w * VARYING1.w) * (clamp(VARYING3.w * abs((texture2D(depthTexTexture, VARYING3.xy).x * 500.0) - VARYING3.z), 0.0, 1.0) * clamp(VARYING0.z, 0.0, 1.0));
    vec4 _352 = vec4(_306.x, _306.y, _306.z, vec4(0.0).w);
    _352.w = _263;
    vec3 _269 = _352.xyz * _263;
    gl_FragData[0] = vec4(_269.x, _269.y, _269.z, _352.w);
}

//$$depthTexTexture=s3
//$$texTexture=s0