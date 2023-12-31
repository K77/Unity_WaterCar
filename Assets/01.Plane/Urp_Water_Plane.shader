﻿Shader "URP/WaterPlane"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor("Color",Color)=(1,1,1,1)
        _SpecularRange("SpecularRange",Range(10,300))=10
        _SpecularColor("SpecularColor",Color)=(1,1,1,1)
        
                _Speed ("Speed", Range(0, 10)) = 1
        _Height ("Height", Range(0, 1)) = 0.1
    }
    SubShader

    {
        Tags { "RenderType"="Opaque" 
        "RenderPipeline"="UniversalRenderPipeline"}
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_ST;
        real4 _BaseColor;
        float _SpecularRange;
        real4 _SpecularColor;
                    float _Speed;
            float _Height;
        CBUFFER_END
        

        ENDHLSL
        
        
        Pass
        {
            Tags{
                "LightMode"="UniversalForward"
            }
            HLSLPROGRAM
            #pragma vertex vert1
            #pragma fragment  frag1

            struct  a2v
            {
                float4 positionOS:POSITION ;
                float3 normalOS:NORMAL;
                float2 texcoord:TEXCOORD0;
            } ;

            struct v2f
            {
                float4 positionCS:SV_POSITION;
                float4 positionUV:TEXCOORD2;
                float3 normalWS:NORMAL;
                float3 viewDirWS:TEXCOORD0 ; 
                float2 texcoord:TEXCOORD1  ;
            };
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
            float4 ComputeNDCPos(float4 posCS)
            {
               float4 posNDC    = 0;
                float wh = _ScreenParams.x / _ScreenParams.y;
               posNDC.xy = float2(posCS.x, posCS.y / wh) + posCS.w;
                posNDC.xy = posNDC.xy / posCS.w /2;
               posNDC.zw 	    = posCS.zw;
               return posNDC;
            }
            
            v2f vert1(a2v i)
            {
                v2f o;
                o.positionCS=TransformObjectToHClip(i.positionOS.xyz);
                o.positionUV=o.positionCS;
                o.normalWS=TransformObjectToWorldNormal(i.normalOS,true);
                o.viewDirWS=normalize(_WorldSpaceCameraPos.xyz-TransformObjectToWorld(i.positionOS.xyz));//得到世界空间的视图方向

                // float4 worldPos = mul(unity_ObjectToWorld, o.positionCS);
                // float2 offset = float2(sin(_Time.y * _Speed + worldPos.x * 0.01),
                // sin(_Time.y * _Speed + worldPos.y * 0.01));
                // o.positionCS.xy += offset * _Height;

            
                // float2 ab = ComputeNDCPos(o.positionCS);
                // ab.y = 1-ab.y;
                // // ab.x = 1-ab.x;
                // o.texcoord = ab;
            
                // o.texcoord=TRANSFORM_TEX(i.texcoord,_MainTex);
                return  o;
            } 

            real4 frag1(v2f i):SV_TARGET
            {
                float2 ab = ComputeNDCPos(i.positionUV);
                                // float2 ab = i.positionCS / 1000.0;

                // ab.y = 1-ab.y;
                // ab.x = 1-ab.x;
                i.texcoord = ab;
                return SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.texcoord);
                //if (i.texcoord.y <0 || i.texcoord.y>1)
                // {
                //     clip(i.texcoord.y);
                //     clip(1-i.texcoord.y);
                // }
                Light mylight=GetMainLight();
                float3 LightDirWS=normalize( mylight.direction);
                float spe=dot(normalize(LightDirWS+i.viewDirWS),i.normalWS);//需要取正数
                real4 specolor=pow(saturate(spe),_SpecularRange)*_SpecularColor;
                real4 texcolor=(dot(i.normalWS,LightDirWS)*0.5+0.5)*SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.texcoord)*_BaseColor/PI;

                texcolor*=real4(mylight.color,1);
                return specolor+texcolor;
            }
            ENDHLSL
        }
    }
}