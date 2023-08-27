Shader "Unlit/Plane"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 posUV : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            // float4 ComputeNDCPos(float4 posCS)
            // {
            //    float4 posNDC    = 0;
            //    posNDC.xy = float2(posCS.x , posCS.y * _ProjectionParams.x) + posCS.w;
            //     posNDC.xy = posNDC.xy / posCS.w /2;
            //    posNDC.zw 	    = posCS.zw;
            //    return posNDC;
            // }
            
            float4 ComputeNDCPos1(float4 posCS)
            {
               float4 posNDC    = 0;
                float wh = _ScreenParams.x / _ScreenParams.y;
               posNDC.xy = float2(posCS.x, posCS.y / wh) + posCS.w;
                posNDC.xy = posNDC.xy / posCS.w /2;
               posNDC.zw 	    = posCS.zw;
               return posNDC;
            }
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.posUV = o.vertex;
                // o.vertex.y = -o.vertex.y;
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // float2 ab = ComputeNDCPos(o.vertex);
                // ab.y = 1-ab.y;
                // // ab.x = 1-ab.x;
                // o.uv = ab;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                                float2 ab = ComputeNDCPos1(i.posUV);

                fixed4 col = tex2D(_MainTex, ab);
                // fixed4 col = i.vertex.x;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
