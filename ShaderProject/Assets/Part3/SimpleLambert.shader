Shader "Custom/SimpleLambert"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        
        #pragma surface surf SimpleLambert

        struct Input
        {
            float2 uv_MainTex;
        };
        sampler2D _MainTex;

        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex);
        }

        half4 LightingSimpleLambert(SurfaceOutput s, half3 lightDir, half atten)
        {
            half f = max(dot(s.Normal, lightDir), 0);
            half4 c;
            //_LightColor0是unity预定义的，表示第0盏灯光的颜色值
            c.rgb = s.Albedo * _LightColor0.rgb * f * atten;
            c.a = s.Alpha;
            return c;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
