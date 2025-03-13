Shader "Custom/NewSurfaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            Name "OutlinePass"
            // 渲染背面
            Cull Front
            ZWrite On
            ZTest LessEqual

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            float4 _OutlineColor;
            float _OutlineWidth;

            v2f vert(appdata v)
            {
                v2f o;
                // 将法线变换到世界空间
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                // 沿法线方向外推
                float3 offsetPos = v.vertex.xyz + worldNormal * _OutlineWidth;
                // 转换到裁剪空间
                o.pos = UnityObjectToClipPos(float4(offsetPos, 1));
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // 纯色填充轮廓
                return _OutlineColor;
            }
            ENDCG
        }

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf ToonLambert fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;  

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Alpha = c.a;
        }

        inline half4 LightingToonLambert (SurfaceOutput s, half3 lightDir, half atten){
            half NdotL = dot(s.Normal, lightDir);
            NdotL = max(0,NdotL);

            half diff = step(0.2, NdotL);

            half3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
            half3 diffuse = _LightColor0.rgb * diff;

            half3 color = (ambient + diffuse) * s.Albedo * atten;
            return half4(color, s.Alpha);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
