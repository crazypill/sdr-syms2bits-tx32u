//
//  main.m
//  bits2bytes-r
//
//  Created by Alex Lelievre on 6/28/20.
//  Copyright © 2020 Alex Lelievre. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Data examples captured from SDR
        // bit rate: 17.1984 kbps - 910.167 MHz captures
        // 43 bit message - 4 bytes (ID, rain + status bits << 16, rain << 8, rain) + CRC byte
//         "0.699197, -0.87498, 0.755496, -0.865372, 0.636301, -0.859178, 0.678502, -0.839219, -1.01259, -0.79524, 0.575348, -0.855173, 0.652791, 0.964255, -1.18264, 0.820793, 0.709986, 0.789815, -1.10936, 0.721641, -1.30361, 0.660394, -0.953353, -0.816151, -0.653012, 0.747213, -1.19411, 0.634666, -0.757265, -0.96905, 0.637562, 0.640429, -0.691161, -0.875026, 0.569393, -0.81273, -1.02232, -0.796588, -1.04128, -0.689551, -0.922238, -0.793439, -0.596406, -0.630172, -0.918827, -1.17285, -0.785352, -1.015, -1.01286, -1.12246, -1.14392, -0.795208, -0.777878, -0.744852, -0.722001, -0.724791, -0.680115, -0.588333, 0.766648, 0.846001, 0.823664, 0.726593, -1.46922, 0.638094, -0.816913, -0.69554"


#pragma mark -





#define USE_BIG_ENDIAN
#define PRINT_BINARY
#define PRINT_FULL_HEX


#define c2f( a ) (((a) * 1.8000) + 32)
#define ms2mph( a ) ((a) * 2.23694)
#define km2mph( a ) ((a) / 0.621371)
#define millimeter2inch  0.0393700787402


static bool s_latch = false;


enum
{
    kType_temp,
    kType_humidity,
    kType_rain,
    kType_wind,
    kType_gust
};




#pragma mark -


uint8_t UpdateCRC(uint8_t res, uint8_t val) {
    for (int i = 0; i < 8; i++) {
      uint8_t tmp = (uint8_t)((res ^ val) & 0x80);
      res <<= 1;
      if (0 != tmp) {
        res ^= 0x31;
      }
      val <<= 1;
    }
  return res;
}


uint8_t CalculateCRC(uint8_t *data, uint8_t len) {
  uint8_t res = 0;
  for (int j = 0; j < len; j++) {
    uint8_t val = data[j];
    res = UpdateCRC(res, val);
  }
  return res;
}


uint8_t reverseBits( uint8_t num )
{
    unsigned int count = sizeof(num) * 8 - 1;
    unsigned int reverse_num = num;
      
    num >>= 1;
    while(num)
    {
       reverse_num <<= 1;
       reverse_num |= num & 1;
       num >>= 1;
       count--;
    }
    reverse_num <<= count;
    return reverse_num;
}



#pragma mark -


int main(int argc, const char * argv[]) {
    @autoreleasepool {

        printf( "-- tx32u ----------------------------------------------------------------------\n" );

        if( argc < 2 )
        {
            printf( "Wrong number of parameters.  Takes a single string with symbols in it.\n\n" );
            return -1;
        }

        NSMutableString* string = [[NSMutableString alloc] init];
        NSString* raw = [NSString stringWithUTF8String:argv[1]];
        
        NSArray* array = [raw componentsSeparatedByString:@","];
        [array enumerateObjectsUsingBlock:^( NSString* obj, NSUInteger idx, BOOL *stop ) {
            bool bit = (obj.floatValue > 0);
            [string appendString:bit ? @"1" : @"0"];  // might be easier to just directly go to binary from here...
        }];

        
        NSString* stripped = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
        uint8_t nibble = 0;
        uint8_t byte = 0;

        uint8_t remainingBits = stripped.length % 8;
        if( remainingBits != 0 )
            printf( "Warning, do not have multiple of 8 bits! %d, remaining: %d\n\n", (int)stripped.length, remainingBits );
        
        unsigned char* buffer = malloc( stripped.length );
        const unsigned char* bits = (const unsigned char*)stripped.UTF8String;
        uint32_t nibbleCounter = 0;
        for( int i = 0; i < stripped.length; i++ )
        {
            int bitCounter = (i % 4);
            
            uint8_t bit = (bits[i] == '1');

#ifdef USE_BIG_ENDIAN
            // big-endian (if you are on intel)
            nibble |= bit << (3 - bitCounter);
#else
            // little-endian
            nibble |= bit << bitCounter;
#endif
            if( bitCounter == 3 )
            {
                buffer[nibbleCounter++] = nibble;
                nibble = 0;
            }
        }
        
        unsigned char* byte_buffer = malloc( stripped.length );
        uint32_t byteCounter = 0;
        for( int i = 0; i < stripped.length; i++ )
        {
            int bitCounter = (i % 8);
            
            uint8_t bit = (bits[i] == '1');

#ifdef USE_BIG_ENDIAN
            // big-endian (if you are on intel)
            byte |= bit << (7 - bitCounter);
            #else
            // little-endian
            byte |= bit << bitCounter;
#endif
            if( bitCounter == 7 )
            {
                byte_buffer[byteCounter++] = byte;
                byte = 0;
            }
        }

#ifdef PRINT_BINARY
        // print input string
        printf( "Input:  " );
        for( int i = 0; i < stripped.length; i++ )
        {
            int bitCounter = (i % 8);
            printf( "%c", stripped.UTF8String[i] );
            if( bitCounter == 7 )
                printf( " " );
        }
        printf( "\nBinary: " );
        
        // print converted input string
        for( int i = 0; i < nibbleCounter; i++ )
        {
            for( int x = 0; x < 4; x++ )
            {
                bool bit = (buffer[i] & (1 << x)) >> x;
                printf( "%d", bit );
            }
            if( i % 2 != 0 )        // remove this line to get output in nibbles
                printf( " " );
        }
#endif
        
//        printf( "\nDecimal: " );
//        for( int i = 0; i < byteCounter; i++ )
//            printf( "%3u ", byte_buffer[i] );

#ifdef PRINT_FULL_HEX
        printf( "\nHex:     " );
        for( int i = 0; i < nibbleCounter; i++ )
        {
            printf( "%3X ", buffer[i] );
            
            if( i % 2 != 0 )        // we do this to line up the hex with the nibbles above...
                printf( " " );
        }
#endif

        // hide preamble and stuff - hibbles = hex nibbles
        printf( "\nHibbles:  " );
        for( int i = 0; i < nibbleCounter; i++ )
        {
            const unsigned char preamble[] = { 0xA, 0xA, 0x2, 0xD, 0xD, 0x4 };
            if( i < 6 && preamble[i] != buffer[i] )
            {
                if( !s_latch )
                {
                    printf( "preamble and sync word don't match[%d]: %2x !=", i, preamble[i] );
                    s_latch = true;
                }
                printf( "%2x ", buffer[i] );
            }
            else if( i >= 6 )
            {
                if( s_latch )
                {
                    printf( "\n" );
                    s_latch = false;
                }
                printf( "%2X ", buffer[i] );
            }
                
        }
        s_latch = false;
        
        uint8_t crc = CalculateCRC( &byte_buffer[3], byteCounter - 4 );
        uint8_t message_crc = byte_buffer[byteCounter - 1];
        printf( " CRC: %s (0x%X)\nBytes in payload: %d + 1 CRC byte, total bits: %d (%d with preamble)\n", message_crc == crc ? "GOOD" : "WRONG", crc, byteCounter - 4, (int)stripped.length - 24, (int)stripped.length );

        printf( "\nPayload: " );
        for( int i = 3; i < byteCounter; i++ )
            printf( "%02X", byte_buffer[i] );

        printf( "  ->  " );
        for( int i = 3; i < byteCounter; i++ )
        {
            printf( "0x%02X", byte_buffer[i] );
            
            if( i != byteCounter - 1 )
                printf( ", " );
        }

        // do a little parsing... not sure what the first byte is-  but I gather it's a station ID,
        // the middle three bytes are the rain counter. last byte is the CRC.
        uint32_t rain_counter = (byte_buffer[4] << 16) | (byte_buffer[5] << 8) | byte_buffer[6];
        printf( "\n\nRain[0x%x]: %0.2f mm (%0.2f inches)\n", byte_buffer[3], rain_counter * 0.5, (rain_counter * 0.5) * millimeter2inch );
    
        printf( "\n" );
        free( buffer );
        free( byte_buffer );
    }
    return 0;
}
