// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//逐像素光照
Shader "Unity Shader Book/Chapter6/DiffusePixelLevelMat"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1) // 漫反射颜色
    }
    SubShader
    {
        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            // 颜色范围是0-1 所以用fixed精度的变量来存储
            fixed4 _Diffuse;


            //使用一个结构体来定义顶点着色器的输入
            struct a2v{
                // POSITION语义告诉UNITY, 用模型空间的顶点坐标填充vertex变量
                float4 vertex : POSITION;
                // NORMAL语义告诉Unity, 用模型空间的法线方向填充normal变量          
                float3 normal : NORMAL;
            };

            // 使用一个结构体来定义顶点着色器的输出
            struct v2f{
                // SV_POSITION语义告诉Unity, pos里包含了顶点在裁剪空间中的位置信息
                float4 pos : SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
            };

        

            //逐像素中,顶点着色器不需要计算光照模型,只需要把世界空间的法线传递给片元着色器即可
            v2f vert (a2v v)
            {
                v2f o;
                // Transform the vertex from object space to projection space
                o.pos = UnityObjectToClipPos(v.vertex);

                //Transform the normal from object space to world space
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

                return o;

            }


            ///片元着色器计算光照模型
            fixed4 frag (v2f i) : SV_Target
            {
                //Get ambient term 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //Get the normal in world space
                fixed3 worldNormal = normalize(i.worldNormal);

                //Get the light direction in world space 入射光
                //_WorldSpaceLightPos0可以得到光源方向(假设只有一个光源且为平行光,若是多个光源则不顶用)
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                //Compute diffuse term 混合
                //saturate函数用于将x截取到[0,1]的范围
                //_LightColor0用于访问该Pass处理的光源的颜色和强度信息
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

                fixed3 color = ambient + diffuse;

                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
