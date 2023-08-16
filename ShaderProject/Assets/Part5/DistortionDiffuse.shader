Shader "Hidden/DistortionDiffuse"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DisplaceTex("Displacement Map", 2D) = "bump"{}
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
            sampler2D _DisplaceTex;

            fixed4 frag (v2f_img i) : SV_Target
            {
                half2 n = tex2D(_DisplaceTex, i.uv);
                half2 d = n * 2 - 1; //从颜色值转为单位向量
                //因为颜色值的范围通常是0到1，而单位向量的范围是-1到1。因此，将颜色值乘以2并减去1可以将其转换为单位向量。
                i.uv += d;
                i.uv = saturate(i.uv); //将值夹持到[0,1]

                float4 c = tex2D(_MainTex, i.uv);

                return c;
            }
            ENDCG
        }
    }
}
