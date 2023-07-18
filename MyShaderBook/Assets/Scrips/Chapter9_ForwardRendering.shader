// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "Unity Shader Book/Chapter9/ForwardRendering"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1,1,1,1)
        _Specular("Specular", Color) = (1,1,1,1) //控制材质的高光反射颜色
        _Gloss("Gloss", Range(8.0, 256)) = 20   //控制高光区域大小
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            // Pass for ambient light & first pixel light(direction light)
            Tags { "RenderType"="ForwardBase" }
            CGPROGRAM
            #pragma multi_compile_fwdbase
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
                // o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                o.worldNormal = UnityObjectToWorldNormal(v.normal); //use Build-In

                // o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldPos = UnityObjectToWorldDir(v.vertex).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Get ambient term
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 worldNormal = normalize(i.worldNormal);

                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                //Compute diffuse term
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

                //Get the view direction in world space
                // fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos)); //use Build-In


                //Get the half direction in world space
                fixed3 halfDir = normalize(worldLightDir + viewDir);

                
                //Compute specular term
                fixed3 specular = _LightColor0.rgb * _Specular.rbg * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                // The attenuation of direction light is always 1 衰减值
                fixed atten = 1.0;

                return fixed4(ambient + (diffuse + specular) * atten, 1.0);
            }
            ENDCG
        }
        Pass
        {
            // Pass for other pixel lights
            Tags { "LightMode" = "ForwardAdd" }
            //光照结果可以在帧缓存中与之前的光照结果进行叠加
            Blend One One
            CGPROGRAM

            //Apparently need to add this declaration
            #pragma multi_compile_fwdadd

            #pragma vertex vert
			#pragma fragment frag

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

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
                // o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
                o.worldNormal = UnityObjectToWorldNormal(v.normal); //use Build-In

                // o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldPos = UnityObjectToWorldDir(v.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);

                // 如果是平行光,可以直接使用_WorldSpaceLightPos0表示光源位置
                // 如果是点光源或者是聚光灯,那么_WorldSpaceLightPos0表示的是世界空间下的光源位置,我们需要用这个位置减去世界空间下的顶点位置得到光源方向
                #ifdef USING_DIRECTIONAL_LIGHT
                    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                    fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
                #endif


                //Compute diffuse term
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

                //Get the reflect direction in world space
                fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));


                //Get the view direction in world space
                // fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos)); //use Build-In


                //Get the half direction in world space
                fixed3 halfDir = normalize(worldLightDir + viewDir);

                
                //Compute specular term
                fixed3 specular = _LightColor0.rgb * _Specular.rbg * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

                // The attenuation of direction light is always 1 衰减值
                // fixed atten = 1.0;

                // #ifdef USING_DIRECTIONAL_LIGHT
                //     fixed atten = 1.0;
                // #else
                //     float3 lightCoord = mul(unity_WorldToLight, fixed4(i.worldPos, 1)).xyz;
                //     fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                // #endif

                #ifdef USING_DIRECTIONAL_LIGHT
					fixed atten = 1.0;
				#else
					#if defined (POINT)
				        float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
				        fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #elif defined (SPOT)
				        float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
				        fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #else
				        fixed atten = 1.0;
				    #endif
				#endif


                return fixed4((diffuse + specular) * atten, 1.0);
            }
            ENDCG

        }
    }
    FallBack "Specular"
}
