// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//逐顶点高光反射
Shader "Unity Shader Book/Chapter6/SpecularVertexLevel"
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
                fixed3 color : COLOR;
            };

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                //Get ambient term
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //Transform the normal from object space to world space
                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));


                // Get the light direction in world space 入射光
                //_WorldSpaceLightPos0可以得到光源方向(假设只有一个光源且为平行光,若是多个光源则不顶用)
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);


                //Compute diffuse term
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));


                // Get the reflect direction in world space 出射方向
                // 由于CG的reflect函数的入射方向要求是由光源指向交点处,因此需要对worldLightDir取反
                fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));


                //Get the view direction in world space 获取观察方向
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);


                //Compute specular term
                //pow函数用于计算一个数的幂
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

                o.color = ambient + diffuse + specular;
                return o;
            }

             fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
