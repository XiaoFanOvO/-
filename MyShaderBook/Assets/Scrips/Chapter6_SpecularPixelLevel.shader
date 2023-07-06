// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//逐像素高光反射
Shader "Unity Shader Book/Chapter6/SpecularPixelLevel"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1,1,1,1)
        _Specular("Specular", Color) = (1,1,1,1) //控制材质的高光反射颜色
        _Gloss("Gloss", Range(8.0, 256)) = 20   //控制高光区域大小
    }
    SubShader
    {
        Pass
        {
             Tags { "RenderType"="ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                //Transform the normal from object space to world space
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

             fixed4 frag (v2f i) : SV_Target
            {
                //Get ambient term
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                //Compute diffuse term
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

                //Get the reflect direction in world space
                fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
                //Get the view direction in world space
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                //Compute specular term
                fixed3 specular = _LightColor0.rgb * _Specular.rbg * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
