Shader "Unlit/PlannerReflection"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_seaColor("SeaColor",Color) = (0,0,0,0)
		_reflectionColor("ReflectionColor",Color) = (0,0,0,0)
	}
		SubShader
	{
		Tags { "RenderType" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

		sampler2D _ReflectionSeaTex;
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 screenPos : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float2 baseUV:VAR_BASE_UV;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _seaColor;
			float4 _reflectionColor;
			
            float4 ComputeNDCPos(float4 posCS)
            {
               float4 posNDC    = 0;
               posNDC.xy = float2(posCS.x , posCS.y * _ProjectionParams.x) + posCS.w;
                posNDC.xy = posNDC.xy / posCS.w /2;
               posNDC.zw 	    = posCS.zw;
               return posNDC;
            }
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.screenPos = ComputeScreenPos(o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed col = tex2D(_ReflectionSeaTex,i.screenPos.xy/i.screenPos.w).r;
				fixed4 finalColor = lerp(_seaColor,_reflectionColor,col);
				return finalColor;
			}
			ENDCG
		}
	}
}