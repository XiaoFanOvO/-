Shader "Unity Shader Book/Chapter7/SingleTexture"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _Color("Color Tint", Color) = (1,1,1,1)
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags { "LightMode" = "ForwardBase" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            //纹理名_ST 声明某个纹理的属性(缩放scale和平移translation) 
            //_MainTex_ST.xy 存放缩放值
            //_MainTex_ST.zw 存放偏移值
            float4 _MainTex_ST; 
            fixed4 _Specular;
            float _Gloss;


            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float3 texcoord : TEXCOORD0;// 将模型的第一组纹理存储到该变量
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
                // o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw; // 先缩放再平移
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex); // Built-in 拿顶点的uv去和材质球的收缩偏移作运算,确保缩放和偏移是正确值
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                //Use the texture to sample the diffuse color
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;//反射率

                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;// 环境光

                fixed3 diffuse = _LightColor0.rbg * albedo * max(0, dot(worldNormal, worldLightDir));//漫反射

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(worldLightDir + viewDir);

                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);//高光反射

                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
