#version 150

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

uniform vec4 CB0[32];
in vec4 POSITION;
in vec4 NORMAL;
in vec2 TEXCOORD0;
in vec2 TEXCOORD1;
in vec4 COLOR0;
in vec4 COLOR1;
in vec4 TEXCOORD3;
out vec4 VARYING0;
out vec4 VARYING1;
out vec4 VARYING2;
out vec4 VARYING3;
out vec4 VARYING4;
out vec4 VARYING5;
out vec4 VARYING6;
out vec4 VARYING7;
out float VARYING8;

void main()
{
    vec3 _397 = (NORMAL.xyz * 0.0078740157186985015869140625) - vec3(1.0);
    float _434 = dot(_397, -CB0[11].xyz);
    vec4 _445 = vec4(POSITION.xyz, 1.0) * mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    vec4 _450 = vec4(TEXCOORD0, 0.0, 0.0);
    vec4 _648 = vec4(TEXCOORD1, 0.0, 0.0);
    _648.x = max(0.0500000007450580596923828125, TEXCOORD1.x);
    float _487 = _445.w;
    vec4 _504 = ((exp2(TEXCOORD3 * 0.0625) - vec4(1.0)) * CB0[24].z) + vec4((0.5 * _487) * CB0[24].y);
    vec4 _653 = vec4(POSITION.xyz, 0.0);
    _653.w = COLOR1.w * 0.0039215688593685626983642578125;
    gl_Position = _445;
    VARYING0 = vec4(_450.x, _450.y, _504.x, _504.y);
    VARYING1 = vec4(_648.x, _648.y, _504.z, _504.w);
    VARYING2 = COLOR0;
    VARYING3 = vec4(((POSITION.xyz + (_397 * 6.0)).yxz * CB0[17].xyz) + CB0[18].xyz, 0.0);
    VARYING4 = vec4(CB0[7].xyz - POSITION.xyz, _487);
    VARYING5 = vec4(_397, COLOR1.z);
    VARYING6 = vec4((CB0[10].xyz * max(_434, 0.0)) + (CB0[12].xyz * max(-_434, 0.0)), (float(_434 > 0.0) * (COLOR1.y * 0.0039215688593685626983642578125)) * CB0[24].w);
    VARYING7 = _653;
    VARYING8 = NORMAL.w;
}
