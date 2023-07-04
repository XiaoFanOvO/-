// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//逐顶点光照
Shader "Unity Shader Book/Chapter6/DiffuseVertexLevel"
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
                // COLOR0 语义可以用于存储颜色信息
                fixed3 color : COLOR0;
            };

        

            // 注意:顶点着色器的输出结构中,必须包含一个变量,它的语义是SV_POSITION
            // 否则渲染器将无法得到裁剪空间中的顶点坐标,也就无法把顶点渲染到屏幕上
            v2f vert (a2v v)
            {

                ///转到世界坐标系计算

                // v2f o;
                // // Transform the vertex from object space to projection space
                // o.pos = UnityObjectToClipPos(v.vertex);

                // //Get ambient term 环境光
                // fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                // //Transform the normal from object space to world space
                // fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

                // //Get the light direction in world space 入射光
                // //_WorldSpaceLightPos0可以得到光源方向(假设只有一个光源且为平行光,若是多个光源则不顶用)
                // fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

                // //Compute diffuse term 混合
                // //saturate函数用于将x截取到[0,1]的范围
                // //_LightColor0用于访问该Pass处理的光源的颜色和强度信息
                // fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));

                // o.color = ambient + diffuse;

                // return o;



                //转到对象坐标系计算
                v2f o;
                // Transform the vertex from object space to projection space
                o.pos = UnityObjectToClipPos(v.vertex);

                //Get ambient term 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //Transform the normal from object space to world space
                fixed3 objNormal = normalize(v.normal);

                //Get the light direction in world space 入射光
                //_WorldSpaceLightPos0可以得到光源方向(假设只有一个光源且为平行光,若是多个光源则不顶用)
                fixed3 objLight = normalize(mul((float3x3)unity_WorldToObject, _WorldSpaceLightPos0));

                //Compute diffuse term 混合
                //saturate函数用于将x截取到[0,1]的范围
                //_LightColor0用于访问该Pass处理的光源的颜色和强度信息
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(objNormal, objLight));

                o.color = ambient + diffuse;

                return o;


            }


            // 注意:顶点着色器是逐顶点调用,片元着色器是逐片元调用
            // 片元着色器中的输入实际上是把顶点着色器的输出进行插值后得到的结果
            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
