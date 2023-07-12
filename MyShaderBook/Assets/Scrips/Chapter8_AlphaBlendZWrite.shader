// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//开启深度写入的半透明效果
Shader "Unity Shader Book/Chapter8/Chapter8_AlphaBlendZWrite"
{
    Properties
    {
        _Color("MainTint", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
        _AlphaScale("Alpha Scale", Range(0,1)) = 1 //在透明纹理的基础上调整整体的透明度
    }
    SubShader
    {
        //RenderType标签可以让Unity把这个Shader归入到提前定义的组 通常被用于着色器替换功能
        //IgnoreProjector = true 表示不会受到投影器的影响
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType"="Transparent" }

        //这个Pass开启深度写入,但不输出颜色,目的仅仅是为了把该模型的深度值写入深度缓冲中.从而剔除模型中被自身遮挡的片元
        //会有额外的性能消耗
        Pass
        {
            ZWrite On
            //ColorMask用于设置颜色通道的写掩码.当ColorMask设为0时,意味着该PASS不写入任何颜色通道,即不会输出任何颜色 
            ColorMask 0
        }

        Pass
        {
            Tags{"LightMode" = "ForwardBase"}

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha // 源颜色的混合因子 目标颜色的混合因子
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed _AlphaScale;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed4 texColor = tex2D(_MainTex, i.uv);

                fixed3 albedo = texColor.rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

                return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
