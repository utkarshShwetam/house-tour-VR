// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "RP_Rigged_MasterShader"
{
	Properties
	{
		_Diffuse("Diffuse", 2D) = "white" {}
		_GM("GM", 2D) = "white" {}
		_DiffusePower("Diffuse Power", Float) = 1
		_DiffuseMultiply("Diffuse Multiply", Float) = 1
		[Toggle(_MASKCOLORIZETOGGLE_ON)] _MaskColorizeToggle("Mask ColorizeToggle", Float) = 0
		_Color1("Color1", Color) = (0,0,0,0)
		_Color1Power("Color1 Power", Float) = 1
		_Color1Multiply("Color1 Multiply", Float) = 1
		_Color2("Color2", Color) = (0,0,0,0)
		_Color2Power("Color2 Power", Float) = 1
		_Color2Multiply("Color2 Multiply", Float) = 1
		[Toggle(_AODIFFUSETOGGLE_ON)] _AODiffuseToggle("AO Diffuse Toggle", Float) = 1
		_AODiffuseBlend("AO Diffuse Blend", Range( 0 , 1)) = 1
		_Normal("Normal", 2D) = "bump" {}
		_NormalStrength("Normal Strength", Float) = 1
		_GlossMultiply("Gloss Multiply", Range( 0 , 2)) = 0
		_DiffuseInputHighpass("DiffuseInput Highpass", 2D) = "white" {}
		[Toggle(_GLOSSHIGHPASSDETAIL_ON)] _GlossHighpassDetail("Gloss HighpassDetail", Float) = 0
		[Toggle(_GLOSSFRESNELDETAIL_ON)] _GlossFresnelDetail("Gloss FresnelDetail", Float) = 0
		_GlossHighpassStrength("Gloss HighpassStrength", Float) = 7
		_GlossHighpassOffset("Gloss HighpassOffset", Float) = 9
		_GlossHighpassRange("Gloss HighpassRange", Range( 0 , 1)) = 0.5
		[Toggle(_SSSTOGGLE_ON)] _SSSToggle("SSS Toggle", Float) = 0
		_SSSBlend("SSS Blend", Range( 0 , 2)) = 0.45
		_SSSColor("SSS Color", Color) = (0.7176471,0.6627451,0.5607843,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature _AODIFFUSETOGGLE_ON
		#pragma shader_feature _MASKCOLORIZETOGGLE_ON
		#pragma shader_feature _GLOSSHIGHPASSDETAIL_ON
		#pragma shader_feature _SSSTOGGLE_ON
		#pragma shader_feature _GLOSSFRESNELDETAIL_ON
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			INTERNAL_DATA
			float3 worldNormal;
		};

		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform float _NormalStrength;
		uniform sampler2D _Diffuse;
		uniform float4 _Diffuse_ST;
		uniform float _DiffuseMultiply;
		uniform float _DiffusePower;
		uniform float _AODiffuseBlend;
		uniform float4 _Color1;
		uniform float _Color1Multiply;
		uniform float _Color1Power;
		uniform sampler2D _GM;
		uniform float4 _GM_ST;
		uniform float4 _Color2;
		uniform float _Color2Multiply;
		uniform float _Color2Power;
		uniform float4 _SSSColor;
		uniform float _SSSBlend;
		uniform sampler2D _DiffuseInputHighpass;
		uniform float4 _DiffuseInputHighpass_ST;
		uniform float _GlossHighpassOffset;
		uniform float4 _DiffuseInputHighpass_TexelSize;
		uniform float _GlossHighpassStrength;
		uniform float _GlossHighpassRange;
		uniform float _GlossMultiply;


		float4 CalculateContrast( float contrastValue, float4 colorTarget )
		{
			float t = 0.5 * ( 1.0 - contrastValue );
			return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float3 tex2DNode8 = UnpackNormal( tex2D( _Normal, uv_Normal ) );
			float4 appendResult263 = (float4(( tex2DNode8.r * _NormalStrength ) , ( tex2DNode8.g * _NormalStrength ) , tex2DNode8.b , 0.0));
			float4 normalizeResult44 = normalize( appendResult263 );
			o.Normal = normalizeResult44.xyz;
			float2 uv_Diffuse = i.uv_texcoord * _Diffuse_ST.xy + _Diffuse_ST.zw;
			float3 Normal682 = tex2DNode8;
			float3 temp_cast_1 = (Normal682.z).xxx;
			float grayscale712 = Luminance(temp_cast_1);
			float clampResult722 = clamp( grayscale712 , ( 1.0 - _AODiffuseBlend ) , 1.0 );
			#ifdef _AODIFFUSETOGGLE_ON
				float staticSwitch735 = clampResult722;
			#else
				float staticSwitch735 = 1.0;
			#endif
			float4 temp_cast_2 = (1.0).xxxx;
			float4 temp_cast_3 = (_Color1Power).xxxx;
			float2 uv_GM = i.uv_texcoord * _GM_ST.xy + _GM_ST.zw;
			float4 tex2DNode1 = tex2D( _GM, uv_GM );
			float Mask1678 = tex2DNode1.g;
			float4 temp_cast_4 = (_Color2Power).xxxx;
			float Mask2680 = tex2DNode1.b;
			float4 temp_output_21_0 = ( ( pow( ( _Color1 * _Color1Multiply ) , temp_cast_3 ) * Mask1678 ) + ( pow( ( _Color2 * _Color2Multiply ) , temp_cast_4 ) * Mask2680 ) );
			#ifdef _MASKCOLORIZETOGGLE_ON
				float4 staticSwitch738 = ( ( 1.0 - CalculateContrast(0.0,temp_output_21_0) ) + temp_output_21_0 );
			#else
				float4 staticSwitch738 = temp_cast_2;
			#endif
			float4 temp_output_23_0 = ( ( ( ( tex2D( _Diffuse, uv_Diffuse ) * _DiffuseMultiply ) * _DiffusePower ) * staticSwitch735 * 1.0 ) * staticSwitch738 );
			float3 temp_cast_5 = (Mask1678).xxx;
			float grayscale653 = Luminance(temp_cast_5);
			float3 temp_cast_6 = (Mask2680).xxx;
			float grayscale654 = Luminance(temp_cast_6);
			float temp_output_30_0_g100 = 0.6;
			int temp_output_6_0_g100 = (int)( 1.0 - tex2DNode1.r );
			float temp_output_4_0_g100 = 0.58;
			float clampResult14_g100 = clamp( ( temp_output_6_0_g100 / temp_output_4_0_g100 ) , 0.0 , 1.0 );
			int temp_output_26_0_g100 = (int)0.5;
			float temp_output_22_0_g100 = pow( ( 1.0 - clampResult14_g100 ) , (float)temp_output_26_0_g100 );
			float lerpResult32_g100 = lerp( 0.15 , temp_output_30_0_g100 , ( 1.0 - temp_output_22_0_g100 ));
			float clampResult13_g100 = clamp( ( ( 1.0 - temp_output_6_0_g100 ) / ( 1.0 - temp_output_4_0_g100 ) ) , 0.0 , 1.0 );
			float temp_output_21_0_g100 = pow( ( 1.0 - clampResult13_g100 ) , (float)temp_output_26_0_g100 );
			float lerpResult33_g100 = lerp( 0.35 , temp_output_30_0_g100 , ( 1.0 - temp_output_21_0_g100 ));
			float lerpResult37_g100 = lerp( lerpResult32_g100 , lerpResult33_g100 , floor( ( 1.0 - temp_output_22_0_g100 ) ));
			float lerpResult149 = lerp( 1.0 , (float)0 , lerpResult37_g100);
			float temp_output_228_0 = ( lerpResult149 * 1.0 );
			float2 uv0_DiffuseInputHighpass = i.uv_texcoord * _DiffuseInputHighpass_ST.xy + _DiffuseInputHighpass_ST.zw;
			float2 temp_output_6_0_g98 = uv0_DiffuseInputHighpass;
			float2 temp_output_1_0_g99 = ( _GlossHighpassOffset / _DiffuseInputHighpass_TexelSize ).xy;
			float4 temp_output_28_0_g98 = ( ( tex2D( _DiffuseInputHighpass, ( temp_output_6_0_g98 + ( float2( 0,1 ) * temp_output_1_0_g99 ) ) ) + tex2D( _DiffuseInputHighpass, ( temp_output_6_0_g98 + ( float2( 1,0 ) * temp_output_1_0_g99 ) ) ) ) + ( tex2D( _DiffuseInputHighpass, ( temp_output_6_0_g98 + ( float2( 0,-1 ) * temp_output_1_0_g99 ) ) ) + tex2D( _DiffuseInputHighpass, ( temp_output_6_0_g98 + ( float2( -1,0 ) * temp_output_1_0_g99 ) ) ) ) );
			float4 temp_cast_13 = (_GlossHighpassStrength).xxxx;
			float clampResult361 = clamp( ( ( pow( ( ( tex2D( _DiffuseInputHighpass, temp_output_6_0_g98 ) - ( ( temp_output_28_0_g98 + ( ( tex2D( _DiffuseInputHighpass, ( temp_output_6_0_g98 + ( float2( -0.5,0.5 ) * temp_output_1_0_g99 ) ) ) + tex2D( _DiffuseInputHighpass, ( temp_output_6_0_g98 + ( float2( 0.5,0.5 ) * temp_output_1_0_g99 ) ) ) ) + ( tex2D( _DiffuseInputHighpass, ( temp_output_6_0_g98 + ( float2( 0.5,-0.5 ) * temp_output_1_0_g99 ) ) ) + tex2D( _DiffuseInputHighpass, ( temp_output_6_0_g98 + ( float2( -0.5,-0.5 ) * temp_output_1_0_g99 ) ) ) ) ) ) / 8.0 ) ) + 1.0 ) , temp_cast_13 ) * 0.5 ) * 1.0 ).g , 0.0 , 1.0 );
			float lerpResult481 = lerp( temp_output_228_0 , clampResult361 , _GlossHighpassRange);
			#ifdef _GLOSSHIGHPASSDETAIL_ON
				float staticSwitch469 = lerpResult481;
			#else
				float staticSwitch469 = temp_output_228_0;
			#endif
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
			float fresnelNdotV187 = dot( mul(ase_tangentToWorldFast,Normal682), ase_worldViewDir );
			float fresnelNode187 = ( 0.23 + 1.03 * pow( 1.0 - fresnelNdotV187, 0.71 ) );
			float4 temp_cast_14 = (fresnelNode187).xxxx;
			float4 temp_cast_15 = (0.0).xxxx;
			float4 temp_cast_16 = (0.25).xxxx;
			float4 clampResult206 = clamp( CalculateContrast(0.0,temp_cast_14) , temp_cast_15 , temp_cast_16 );
			float fresnelNdotV426 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode426 = ( 0.05 + 1.0 * pow( 1.0 - fresnelNdotV426, 5.0 ) );
			float clampResult444 = clamp( saturate( ( 1.0 - fresnelNode426 ) ) , 0.0 , 1.0 );
			float4 temp_output_152_0 = ( staticSwitch469 * _GlossMultiply * ( clampResult206 * clampResult444 ) );
			float grayscale659 = Luminance(CalculateContrast(8.0,temp_output_152_0).rgb);
			float fresnelNdotV491 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode491 = ( -0.33 + 0.8 * pow( 1.0 - fresnelNdotV491, 1.52 ) );
			float lerpResult506 = lerp( ( 1.0 - (grayscale659*1.53 + -0.4) ) , fresnelNode491 , 0.15);
			float clampResult644 = clamp( ( 1.0 - ( lerpResult506 + fresnelNode491 ) ) , 0.0 , 1.0 );
			float clampResult625 = clamp( ( ( 1.0 - ( grayscale653 + grayscale654 ) ) - clampResult644 ) , 0.0 , 1.0 );
			float4 lerpResult604 = lerp( temp_output_23_0 , ( temp_output_23_0 + ( _SSSColor * temp_output_23_0 * _SSSBlend ) ) , clampResult625);
			#ifdef _SSSTOGGLE_ON
				float staticSwitch661 = 1.0;
			#else
				float staticSwitch661 = 0.0;
			#endif
			float4 lerpResult606 = lerp( temp_output_23_0 , lerpResult604 , staticSwitch661);
			o.Albedo = lerpResult606.rgb;
			o.Metallic = 0.0;
			float4 temp_cast_19 = (0.0).xxxx;
			float4 temp_cast_20 = (1.0).xxxx;
			float4 clampResult692 = clamp( temp_output_152_0 , temp_cast_19 , temp_cast_20 );
			float grayscale691 = Luminance(clampResult692.rgb);
			float grayscale566 = Luminance(temp_output_152_0.rgb);
			#ifdef _GLOSSFRESNELDETAIL_ON
				float staticSwitch688 = grayscale566;
			#else
				float staticSwitch688 = grayscale691;
			#endif
			o.Smoothness = staticSwitch688;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16700
1;1;1918;1137;601.558;-361.312;1.864853;True;True
Node;AmplifyShaderEditor.SamplerNode;1;-2466.532,497.232;Float;True;Property;_GM;GM;1;0;Create;True;0;0;True;0;None;88ba0e393819b084db2fbbdf82e5dcd4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;265;-1679.723,134.8576;Float;False;1749.433;361.6672;Comment;7;8;260;261;259;263;44;682;Normal;0.4901961,0.4901961,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;483;-1918.043,455.0163;Float;False;2153.696;634.7283;Comment;12;326;325;356;359;396;358;392;462;393;361;481;482;HighpassFilter;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;744;-1997.591,1186.06;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;325;-1497.808,736.793;Float;False;Property;_GlossHighpassStrength;Gloss HighpassStrength;20;0;Create;True;0;0;False;0;7;7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;326;-1868.043,523.8749;Float;True;Property;_DiffuseInputHighpass;DiffuseInput Highpass;17;0;Create;True;0;0;False;0;None;2b7bbebdacae31441a6882fa1b611dd1;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.WireNode;745;-1875.707,1236.359;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;8;-1629.723,184.8576;Float;True;Property;_Normal;Normal;13;0;Create;True;0;0;True;0;None;1675f72f105e0fc429bce7e860c623a2;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;264;-1829.195,1099.061;Float;False;2011.093;942.9811;Comment;14;232;196;195;148;193;194;170;151;150;149;228;231;442;695;Gloss;0.6839622,0.8972042,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;356;-1761.716,819.0895;Float;False;Property;_GlossHighpassOffset;Gloss HighpassOffset;21;0;Create;True;0;0;False;0;9;9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;194;-1256.003,1357.189;Float;False;Constant;_Float13;Float 13;19;0;Create;True;0;0;False;0;0.6;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;148;-1264.062,1210.248;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;425;-1592.118,1996.457;Float;False;1011.198;309.3849;Simple fresnel blend;6;444;446;433;447;429;426;Blend Factor;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;196;-1250.401,1570.344;Float;False;Constant;_Float15;Float 15;19;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;396;-1187.909,537.5932;Float;True;HighPassTexture;-1;;98;8fcb27c32ddabcd469911f1d88fb638e;1,46,0;6;1;FLOAT;0;False;2;INT;0;False;6;FLOAT2;0,0;False;9;SAMPLER2D;0;False;38;INT;0;False;50;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;232;-1775.78,1656.024;Float;False;1692.355;374.0699;Surface Fresnel;9;187;146;162;147;191;206;207;208;684;Surface Fresnel;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;359;-942.7996,810.0804;Float;False;Constant;_Float1;Float 1;28;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;682;-1344.778,184.8089;Float;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;195;-1259.003,1287.188;Float;False;Constant;_Float14;Float 14;19;0;Create;True;0;0;False;0;0.35;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;231;-1255.33,1501.374;Float;False;Constant;_Float18;Float 18;19;0;Create;True;0;0;False;0;0.58;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;193;-1257.003,1430.19;Float;False;Constant;_Float12;Float 12;19;0;Create;True;0;0;False;0;0.15;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;147;-1069.068,1915.093;Float;False;Constant;_Float21;Float 21;20;0;Create;True;0;0;False;0;0.71;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;426;-1555.769,2047.287;Float;True;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;1;FLOAT;0.05;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;170;-1036.582,1393.162;Float;True;3PointLevels;-1;;100;9714f1ca5b797134b8312f7d99e411e7;6,46,0,28,0,17,0,19,0,45,0,27,0;12;29;FLOAT;1;False;30;FLOAT;0.5;False;31;FLOAT;0;False;1;FLOAT;1;False;4;FLOAT;0.5;False;6;INT;0;False;7;FLOAT;0;False;23;FLOAT;0;False;24;FLOAT;0;False;25;FLOAT;0;False;40;FLOAT;0;False;26;INT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;684;-1172.518,1691.018;Float;False;682;Normal;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IntNode;151;-849.9631,1225.869;Float;False;Constant;_Int0;Int 0;20;0;Create;True;0;0;False;0;0;0;0;1;INT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;358;-765.1741,597.2067;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;146;-1113.78,1761.194;Float;False;Constant;_Float20;Float 20;20;0;Create;True;0;0;False;0;0.23;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;150;-848.9225,1149.061;Float;False;Constant;_Float22;Float 22;20;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;268;-1750.158,-1172.587;Float;False;1950.575;875.6668;Comment;22;2;28;29;17;16;30;19;31;20;33;34;15;21;43;35;41;36;42;299;678;680;739;Mask Tint;0.3254717,1,0.3506416,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;162;-1086.789,1838.421;Float;False;Constant;_Float26;Float 26;21;0;Create;True;0;0;False;0;1.03;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;392;-503.9229,688.9029;Float;False;Constant;_Float7;Float 7;29;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;393;-474.3656,770.6503;Float;False;Constant;_Float8;Float 8;29;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;429;-1257.371,2049.727;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;187;-882.8997,1713.823;Float;True;Standard;TangentNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-1347.284,-629.1962;Float;False;Property;_Color2Multiply;Color2 Multiply;10;0;Create;True;0;0;True;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;149;-617.6086,1210.184;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;695;-516.2562,1450.758;Float;False;Constant;_Float29;Float 29;29;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;742;-1955.65,-390.2887;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;741;-2180.228,-809.3814;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;462;-536.8921,505.0163;Float;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ColorNode;2;-1559.11,-1135.721;Float;False;Property;_Color1;Color1;5;0;Create;True;0;0;True;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;17;-1336.212,-1029.787;Float;False;Property;_Color1Multiply;Color1 Multiply;7;0;Create;True;0;0;True;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;28;-1561.695,-721.1685;Float;False;Property;_Color2;Color2;8;0;Create;True;0;0;True;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;207;-460.0458,1811.344;Float;False;Constant;_Float10;Float 10;19;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;447;-1002.01,2147.256;Float;False;Constant;_Float6;Float 6;19;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;446;-972.3754,2224.077;Float;False;Constant;_Float5;Float 5;19;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleContrastOpNode;191;-571.4557,1713.334;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;228;-292.7889,1304.089;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-1158.711,-721.996;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;743;-1888.427,-468.9907;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;361;-298.0659,593.1935;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;482;-482.1912,890.3513;Float;False;Property;_GlossHighpassRange;Gloss HighpassRange;22;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;208;-461.36,1891.423;Float;False;Constant;_Float11;Float 11;19;0;Create;True;0;0;False;0;0.25;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;433;-1087.718,2051.235;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1217.808,-560.5173;Float;False;Property;_Color2Power;Color2 Power;9;0;Create;True;0;0;True;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;740;-2099.167,-880.9063;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1203.41,-961.1077;Float;False;Property;_Color1Power;Color1 Power;6;0;Create;True;0;0;True;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-1144.313,-1122.587;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;567;63.37961,1361.591;Float;False;803.1596;304.095;Comment;6;320;692;693;694;152;230;Gloss Output;1,1,1,1;0;0
Node;AmplifyShaderEditor.ClampOpNode;206;-258.4224,1714.217;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;680;-1340.08,-527.8826;Float;False;Mask2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;678;-1416.52,-942.0917;Float;False;Mask1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;444;-804.4691,2046.698;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;481;-29.34646,836.7447;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;20;-971.3282,-1121.107;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;670;632.5109,135.3962;Float;False;1948.026;1308.183;SSS Albedo Blend;11;596;663;662;661;604;668;508;595;623;625;575;SSS;0.9811321,0.8022823,0.3100747,1;0;0
Node;AmplifyShaderEditor.PowerNode;33;-987.4097,-720.5163;Float;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;230;76.49834,1587.813;Float;False;Property;_GlossMultiply;Gloss Multiply;16;0;Create;True;0;0;False;0;0;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;508;800.0056,831.0129;Float;False;1680.531;612.5657;Costum SSS Mask;12;451;450;496;498;497;501;506;505;507;548;659;676;Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-718.9026,-548.035;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-704.5043,-948.6254;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;469;99.87152,1225.775;Float;False;Property;_GlossHighpassDetail;Gloss HighpassDetail;18;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;442;-49.74664,1713.239;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;394.9741,1417.678;Float;True;3;3;0;FLOAT;0;False;1;FLOAT;1;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-505.7951,-723.212;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;737;-828.6651,-324.7886;Float;False;1114.975;534.5632;Comment;9;729;734;712;724;722;736;735;727;731;AO Blend;0.3349057,0.8980392,1,0.7686275;0;0
Node;AmplifyShaderEditor.RangedFloatNode;451;848.4511,1171.348;Float;False;Constant;_Float9;Float 9;29;0;Create;True;0;0;False;0;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;299;-362.7072,-923.9416;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;267;-1675.45,-262.1909;Float;False;881.0246;382.5923;;5;26;27;22;25;99;Diffuse;0.8679245,0.3417134,0.1596654,1;0;0
Node;AmplifyShaderEditor.SimpleContrastOpNode;450;1028.957,1047.995;Float;True;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;729;-605.0538,-57.26985;Float;False;Property;_AODiffuseBlend;AO Diffuse Blend;12;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-362.4603,-1048.486;Float;False;Constant;_Float2;Float 2;11;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;703;-781.8651,11.27864;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;25;-1379.15,-18.60638;Float;False;Property;_DiffuseMultiply;Diffuse Multiply;3;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;676;1514.283,1135.365;Float;False;558.7162;288.9884;SSS Fresnel;4;491;503;494;495;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCGrayscale;659;1306.544,909.837;Float;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;498;1327.374,1060.475;Float;False;Constant;_Float25;Float 25;32;0;Create;True;0;0;False;0;1.53;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleContrastOpNode;35;-209.2186,-993.5648;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;99;-1562.05,-212.1909;Float;True;Property;_Diffuse;Diffuse;0;0;Create;False;0;0;True;0;None;2b7bbebdacae31441a6882fa1b611dd1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;734;-320.3339,-30.78859;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;497;1344.586,1140.721;Float;False;Constant;_Float24;Float 24;32;0;Create;True;0;0;False;0;-0.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;712;-542.2278,56.09169;Float;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;724;-329.4723,60.89476;Float;False;Constant;_Float34;Float 34;32;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;503;1604.971,1350.341;Float;False;Constant;_Float27;Float 27;32;0;Create;True;0;0;False;0;1.52;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1121.261,-70.13689;Float;False;Property;_DiffusePower;Diffuse Power;2;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;41;27.32412,-885.9156;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-1149.687,-202.3779;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;495;1526.223,1206.692;Float;False;Constant;_Float23;Float 23;32;0;Create;True;0;0;False;0;-0.33;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;494;1563.827,1277.431;Float;False;Constant;_Float19;Float 19;32;0;Create;True;0;0;False;0;0.8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;736;-360.3339,-274.7886;Float;False;Constant;_Float32;Float 32;32;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;496;1536.699,913.1494;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;722;-173.5611,-43.22534;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;491;1782.594,1163.408;Float;True;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;739;-2.359326,-399.6407;Float;False;Constant;_Float33;Float 33;33;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;501;1782.81,910.5465;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-2.686821,-674.1914;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;735;-189.3339,-273.7886;Float;False;Property;_AODiffuseToggle;AO Diffuse Toggle;11;0;Create;True;0;0;False;0;0;1;1;True;;Toggle;2;Key0;Key1;Create;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-934.6589,-199.0262;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;677;1712.336,1475.623;Float;False;819.6956;308.634;Comment;6;681;679;655;649;654;653;Mask Inputs;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;731;-52.05196,-153.9537;Float;False;Constant;_Float31;Float 31;31;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;507;1851.91,1024.709;Float;False;Constant;_SurfaceBlend;Surface Blend;32;0;Create;True;0;0;False;0;0.15;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;506;2060.941,926.0665;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;679;1746.157,1570.921;Float;False;678;Mask1;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;694;597.9548,1594.57;Float;False;Constant;_Float28;Float 28;29;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;727;117.3102,-192.8754;Float;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;693;578.9987,1519.784;Float;False;Constant;_Float4;Float 4;29;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;681;1746.275,1651.068;Float;False;680;Mask2;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;738;164.9632,-441.6012;Float;False;Property;_MaskColorizeToggle;Mask ColorizeToggle;4;0;Create;True;0;0;False;0;0;0;1;True;;Toggle;2;Key0;Key1;Create;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;505;2254.863,1065.2;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;654;1934.728,1651.712;Float;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;282.4606,-196.7513;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCGrayscale;653;1937.423,1570.637;Float;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;660;2499.363,967.6359;Float;False;591.5249;473.2188;;5;658;646;645;644;657;SSS Edge Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.ClampOpNode;692;734.1865,1430.527;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;658;2531.076,1222.503;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;649;2178.632,1598.719;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;646;2747.356,1327.073;Float;False;Constant;_Float41;Float 41;35;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;691;916.271,1458.078;Float;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;566;917.6935,1538.305;Float;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;645;2734.162,1249.414;Float;False;Constant;_Float40;Float 40;35;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;664;440.6611,464.4399;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;665;515.723,530.4036;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;688;1140.931,1484.112;Float;False;Property;_GlossFresnelDetail;Gloss FresnelDetail;19;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;575;1200.492,546.681;Float;False;Property;_SSSColor;SSS Color;25;0;Create;True;0;0;False;0;0.7176471,0.6627451,0.5607843,0;0.7176471,0.6627451,0.5607843,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;595;1220.455,722.6687;Float;False;Property;_SSSBlend;SSS Blend;24;0;Create;True;0;0;False;0;0.45;0.45;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;655;2334.031,1554.235;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;666;504.35,289.2962;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;644;2893.942,1216.201;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;623;1694.852,624.9767;Float;False;Constant;_Float36;Float 36;36;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;672;3119.89,1471.867;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;624;1697.149,704.7999;Float;False;Constant;_Float37;Float 37;36;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;667;561.2151,339.3374;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;669;587.9427,191.0815;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;591;1513.52,485.4499;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;657;2677.279,1017.636;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;260;-908.0804,368.8199;Float;False;Property;_NormalStrength;Normal Strength;14;0;Create;True;0;0;False;0;1;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;663;1563.861,281.8174;Float;False;Constant;_Float17;Float 17;36;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;673;3211.016,1400.611;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;662;1578.355,202.0832;Float;False;Constant;_Float16;Float 16;36;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;668;682.5109,242.9418;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;261;-628.7811,207.5927;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;596;1723.86,324.1009;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;259;-629.7816,304.9643;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;625;1852.007,625.2231;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;263;-389.6963,229.3357;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;671;3228.964,282.2732;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;604;2007.601,209.7148;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;661;1729.081,185.3962;Float;False;Property;_SSSToggle;SSS Toggle;23;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;160;3092.678,112.5203;Float;False;Constant;_MatallicIntdicator;Matallic Intdicator;21;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-1346.443,-785.1342;Float;False;Property;_Float0;Float 0;15;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;548;2355.517,887.3243;Float;False;Constant;_Float30;Float 30;34;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;320;127.8271,1409.98;Float;False;Constant;_Color0;Color 0;27;0;Create;True;0;0;False;0;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;675;3244.622,192.0311;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;44;-115.2898,240.7235;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;606;2191.492,-189.9942;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;183;3412.704,46.12523;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;RP_Rigged_MasterShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;744;0;1;1
WireConnection;745;0;744;0
WireConnection;148;0;745;0
WireConnection;396;1;356;0
WireConnection;396;9;326;0
WireConnection;396;50;325;0
WireConnection;682;0;8;0
WireConnection;170;29;195;0
WireConnection;170;30;194;0
WireConnection;170;31;193;0
WireConnection;170;4;231;0
WireConnection;170;6;148;0
WireConnection;170;26;196;0
WireConnection;358;0;396;0
WireConnection;358;1;359;0
WireConnection;429;0;426;0
WireConnection;187;0;684;0
WireConnection;187;1;146;0
WireConnection;187;2;162;0
WireConnection;187;3;147;0
WireConnection;149;0;150;0
WireConnection;149;1;151;0
WireConnection;149;2;170;0
WireConnection;742;0;1;3
WireConnection;741;0;1;2
WireConnection;462;0;358;0
WireConnection;191;1;187;0
WireConnection;228;0;149;0
WireConnection;228;1;695;0
WireConnection;31;0;28;0
WireConnection;31;1;29;0
WireConnection;743;0;742;0
WireConnection;361;0;462;1
WireConnection;361;1;392;0
WireConnection;361;2;393;0
WireConnection;433;0;429;0
WireConnection;740;0;741;0
WireConnection;16;0;2;0
WireConnection;16;1;17;0
WireConnection;206;0;191;0
WireConnection;206;1;207;0
WireConnection;206;2;208;0
WireConnection;680;0;743;0
WireConnection;678;0;740;0
WireConnection;444;0;433;0
WireConnection;444;1;447;0
WireConnection;444;2;446;0
WireConnection;481;0;228;0
WireConnection;481;1;361;0
WireConnection;481;2;482;0
WireConnection;20;0;16;0
WireConnection;20;1;19;0
WireConnection;33;0;31;0
WireConnection;33;1;30;0
WireConnection;34;0;33;0
WireConnection;34;1;680;0
WireConnection;15;0;20;0
WireConnection;15;1;678;0
WireConnection;469;1;228;0
WireConnection;469;0;481;0
WireConnection;442;0;206;0
WireConnection;442;1;444;0
WireConnection;152;0;469;0
WireConnection;152;1;230;0
WireConnection;152;2;442;0
WireConnection;21;0;15;0
WireConnection;21;1;34;0
WireConnection;299;0;21;0
WireConnection;450;1;152;0
WireConnection;450;0;451;0
WireConnection;703;0;682;0
WireConnection;659;0;450;0
WireConnection;35;1;299;0
WireConnection;35;0;36;0
WireConnection;734;0;729;0
WireConnection;712;0;703;2
WireConnection;41;0;35;0
WireConnection;22;0;99;0
WireConnection;22;1;25;0
WireConnection;496;0;659;0
WireConnection;496;1;498;0
WireConnection;496;2;497;0
WireConnection;722;0;712;0
WireConnection;722;1;734;0
WireConnection;722;2;724;0
WireConnection;491;1;495;0
WireConnection;491;2;494;0
WireConnection;491;3;503;0
WireConnection;501;0;496;0
WireConnection;42;0;41;0
WireConnection;42;1;21;0
WireConnection;735;1;736;0
WireConnection;735;0;722;0
WireConnection;27;0;22;0
WireConnection;27;1;26;0
WireConnection;506;0;501;0
WireConnection;506;1;491;0
WireConnection;506;2;507;0
WireConnection;727;0;27;0
WireConnection;727;1;735;0
WireConnection;727;2;731;0
WireConnection;738;1;739;0
WireConnection;738;0;42;0
WireConnection;505;0;506;0
WireConnection;505;1;491;0
WireConnection;654;0;681;0
WireConnection;23;0;727;0
WireConnection;23;1;738;0
WireConnection;653;0;679;0
WireConnection;692;0;152;0
WireConnection;692;1;693;0
WireConnection;692;2;694;0
WireConnection;658;0;505;0
WireConnection;649;0;653;0
WireConnection;649;1;654;0
WireConnection;691;0;692;0
WireConnection;566;0;152;0
WireConnection;664;0;23;0
WireConnection;665;0;664;0
WireConnection;688;1;691;0
WireConnection;688;0;566;0
WireConnection;655;0;649;0
WireConnection;666;0;23;0
WireConnection;644;0;658;0
WireConnection;644;1;645;0
WireConnection;644;2;646;0
WireConnection;672;0;688;0
WireConnection;667;0;666;0
WireConnection;669;0;23;0
WireConnection;591;0;575;0
WireConnection;591;1;665;0
WireConnection;591;2;595;0
WireConnection;657;0;655;0
WireConnection;657;1;644;0
WireConnection;673;0;672;0
WireConnection;668;0;669;0
WireConnection;261;0;8;1
WireConnection;261;1;260;0
WireConnection;596;0;667;0
WireConnection;596;1;591;0
WireConnection;259;0;8;2
WireConnection;259;1;260;0
WireConnection;625;0;657;0
WireConnection;625;1;623;0
WireConnection;625;2;624;0
WireConnection;263;0;261;0
WireConnection;263;1;259;0
WireConnection;263;2;8;3
WireConnection;671;0;673;0
WireConnection;604;0;668;0
WireConnection;604;1;596;0
WireConnection;604;2;625;0
WireConnection;661;1;662;0
WireConnection;661;0;663;0
WireConnection;675;0;671;0
WireConnection;44;0;263;0
WireConnection;606;0;23;0
WireConnection;606;1;604;0
WireConnection;606;2;661;0
WireConnection;183;0;606;0
WireConnection;183;1;44;0
WireConnection;183;3;160;0
WireConnection;183;4;675;0
ASEEND*/
//CHKSM=35A6A341805DAD0670C57A150B9685E34DDACDF5