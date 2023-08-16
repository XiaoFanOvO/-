Shader "Hidden/CRTDiffuse"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MaskTex("Mask Texture", 2D) = "white"{}
        _maskBlend("Mask Blending", Float) = 0.5
        _maskSize("Mask Size", float) = 1
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _MaskTex;

            fixed _maskBlend;
            fixed _maskSize;

            fixed4 frag (v2f_img i) : SV_Target
            {
                fixed4 base = tex2D(_MainTex, i.uv);
                fixed4 mask = tex2D(_MaskTex, i.uv * _maskSize);
                return lerp(base, mask, _maskBlend);
            }
            ENDCG
        }
    }
}
