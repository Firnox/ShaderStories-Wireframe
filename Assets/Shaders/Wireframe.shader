Shader "Unlit/Wireframe"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _WireframeFrontColour("Wireframe front colour", color) = (1.0, 1.0, 1.0, 1.0)
        _WireframeBackColour("Wireframe back colour", color) = (1.0, 1.0, 1.0, 1.0)
        _WireframeAliasing("Wireframe aliasing", float) = 1.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent"}
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            // Removes the front facing triangles, this enables us to create the wireframe for those behind.
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            // We add our barycentric variables to the geometry struct.
            struct g2f {
                float4 pos : SV_POSITION;
                float3 barycentric : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            // This applies the barycentric coordinates to each vertex in a triangle.
            [maxvertexcount(3)]
            void geom(triangle v2f IN[3], inout TriangleStream<g2f> triStream) {
                g2f o;
                o.pos = IN[0].vertex;
                o.barycentric = float3(1.0, 0.0, 0.0);
                triStream.Append(o);
                o.pos = IN[1].vertex;
                o.barycentric = float3(0.0, 1.0, 0.0);
                triStream.Append(o);
                o.pos = IN[2].vertex;
                o.barycentric = float3(0.0, 0.0, 1.0);
                triStream.Append(o);
            }

            fixed4 _WireframeBackColour;
            float _WireframeAliasing;

            fixed4 frag(g2f i) : SV_Target
            {
                // Calculate the unit width based on triangle size.
                float3 unitWidth = fwidth(i.barycentric);
                // Alias the line a bit.
                float3 aliased = smoothstep(float3(0.0, 0.0, 0.0), unitWidth * _WireframeAliasing, i.barycentric);
                // Use the coordinate closest to the edge.
                float alpha = 1 - min(aliased.x, min(aliased.y, aliased.z));
                // Set to our backwards facing wireframe colour.
                return fixed4(_WireframeBackColour.r, _WireframeBackColour.g, _WireframeBackColour.b, alpha);
            }
            ENDCG
        }

        Pass
        {
            // Removes the back facing triangles.
            Cull Back
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            // We add our barycentric variables to the geometry struct.
            struct g2f {
                float4 pos : SV_POSITION;
                float3 barycentric : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            // This applies the barycentric coordinates to each vertex in a triangle.
            [maxvertexcount(3)]
            void geom(triangle v2f IN[3], inout TriangleStream<g2f> triStream) {
                g2f o;
                o.pos = IN[0].vertex;
                o.barycentric = float3(1.0, 0.0, 0.0);
                triStream.Append(o);
                o.pos = IN[1].vertex;
                o.barycentric = float3(0.0, 1.0, 0.0);
                triStream.Append(o);
                o.pos = IN[2].vertex;
                o.barycentric = float3(0.0, 0.0, 1.0);
                triStream.Append(o);
            }

            fixed4 _WireframeFrontColour;
            float _WireframeAliasing;

            fixed4 frag(g2f i) : SV_Target
            {
                // Calculate the unit width based on triangle size.
                float3 unitWidth = fwidth(i.barycentric);
                // Alias the line a bit.
                float3 aliased = smoothstep(float3(0.0, 0.0, 0.0), unitWidth * _WireframeAliasing, i.barycentric);
                // Use the coordinate closest to the edge.
                float alpha = 1 - min(aliased.x, min(aliased.y, aliased.z));
                // Set to our forwards facing wireframe colour.
                return fixed4(_WireframeFrontColour.r, _WireframeFrontColour.g, _WireframeFrontColour.b, alpha);
            }
            ENDCG
        }
    }
}
