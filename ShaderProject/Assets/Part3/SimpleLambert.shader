Shader "Custom/SimpleLambert"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Color("Diffuse", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        
        #pragma surface surf  PureColor//SimpleLambert

        struct Input
        {
            float2 uv_MainTex;
        };
        sampler2D _MainTex;
        float4 _Color;

        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex);
        }

        //表面着色器的输出等于光照模型的输入
        half4 LightingSimpleLambert(SurfaceOutput s, half3 lightDir, half atten)
        {
            half f = max(dot(s.Normal, lightDir), 0);
            half4 c;
            //_LightColor0是unity预定义的，表示第0盏灯光的颜色值
            c.rgb = s.Albedo * _LightColor0.rgb * f * atten * _Color;
            c.a = s.Alpha;
            return c;

            // c.xyz = s.Albedo * _LightColor0.xyz * f * atten;
            // c.a = s.Alpha;
            // return c;
        }

        half4 LightingPureColor(SurfaceOutput s, half3 lightDir, half atten)
        {
            half4 c;
            c.rgb = _Color;
            c.a = s.Alpha;
            return c;
        }

        ENDCG
    }
    FallBack "Diffuse"
}
