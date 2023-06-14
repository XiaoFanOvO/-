// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/WaterShader"
{
    Properties
    {
        _MainTex ("Glass Base Texture", 2D) = "white" {}
        _BumpMap ("Noise text", 2D) = "bump" {}
        _CausticTex("Caustic Texture", 2D) = "white" {}
        _Magnitude("Magnitude", Range(0,1)) = 0.5 //扰动值
        _WaterColor("Water Color", Color) = (1,1,1,1)
        _WaterMagnitude("Water Magnitude", float) = 1
        _WaterPeriod("Water Period", float) = 1
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
            sampler2D _CausticTex;
            float4 _WaterColor;
            float _Magnitude;

            float _WaterMagnitude;
            float _WaterPeriod;

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


            float2 sinusoid(float2 x, float2 m, float2 M, float2 periodo)
            {
                float2 esursione = M - m;
                float2 coefficiente = 3.1415 * 2.0 / periodo;
                return esursione / 2.0 * (1.0 + sin(x * coefficiente)) + m;
            }


            //对unity光栅化阶段经过顶点插值得到的片元(像素)的属性进行计算,得到每个片元的颜色值
            half4 frag(VertOutput i) : COLOR
            {
                fixed4 noise = tex2D(_BumpMap, i.texcoord);
                fixed4 mainColor = tex2D(_MainTex, i.texcoord);

                float time = _Time[1]; // Time.time

                float waterDisplacement = sinusoid(
                    float2(time, time) + noise.xy,  //时间+噪点
                    float2(-_WaterMagnitude, -_WaterMagnitude),
                    float2(_WaterMagnitude, _WaterMagnitude),
                    float2(_WaterPeriod,_WaterPeriod)
                ); //当前值，最小值，最大值，周期
                i.uvgrab.xy += waterDisplacement;
                float4 grabColor = tex2Dproj(_GrabTexture, i.uvgrab);
                fixed4 causticColor = tex2D(_CausticTex, i.texcoord.xy * 0.25 + waterDisplacement * 5);

                return grabColor * mainColor * causticColor * _WaterColor;
            }

            ENDCG
        }
    }
}
