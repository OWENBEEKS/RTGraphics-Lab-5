//--------------------------------------------------------------------------------------
// File: Tutorial06.fx
//
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License (MIT).
//--------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------
// Constant Buffer Variables
//--------------------------------------------------------------------------------------
cbuffer ConstantBuffer : register( b0 )
{
	matrix World;
	matrix View;
	matrix Projection;
	float4 vLightDir[2];
	float4 vLightColor[2];
	float4 vOutputColor;
}


//--------------------------------------------------------------------------------------
struct VS_INPUT
{
    float4 Pos : POSITION;
    float3 Norm : NORMAL;
};

struct PS_INPUT
{
    float4 Pos : SV_POSITION;
    float3 Norm : TEXCOORD0;
};


//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------
PS_INPUT VS( VS_INPUT input )
{
    PS_INPUT output = (PS_INPUT)0;
    output.Pos = mul( input.Pos, World );
    output.Pos = mul( output.Pos, View );
    output.Pos = mul( output.Pos, Projection );
    output.Norm = mul( float4( input.Norm, 1 ), World ).xyz;
    
    return output;
}


//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
float4 PS( PS_INPUT input) : SV_Target
{
    float4 finalColor = 0;
    
    //do NdotL lighting for 2 lights
    for(int i=0; i<2; i++)
    {
        finalColor += saturate( dot( (float3)vLightDir[i],input.Norm) * vLightColor[i] );
    }
    finalColor.a = 1;
    return finalColor;
}
/*float4 materialAmb = float4(0.1, 0.1, 0.1, 1.0);
    float4 materialDiff = float4(0.9, 1.0, 1.0, 1.0);
    float4 lightCol = float4(1.0, 0.0, 1.0, 1.0); //red
    float3 normal = normalize(input.Norm);
    
    float3 lightDir = normalize(vLightDir[1].xyz - input.PosW.xyz);
    
    float3 R = reflect(-lightDir, normal);
    //float3 V = normalize(eyePos - input.Pos.xyz);
    float3 V = normalize(float3(3, 10, 5) - input.PosW.xyz);
    float spec = max(0.1, dot(R, V));
    
    float diff = max(0.0, dot(normal, lightDir));
    
    float4 finalColor = (materialAmb + diff * materialDiff) * lightCol;
    finalColor += pow(spec, 30) * lightCol;
    finalColor.a = 1.0;
    
    return pow(spec, 1) + (diff) * float4(R, 1.0);
    //return finalColor;*/


//--------------------------------------------------------------------------------------
// PSSolid - render a solid color
//--------------------------------------------------------------------------------------
float4 PSSolid( PS_INPUT input) : SV_Target
{
    return vOutputColor;
}
