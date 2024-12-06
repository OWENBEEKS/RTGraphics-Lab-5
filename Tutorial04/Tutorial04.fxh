//--------------------------------------------------------------------------------------
// File: Tutorial06.fx
//
// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License (MIT).
//--------------------------------------------------------------------------------------

//Texture objects
Texture2D txWoodColor : register(t0);
Texture2D txTileColor : register(t1);
SamplerState txWoodsamSampler : register(s0);

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
    float2 Tex : TEXCOORD0;
};

struct PS_INPUT
{
    float4 Pos : SV_POSITION;
    float3 Norm : TEXCOORD0;
    float3 PosW : TEXCOORD01;
    float2 Tex : TEXCOORD02;
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
    //Texture pass to pixels shader
    output.Tex = input.Tex;
    return output;
}


float4 PS(PS_INPUT input) : SV_Target
{
    // Sample the textures
    float4 woodColor = txWoodColor.Sample(txWoodsamSampler, 2.0 * input.Tex);
    float4 tileColor = txTileColor.Sample(txWoodsamSampler, 4.0 * input.Tex);

    // Use the alpha channel of the tileColor to blend it with the woodColor
    float alpha = tileColor.a;
    float4 blendColor = lerp(woodColor, tileColor, alpha);

    return saturate(blendColor);
}