//
//  main.m
//  bits2bytes
//
//  Created by Alex Lelievre on 6/28/20.
//  Copyright © 2020 Alex Lelievre. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum
{
    temperature,
    humidity,
    rain,
    wind,
    gust
} quartet_type;


typedef struct
{
    uint8_t  type  : 4;        // 4 - one nibble
    uint16_t data  : 12;       // 16 - three nibbles
}  __attribute__((packed)) quartet;


typedef struct
{
    uint8_t  preable[5];
    uint8_t  error  : 2;
    uint8_t  aquiring : 2;
    uint8_t  station_id  : 4;
    uint8_t  num_quartets : 4;
    uint8_t  start_quartets;
}  __attribute__((packed)) weatherData;



int main(int argc, const char * argv[]) {
    @autoreleasepool {
    
        // looking for patterns (or anti-patterns) in captured data...
//      NSString* string = @"0    0    0    0    0    0    0    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    1    1    0    0    0    0    1    1    1    1    1    1    1    0    0    0    1    0    1    1    1    1    0    0    0    0    0    0    0    0    0    0    1    1    1    1    1    0    0    0    0    0    0    0    0    0";
//      NSString* string = @"0    0    0    0    0    0    0    0    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    1    1    0    0    0    0    1    1    1    1    1    1    1    0    0    0    1    0    1    1    1    1    0    0    0    0    0    0    0    0";
//      NSString* string = @"0    0    0    0    0    0    0    0    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    1    1    0    0    0    0    1    1    1    1    1    1    1    0    0    0    1    0    1    1    1    1    0    0    0    0    0    0    0    0";
//      NSString* string = @"0    0    0    0    0    0    0    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    1    1    0    0    0    0    1    1    1    1    1    1    1    0    0    0    1    0    1    1    1    1    0    0    0    0    0    0    0    0    0";
//      NSString* string = @"0    0    0    0    0    0    0    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    1    1    0    0    0    0    1    1    1    1    1    1    1    0    0    0    1    0    1    1    1    1    0    0    0    0    0    0    0    0    0";
//      NSString* string = @"0    0    0    0    0    0    0    0    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    1    0    0    0    0    0    1    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0    0    0    1    1    0    1    1    1    0    0    0    0    0    0    0    0    0    0";
//      NSString* string = @"0    0    0    0    0    0    0    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    1    0    0    0    0    0    1    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0    0    0    1    1    0    1    1    1    0    0    0    0    0    0    0    0    0    0    0";
//      NSString* string = @"0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    1    0    0    0    0    0    1    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0    0    0    1    1    0    1    1    1    0    0    0    0    0    0    0    0    0    0";
//      NSString* string = @"0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    1    0    0    0    0    0    1    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0    0    0    1    1    0    1    1    1    0    0    0    0    0    0    0    0    0    0";
//      NSString* string = @"0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    1    0    0    0    0    1    0    0    0    0    0    0    1    1    0    0    0    0    0    0    1    0    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0    0    1    1    1    1    0    0    0    0    0    0    0    0    0    0    0    0    0";
//      NSString* string = @"0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    1    0    0    0    0    0    1    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0    0    0    1    1    0    1    1    1    0    0    0    0    0    0    0    0    0    0";
//      NSString* string = @"0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    1    0    0    0    0    1    0    0    0    0    1    0    0    0    0    0    1    1    1    0    0    1    0    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0    0    0    1    0    0    1    0    1    1    0    0    0    0    0    0    0    0";
//      NSString* string = @"0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    1    1    0    0    1    1    1    1    1    1    1    1    1    0    0    0    0    0    0    0    1";
//      NSString* string = @"0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    1    1    0    0    1    1    1    1    1    1    1    1    1    0    0    0    0    0    0    0    1";
//      NSString* string = @"0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    1    0    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    1    1    0    0    1    1    1    1    1    1    1    1    1    0    0    0    0    0    0    0";
//      NSString* string = @"0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    1    0    0    0    0    0    1    1    0    0    0    0    0    0    0    1    1    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    1    1    0    0    1    1    1    1    1    1    1    1    1    0    0    0    1    0    0    1    1    1    0";
//        NSString* string = @"0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    1    0    0    0    0    0    1    1    0    0    0    0    0    0    0    1    1    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0";
//        NSString* string = @"0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    1    1    0    0    1    1    1    1    1    1    1    1    1";
//        NSString* string = @"0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    1    1    0    0    1    1    1    1    1    1    1    1    1";
//        NSString* string = @"0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    1    1    0    0    1    1    1    1    1    1    1    1    1";
//        NSString* string = @"0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    1    1    1    0    0    0    0    1    1    0    0    0    0    0    1    1    0    0    1    1    0    0    1    1    1    0    0    0    1    0    0    0    0    0    1    0    1    0    1    1    1    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0    0    1    0    1    0    1    1    0    1";
//        NSString* string = @"0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    1    0    0    0    0    0    1    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0    0    0    1    1    0    1    1    1    0    0    0    0    0    0    0    0";
//        NSString* string = @"0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    1    0    0    0    0    0    1    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0    0    0    1    1    0    1    1    1    0    0    0    0    0    0    0    0";
//        NSString* string = @"0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    1    0    0    0    0    1    0    0    0    0    0    0    1    1    0    0    1    1    1    0    1    1    1    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    1    0    1    0    1    0    0    0    0    0    0    0";
        NSString* string = @"0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    1    0    0    0    1    0    1    1    0    1    1    1    0    1    0    1    0    0    1    0    1    0    1    0    0    1    0    1    0    0    0    0    1    0    0    0    0    0    0    1    1    0    0    1    1    1    0    1    1    0    0    0    1    0    0    0    0    0    0    0    0    0    0    0    0    0    0    1    0    1    0    0    1    1    0";
        NSString* stripped = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
        uint8_t byte = 0;
        
        uint8_t remainingBits = stripped.length % 8;
        if( remainingBits != 0 )
            printf( "Warning, do not have multiple of 8 bits! %d, remaining: %d\n\n", (int)stripped.length, remainingBits );
        
        unsigned char* buffer = malloc( stripped.length );
        const unsigned char* bits = (const unsigned char*)stripped.UTF8String;
        uint32_t byteCounter = 0;
        for( int i = 0; i < stripped.length; i++ )
        {
            int bitCounter = (i % 8);
            
            uint8_t bit = (bits[i] == '1');
            
            // big-endian (if you are on intel)
//            byte |= bit << (7 - bitCounter);
            // little-endian
            byte |= bit << bitCounter;

            if( bitCounter == 7 )
            {
                buffer[byteCounter++] = byte;
                byte = 0;
            }
        }
        
//        printf( "Input: %s\nBinary: ", stripped.UTF8String );
        for( int i = 0; i < byteCounter; i++ )
        {
            for( int x = 0; x < 8; x++ )
                printf( "%d", (buffer[i] & (1 << x)) >> x );

            printf( " " );
        }
//
//        printf( "\nDecimal: " );
//        for( int i = 0; i < byteCounter; i++ )
//            printf( "%3u ", buffer[i] );
//
        printf( "\nHex:     " );
        for( int i = 0; i < byteCounter; i++ )
            printf( "%3X ", buffer[i] );
//
//
//        printf( "\nNibbles:  " );
//        for( int i = 0; i < byteCounter; i++ )
//            printf( "%2u %2u ", (buffer[i] & 0xF0) >> 4, buffer[i] & 0xF );
//
        printf( "\nHibbles:  " );
        for( int i = 0; i < byteCounter; i++ )
            printf( "%2X %2X ", (buffer[i] & 0xF0) >> 4, buffer[i] & 0xF );
//            printf( "%2X %2X ", buffer[i] & 0xF, (buffer[i] & 0xF0) >> 4 );

        printf( "\nNumber of bits in message: %d\n", (int)stripped.length );

        
        
        weatherData* wd = (weatherData*)buffer;
        int nibbles = wd->num_quartets;
        printf( "\nWeather:  station_id: %d, error: %d, aquiring: %d, quartets: %d\n", wd->station_id, wd->error, wd->aquiring, nibbles );

//        quartet* q = (quartet*)&wd->start_quartets;
//        for( int i = 0; i < wd->num_quartets; i++ )
//        {
//            printf( "\nQuartet:  type: %d, data: ", q->type );
//            printf( "%2u %2u %2u\n", (q->data & 0xF00) >> 8, (q->data & 0xF0) >> 4, q->data & 0xF );
////            printf( "%2x %2x %2x\n", (q->data & 0xF00) >> 8, (q->data & 0xF0) >> 4, q->data & 0xF );
//
//            ++q;
//        }

////        uint8_t* q = &wd->num_quartets;
//        printf( "\nQuartets: " );
//        uint8_t* q = (uint8_t*)&wd->start_quartets;
//        for( int i = 0; i < nibbles - 1; i++ )
//        {
//            if( i & 1 )
//            {
//                printf( "%2x ", *q & 0xF );
//                ++q;
//            }
//            else
//                printf( "%2x ", (*q & 0xF0) >> 4 );
////            printf( "%2x %2x %2x\n", (q->data & 0xF00) >> 8, (q->data & 0xF0) >> 4, q->data & 0xF );
//      }
        printf( "\n" );

    }
    return 0;
}
