Shader "Hidden/BWDiffuse"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _bwBlend("Black & White blend", Range(0,1)) = 0
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            //vert和vert_img是着色器中的函数。vert函数是顶点着色器函数，它处理输入的顶点数据并输出变换后的顶点位置。
            //vert_img函数是图像效果着色器函数，它处理输入的顶点数据并输出变换后的顶点位置和纹理坐标.
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            //uniform是一种全局着色器变量,值存储在程序对象中,可以从着色器程序的任何阶段访问
            //uniform可以直接将数据从应用程序传递到任何着色器阶段,主要是向shader中传递一些与顶点无关的数据
            uniform sampler2D _MainTex;
            uniform float _bwBlend;

            //v2f和v2f_img都是着色器中的结构体。v2f是顶点着色器函数的输出结构体，它包含了变换后的顶点位置和纹理坐标等信息。
            //v2f_img是图像效果着色器函数的输出结构体，它包含了变换后的顶点位置、纹理坐标和颜色等信息
            fixed4 frag (v2f_img i) : SV_Target
            {
                fixed4 c = tex2D(_MainTex, i.uv);
                
                float lum = c.r * 0.3 + c.g * 0.59 + c.b * 0.11; //得到颜色的亮度值

                float4 bw = float4(lum, lum, lum , 1); //从颜色的亮度值构造一个该亮度值的灰色

                float4 result = lerp(c, bw, _bwBlend);

                return result;
            }
            ENDCG
        }
    }
}
