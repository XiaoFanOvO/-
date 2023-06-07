Shader "My Surface Shader"
{
    Properties  //属性 类型不区分大小写
    {
        //次数设置的属性将被显示在Shader所在的Material的属性面板上
        //属性的语法格式:属性的变量名(属性的显示名称,属性的类型) = 属性的初始值
        //属性的变量名:在Shader中使用的名称
        //属性的显示名称:在Material的面板上显示的名称
        _MainTex("我的纹理",2D) = "white"{}
        //_MyTexture2("我的纹理2",2D) = "bump"{} //凹凸贴图
        _MyInt("我的整数", int) = 2
        _MyRange("在范围内调节", Range(-1,1)) = 0
        _MyColor("调节颜色", Color) = (0,0,1,0.5) //new Color(R,G,B,A) 0-1
        _MyVector("设置向量", Vector) = (1,1,1,1) //new Vector(x,y,z,w)
    }
    
    SubShader   //shader程序区分大小写
    {
        //此处编写Shader代码
//        CGPROGRAM
//        #pragma surface surf Lambert
//        struct Input
//        {
//            float2 uv_MainTex; //纹理坐标
//        };
//
//        
//        //参数名要和上面定义的完全一致,单位不一定
//        sampler2D _MainTex; //对_MyTexture进行2D纹理采样(按照纹理坐标抓取纹理贴图的像素颜色值的过程)
//        int _MyInt;
//        half4 _MyColor; //half4比float4更小,更节省GPU资源
//        half _MyRange; //半精度浮点数
//        float2 _MyVector; // (x,y,z,w) .xy => (x,y)
//        void surf (Input IN, inout SurfaceOutput o) // 此函数被Unity调用,并传入相应参数
//        {
//            //o.Albedo = float4(1,0,0,1);
//            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * _MyColor.rgb; //传入一个纹理图,以及一个uv坐标,此函数自动对纹理图进行采样
//        }
//        
//        ENDCG
        Tags
        {
            "Queue" = "Geometry"
            "RenderType" = "Opaque"
        }
        
        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex);
        }
        
        ENDCG
    }
}