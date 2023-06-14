// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/GlassShader"
{
    Properties
    {
        _MainTex ("Glass Base Texture", 2D) = "white" {}
        _BumpMap ("Noise text", 2D) = "bump" {}
        _Magnitude("Magnitude", Range(0,1)) = 0.5 //扰动值
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent" //透明的物体在不透明的物体之后
            "IgnoreProjector" = "True"
            "RenderType" = "Opaque" // 我们希望不透明物体都在这个物体渲染之前被先渲染完了，这样渲染这个物体的时候抓取的屏幕图像才是正确的屏幕图像
        }
        ZWrite On
        Lighting Off
        Cull Off
        Fog{Mode off}
        Blend One Zero
        LOD 100

        GrabPass{"_GrabTexture"} //在对玻璃第一遍渲染时,把整个场景拍照,绘制到一个名为_GrabTexture的纹理上
        //GrabPass把抓取到的屏幕图像储存在一张与屏幕分辨率相同的RT中

        // 将GrabPass抓取的内容贴图到当前pass
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _GrabTexture; //表示在GrabPass中抓取纹理
            sampler2D _MainTex;
            sampler2D _BumpMap;
            float _Magnitude;

            struct VertInput
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 texcoord : TEXCOORD0; //纹理坐标 在玻璃中，每个玻璃的顶点有两个坐标，一个是自身的纹理坐标，一个是贴图坐标
            };

            struct VertOutput
            {
                float4 vertex : POSITION;
                fixed4 color : COLOR;
                float2 texcoord : TEXCOORD0; //_MainTex的纹理坐标
                float4 uvgrab : TEXCOORD1; // _BumpMap的纹理坐标
            };

            //计算每个顶点相关的属性(位置,纹理坐标等)
            VertOutput vert(VertInput v)
            {
                VertOutput o;
                o.vertex = UnityObjectToClipPos(v.vertex); //顶点变换
                //ComputeGrabScreenPos 传入一个投影空间中的顶点坐标,此方法会以摄像机可视范围的左下角为纹理坐标[0,0]点,右上角为[1,1]点
                //计算出当前顶点位置对应的纹理坐标
                o.uvgrab = ComputeGrabScreenPos(o.vertex);

                o.color = v.color;
                o.texcoord = v.texcoord;

                return o;
                //顶点坐标是-1到1，纹理坐标是0到1
                //在ComputeGrabScreenPos方法中先将顶点坐标全部除以0.5, 再全部加0.5，就转化为了纹理坐标
            }

            //对unity光栅化阶段经过顶点插值得到的片元(像素)的属性进行计算,得到每个片元的颜色值
            half4 frag(VertOutput i) : COLOR
            {
                //tex2Dproj和tex2D的唯一区别是，在对纹理进行采样之前，tex2Dproj将输入的UV xy坐标除以其w坐标。这是将坐标从正交投影转换为透视投影。
                //裁剪空间的坐标经过缩放和偏移后就变成了(0,ｗ),而当分量除以分量W以后,就变成了(0,1),这样在计算需要返回(0,1)值的时候,就可以直接使用tex2Dproj了
                half4 mainColor = tex2D(_MainTex, i.texcoord); //玻璃本身的颜色采样
                half4 bump = tex2D(_BumpMap, i.texcoord);//从凹凸贴图采样玻璃的扰动值
                half2 distortion = UnpackNormal(bump).rg; //将纹理颜色值转换为法线方向值

                i.uvgrab.xy += distortion * _Magnitude; //对uvgrab进行扰动
                fixed4 grabColor = tex2Dproj(_GrabTexture, i.uvgrab); //玻璃后面背景的颜色采样
                return mainColor * grabColor;
            }

            ENDCG
        }
    }
}
