/*****************************************************************************/
//
// Module	: functions.vh
//
//-----------------------------------------------------------------------------
//
// Description     : Useful generic functions
//
//-----------------------------------------------------------------------------
//
// Copyright (c) 2016 Micron Technology, Inc. All Rights Reserved.
// This source code contains confidential information and trade secrets of
// Micron Technology, Inc.  Use, disclosure, or reproduction is prohibited
// without the prior express written permission of Micron Technology, Inc.
//
/*****************************************************************************/


/**
 * f_clogb2 - Return ceil logb2
 * @bits: value to process
 *
 * This function returns the ceil of logb2 for bits.
 *
 */
function integer f_clogb2;
input [31:0] bits;
// leda SYN9_25 FM_106 B_3007_A off
begin
    f_clogb2 = 32'd0;
//leda W182 W292 W459 B_3201 B_3212 B_3420 B_3201 B_3212 B_3007_A VER_2_10_6_3 VER_2_10_3_1 off
    while ('d2**f_clogb2 < bits)
	f_clogb2 = f_clogb2 + 32'd1;
//leda W182 W292 W459 B_3201 B_3212 B_3420 B_3201 B_3212 B_3007_A VER_2_10_6_3 VER_2_10_3_1 on
end
// leda SYN9_25 FM_106 B_3007_A on
endfunction

/**
 * f_enc_bits - Return number of bits to binary encode value
 * @bits: value to process
 *
 * This function is very useful for calculating the number of address
 * bits required for a specified depth when parameterizing a RAM.
 *
 */
function integer f_enc_bits;
input [31:0] bits;
begin
//leda B_3212 B_3007_A W459 VER_2_10_3_6 VER_2_10_6_3 off
    f_enc_bits = bits <= 32'd2 ? 'd1 : f_clogb2(bits);
//leda B_3212 B_3007_A W459 VER_2_10_3_6 VER_2_10_6_3 on
end
endfunction


/**
 * f_enconehot - Return encoded bit position for one-hot vector
 * @bits[63:0]: onehot value to process
 *
 * bits[63] set returns 6'd63; bits[0] set returns 0 as does an empty vector.
 */
function [5:0] f_enconehot;
// leda FM_106 VER_2_10_4_3 off
input [63:0] bits;
integer i;
begin
    f_enconehot = 6'b0;
//leda G_5214_2 FM_2_22 VER_2_1_6_4 W216 off
    for (i=0; i<64; i=i+1) if (bits[i]) f_enconehot = f_enconehot | i[5:0];
//leda G_5214_2 FM_2_22 VER_2_1_6_4 W216 on
end
// leda FM_106 VER_2_10_4_3 on
endfunction


/**
 * f_ntz - Return number of trailing zeros
 * @bits[63:0]: value to process
 *
 */
function [6:0] f_ntz;
input [63:0] bits;
reg [7:0] reduce;
begin
    reduce = {|bits[63:56],|bits[55:48],|bits[47:40],|bits[39:32],
	      |bits[31:24],|bits[23:16],|bits[15: 8],|bits[ 7: 0]};
    casex (reduce)
//leda W443 W484 B_3200 VER_2_10_6_1 off
	8'bxxxxxxx1: f_ntz = 7'd0  + f_ntz8(bits[ 7: 0]);
	8'bxxxxxx10: f_ntz = 7'd8  + f_ntz8(bits[15: 8]);
	8'bxxxxx100: f_ntz = 7'd16 + f_ntz8(bits[23:16]);
	8'bxxxx1000: f_ntz = 7'd24 + f_ntz8(bits[31:24]);
	8'bxxx10000: f_ntz = 7'd32 + f_ntz8(bits[39:32]);
	8'bxx100000: f_ntz = 7'd40 + f_ntz8(bits[47:40]);
	8'bx1000000: f_ntz = 7'd48 + f_ntz8(bits[55:48]);
	8'b10000000: f_ntz = 7'd56 + f_ntz8(bits[63:56]);
//leda W443 W484 B_3200 VER_2_10_6_1 on
	default: f_ntz = 7'd64;
    endcase
end
endfunction

function [3:0] f_ntz8;
input [7:0] bits;
begin
//leda W443 off
    casex (bits)
	8'bxxxxxxx1: f_ntz8 = 4'd0;
	8'bxxxxxx10: f_ntz8 = 4'd1;
	8'bxxxxx100: f_ntz8 = 4'd2;
	8'bxxxx1000: f_ntz8 = 4'd3;
	8'bxxx10000: f_ntz8 = 4'd4;
	8'bxx100000: f_ntz8 = 4'd5;
	8'bx1000000: f_ntz8 = 4'd6;
	8'b10000000: f_ntz8 = 4'd7;
	default:     f_ntz8 = 4'd8;
    endcase
//leda W443 on
end
endfunction


/**
 * f_nlz - Return number of leading zeros
 * @bits[63:0]: value to process
 *
 */
function [6:0] f_nlz;
input [63:0] bits;
reg [63:0] rbits;
integer i;
begin
//leda G_5214_2 FM_2_22 VER_2_1_6_4 off
    for (i=0; i<64; i=i+1) rbits[63-i] = bits[i];
//leda G_5214_2 FM_2_22 VER_2_1_6_4 on
    f_nlz = f_ntz(rbits);
end
endfunction


/**
 * f_pop128 - Return number of ones
 * @bits[127:0]: value to process
 *
 */
function [7:0] f_pop128;
input [127:0] bits;
begin
//leda VER_2_10_3_2 B_3208 off - Operand size mismatch in signal assignment
    f_pop128 = f_pop64(bits[64 +: 64]) + f_pop64(bits[0 +: 64]);
//leda VER_2_10_3_2 B_3208 on - Operand size mismatch in signal assignment
end
endfunction

/**
 * f_pop64 - Return number of ones
 * @bits[63:0]: value to process
 *
 */
function [6:0] f_pop64;
input [63:0] bits;
begin
//leda VER_2_10_3_2 B_3208 off - Operand size mismatch in signal assignment
    f_pop64 = f_pop32(bits[32 +: 32]) + f_pop32(bits[0 +: 32]);
//leda VER_2_10_3_2 B_3208 on - Operand size mismatch in signal assignment
end
endfunction

function [5:0] f_pop32;
input [31:0] bits;
begin
//leda VER_2_10_3_2 B_3208 off - Operand size mismatch in signal assignment
    f_pop32 = f_pop16(bits[16 +: 16]) + f_pop16(bits[0 +: 16]);
//leda VER_2_10_3_2 B_3208 on - Operand size mismatch in signal assignment
end
endfunction

function [4:0] f_pop16;
input [15:0] bits;
begin
//leda VER_2_10_3_2 B_3208 off - Operand size mismatch in signal assignment
    f_pop16 = f_pop8(bits[8 +: 8]) + f_pop8(bits[0 +: 8]);
//leda VER_2_10_3_2 B_3208 on - Operand size mismatch in signal assignment
end
endfunction

function [3:0] f_pop8;
input [7:0] bits;
begin
//leda VER_2_10_3_2 B_3208 VER_2_10_3_4 VER_2_10_6_1 VER_2_10_6_7  B_3208 off
    f_pop8 = bits[7] + bits[6] + bits[5] + bits[4] +
	     bits[3] + bits[2] + bits[1] + bits[0];
//leda VER_2_10_3_2 B_3208 VER_2_10_3_4 VER_2_10_6_1  VER_2_10_6_7 B_3208 on
end
endfunction


/**
 * f_lru4 - Return current LRU and next 4 way state;
 * @state[4:0]: current LRU state
 * @used[3:0]:	one hot way which was used
 *
 */
function [2+4:0] f_lru4;
// leda DFT_022 FM_2_4 S_2_8 VER_2_8_1_4 off
input [4:0] state;
input [3:0] used;
localparam [4:0] S0123 = 'd0,  S0132 = 'd1,  S0213 = 'd2,  S0231 = 'd3,
		 S0312 = 'd4,  S0321 = 'd5,  S1023 = 'd6,  S1032 = 'd7,
		 S1203 = 'd8,  S1230 = 'd9,  S1302 = 'd10, S1320 = 'd11,
		 S2013 = 'd12, S2031 = 'd13, S2103 = 'd14, S2130 = 'd15,
		 S2301 = 'd16, S2310 = 'd17, S3012 = 'd18, S3021 = 'd19,
		 S3102 = 'd20, S3120 = 'd21, S3201 = 'd22, S3210 = 'd23;
    begin

    // default
//leda W342 W443 VER_2_10_1_5 VER_2_10_1_6 off
    f_lru4 = {2'bx, state};
//leda W342 W443 VER_2_10_1_5 VER_2_10_1_6 on

    // next state
//leda VER_2_8_5_3 W71 W226 XV2_1402 XV2P_1402 XV4_1402 XVSP2_1402 W225 off
    case (state)
	S0123: case (1'b1)
		used[1]: f_lru4[4:0] = S1023;
		used[2]: f_lru4[4:0] = S2013;
		used[3]: f_lru4[4:0] = S3012;
	       endcase
	S0132: case (1'b1)
		used[1]: f_lru4[4:0] = S1032;
		used[2]: f_lru4[4:0] = S2013;
		used[3]: f_lru4[4:0] = S3012;
	       endcase
	S0213: case (1'b1)
		used[1]: f_lru4[4:0] = S1023;
		used[2]: f_lru4[4:0] = S2013;
		used[3]: f_lru4[4:0] = S3021;
	       endcase
	S0231: case (1'b1)
		used[1]: f_lru4[4:0] = S1023;
		used[2]: f_lru4[4:0] = S2031;
		used[3]: f_lru4[4:0] = S3021;
	       endcase
	S0312: case (1'b1)
		used[1]: f_lru4[4:0] = S1032;
		used[2]: f_lru4[4:0] = S2031;
		used[3]: f_lru4[4:0] = S3012;
	       endcase
	S0321: case (1'b1)
		used[1]: f_lru4[4:0] = S1032;
		used[2]: f_lru4[4:0] = S2031;
		used[3]: f_lru4[4:0] = S3021;
	       endcase

	S1023: case (1'b1)
		used[0]: f_lru4[4:0] = S0123;
		used[2]: f_lru4[4:0] = S2103;
		used[3]: f_lru4[4:0] = S3102;
	       endcase
	S1032: case (1'b1)
		used[0]: f_lru4[4:0] = S0132;
		used[2]: f_lru4[4:0] = S2103;
		used[3]: f_lru4[4:0] = S3102;
	       endcase
	S1203: case (1'b1)
		used[0]: f_lru4[4:0] = S0123;
		used[2]: f_lru4[4:0] = S2103;
		used[3]: f_lru4[4:0] = S3120;
	       endcase
	S1230: case (1'b1)
		used[0]: f_lru4[4:0] = S0123;
		used[2]: f_lru4[4:0] = S2130;
		used[3]: f_lru4[4:0] = S3120;
	       endcase
	S1302: case (1'b1)
		used[0]: f_lru4[4:0] = S0132;
		used[2]: f_lru4[4:0] = S2130;
		used[3]: f_lru4[4:0] = S3102;
	       endcase
	S1320: case (1'b1)
		used[0]: f_lru4[4:0] = S0132;
		used[2]: f_lru4[4:0] = S2130;
		used[3]: f_lru4[4:0] = S3120;
	       endcase

	S2013: case (1'b1)
		used[0]: f_lru4[4:0] = S0213;
		used[1]: f_lru4[4:0] = S1203;
		used[3]: f_lru4[4:0] = S3201;
	       endcase
	S2031: case (1'b1)
		used[0]: f_lru4[4:0] = S0231;
		used[1]: f_lru4[4:0] = S1203;
		used[3]: f_lru4[4:0] = S3201;
	       endcase
	S2103: case (1'b1)
		used[0]: f_lru4[4:0] = S0213;
		used[1]: f_lru4[4:0] = S1203;
		used[3]: f_lru4[4:0] = S3210;
	       endcase
	S2130: case (1'b1)
		used[0]: f_lru4[4:0] = S0213;
		used[1]: f_lru4[4:0] = S1230;
		used[3]: f_lru4[4:0] = S3210;
	       endcase
	S2301: case (1'b1)
		used[0]: f_lru4[4:0] = S0231;
		used[1]: f_lru4[4:0] = S1230;
		used[3]: f_lru4[4:0] = S3201;
	       endcase
	S2310: case (1'b1)
		used[0]: f_lru4[4:0] = S0231;
		used[1]: f_lru4[4:0] = S1230;
		used[3]: f_lru4[4:0] = S3210;
	       endcase

	S3012: case (1'b1)
		used[0]: f_lru4[4:0] = S0312;
		used[1]: f_lru4[4:0] = S1302;
		used[2]: f_lru4[4:0] = S2301;
	       endcase
	S3021: case (1'b1)
		used[0]: f_lru4[4:0] = S0321;
		used[1]: f_lru4[4:0] = S1302;
		used[2]: f_lru4[4:0] = S2301;
	       endcase
	S3102: case (1'b1)
		used[0]: f_lru4[4:0] = S0312;
		used[1]: f_lru4[4:0] = S1302;
		used[2]: f_lru4[4:0] = S2310;
	       endcase
	S3120: case (1'b1)
		used[0]: f_lru4[4:0] = S0312;
		used[1]: f_lru4[4:0] = S1320;
		used[2]: f_lru4[4:0] = S2310;
	       endcase
	S3201: case (1'b1)
		used[0]: f_lru4[4:0] = S0321;
		used[1]: f_lru4[4:0] = S1320;
		used[2]: f_lru4[4:0] = S2301;
	       endcase
	S3210: case (1'b1)
		used[0]: f_lru4[4:0] = S0321;
		used[1]: f_lru4[4:0] = S1320;
		used[2]: f_lru4[4:0] = S2310;
	       endcase
//leda VER_2_8_5_3 W71 W226 XV2_1402 XV2P_1402 XV4_1402 XVSP2_1402 W225 on

	default: f_lru4[4:0] = S0123; // initialize
    endcase

    // current LRU
    case (state)
	S0123, S0213, S1023, S1203, S2013, S2103: f_lru4[6:5] = 2'd3;
	S0132, S0312, S1032, S1302, S3012, S3102: f_lru4[6:5] = 2'd2;
	S0231, S0321, S2031, S2301, S3021, S3201: f_lru4[6:5] = 2'd1;
	S1230, S1320, S2130, S2310, S3120, S3210: f_lru4[6:5] = 2'd0;
	default: f_lru4[6:5] = 2'd0;
    endcase
end
// leda DFT_022 FM_2_4 S_2_8 VER_2_8_1_4 on
endfunction


/**
 * f_to_gray2 - Convert to Gray code
 * @bits[1:0]: binary value
 *
 */
function [1:0] f_to_gray2;
input [1:0] bits;
begin
    case (bits)
	2'b00: f_to_gray2 = 2'b00;
	2'b01: f_to_gray2 = 2'b01;
	2'b10: f_to_gray2 = 2'b11;
	2'b11: f_to_gray2 = 2'b10;
//leda W342 W443 off
	default: f_to_gray2 = 2'bx;
//leda W342 W443 on
    endcase
end
endfunction

/**
 * f_from_gray2 - Convert from Gray code
 * @bits[1:0]: gray value
 *
 */
function [1:0] f_from_gray2;
input [1:0] bits;
begin
    case (bits)
	2'b00: f_from_gray2 = 2'b00;
	2'b01: f_from_gray2 = 2'b01;
	2'b11: f_from_gray2 = 2'b10;
	2'b10: f_from_gray2 = 2'b11;
//leda W342 W443 off
	default: f_from_gray2 = 2'bx;
//leda W342 W443 on
    endcase
end
endfunction


/**
 * dec_3to8 - encoded 3 bit to decoded 8-bit, 1-hot value
 *
 */
function [7:0] dec_3to8;
input [2:0] ptr_enc;
begin
   casex(ptr_enc)
   3'h0:  dec_3to8 = 8'h01;
   3'h1:  dec_3to8 = 8'h02;
   3'h2:  dec_3to8 = 8'h04;
   3'h3:  dec_3to8 = 8'h08;
   3'h4:  dec_3to8 = 8'h10;
   3'h5:  dec_3to8 = 8'h20;
   3'h6:  dec_3to8 = 8'h40;
   3'h7:  dec_3to8 = 8'h80;
   default: dec_3to8 = 8'h00;
   endcase
end
endfunction


/**
 * enc_8to3 - 8-bit one-hot to 3-bit encoded value
 *
 */
function [2:0] enc_8to3;
input [7:0] ptr_dec;
begin
   casex(ptr_dec)
   8'h01:  enc_8to3 = 3'h0;
   8'h02:  enc_8to3 = 3'h1;
   8'h04:  enc_8to3 = 3'h2;
   8'h08:  enc_8to3 = 3'h3;
   8'h10:  enc_8to3 = 3'h4;
   8'h20:  enc_8to3 = 3'h5;
   8'h40:  enc_8to3 = 3'h6;
   8'h80:  enc_8to3 = 3'h7;
   default:  enc_8to3 = 3'h0;
   endcase
end
endfunction

/*
 *	endian swap lsbytes with msbytes within 256 bit word
 */
function [255:0] swizzle256;
input [255:0] data;
begin
    swizzle256 = {
        swizzle128(data[128+: 128]),
        swizzle128(data[0  +: 128])
    };
end
endfunction

/*
 *	endian swap lsbytes with msbytes within 128 bit word
 */
function [127:0] swizzle128;
input [127:0] data;
begin
    swizzle128 = {
        swizzle64(data[64 +: 64]),
        swizzle64(data[0  +: 64])
    };
end
endfunction

/*
 *	endian swap lsbytes with msbytes within 96 bit word
 */
function [95:0] swizzle96;
input [95:0] data;
begin
    swizzle96 = {
        swizzle32(data[64 +: 32]),
        swizzle64(data[0  +: 64])
    };
end
endfunction

/*
 *	endian swap lsbytes with msbytes within 64 bit word
 */
function [63:0] swizzle64;
input [63:0] data;
begin
    swizzle64 = {
        swizzle32(data[32 +: 32]),
        swizzle32(data[0  +: 32])
    };
end
endfunction

/*
 *	endian swap lsbytes with msbytes within 32 bit word
 */
function [31:0] swizzle32;
input [31:0] data;
begin
    swizzle32 = {
        data[0  +: 8],
        data[8  +: 8],
        data[16 +: 8],
        data[24 +: 8]
    };
end
endfunction

