//切线空间计算法线纹理
Shader "Unity Shader Book/Chapter7/NormalMapTangentSpaceMat"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap("Normal Map", 2D) = "bump" {}  // bump是unity内置的法线纹理, 当没有提供任何法线纹理时,bump就对应了模型自带的法线信息
        _BumpScale("BumpScale", Float) = 1.0    //控制凹凸程度 当它为0时,表示该法线纹理不会对光照产生任何影响
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags { "LightMode" = "ForwardBase" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST; 
            sampler2D _BumpMap;
            float4 _BumpMap_ST; 
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;


            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float3 texcoord : TEXCOORD0;// 将模型的第一组纹理存储到该变量
                float4 tangent : TANGENT;//切线方向
            };


            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;//xy分量存_MainTex的纹理坐标
                // o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;//zw分量存_BumpMap的纹理坐标

                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

                //计算切线空间变换矩阵(从模型空间变到切线空间)
                // float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;//叉乘得到副法线方向 w决定了其方向
                // Construct a matrix which transform vectors from object space to tangent space
                // float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);

                TANGENT_SPACE_ROTATION;//宏定义,等于上面那两行代码

                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

                return o;
            }
 
            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);

                // Get the texel in the normal map
                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                fixed3 tangentNormal;
                // If the texture is not marked as "Normal map"
                // tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale; // 法线方向 = 像素方向 * 2 - 1
                // tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                // Or mark the texture as "Normal map", and use the built-in function
                tangentNormal = UnpackNormal(packedNormal);//源码在上面,将像素颜色信息转化为法线信息
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy))); // tangentNormal是单位矢量

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);

                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss); 

                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
