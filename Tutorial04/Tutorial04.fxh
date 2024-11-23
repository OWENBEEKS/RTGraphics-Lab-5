//--------------------------------------------------------------------------------------
// File: Tutorial06.fx
//
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License (MIT).
//--------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------
// Constant Buffer Variables
//--------------------------------------------------------------------------------------
cbuffer ConstantBuffer : register(b0)
{
    matrix World;
    matrix View;
    matrix Projection;
    float4 vLightDir[2];
    float4 vLightColor[2];
    float3 eyePos;
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
    float3 PosW : TEXCOORD01;

};


//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------
PS_INPUT VS(VS_INPUT input)
{
    PS_INPUT output = (PS_INPUT) 0;
    
    //Calculate the position of the vertex against the world, 
    //view, and projection matrices
    output.Pos = mul(input.Pos, World);
    output.Pos = mul(output.Pos, View);
    output.Pos = mul(output.Pos, Projection);
    
    //Calculate the normal vector in world space
    output.Norm = mul(float4(input.Norm, 1), World).xyz; 
    output.PosW = input.Pos.xyz;

    //Supposed to inverse usually, but a translation or scalar wouldn't calculate the normal correctly
    
    return output;
}


//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
//float4 PS(PS_INPUT input) : SV_Target
//{
//    float4 finalColor = 0;
     
//    finalColor.a = 1;
//    float3 N = normalize(input.Norm);
//    float3 L = float3(0, 1, 0);
    
//    float diff = max(0.05, dot(L, N));
    
//    return float4(N, 1);
//}


//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
float4 PS(PS_INPUT input) : SV_Target
{
    float4 materialAmb = float4(0.1, 0.1, 0.1, 1.0);
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
    finalColor += pow(spec, 1) * lightCol;
    finalColor.a = 1.0;
    
    return pow(spec, 1) + (diff) * float4(R, 1.0);
    //return finalColor;
}
