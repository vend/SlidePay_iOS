//
//  AudioReader.h
//  Test2
//
//  Created by Don Messerli on 10/19/12.
//  
//

#ifndef __Test2__AudioReader__
#define __Test2__AudioReader__

#include <iostream>

class AudioReader
{
    AudioReader();
    ~AudioReader();
    void getResponseDataBytes(unsigned long*);
    int getCardStatus();
    void setCommand(int, int);
    void DFM_vFixCheckDigit(unsigned char*, int, unsigned char);
    int getBatteryLevel();
    void getCommand(int*);
    void clearData();
    void cleanUp();
    long getSwipeCount();
    int getTrackStatus();
    void processSamples(long);
    void setEventMask(long);
};
#endif /* defined(__Test2__AudioReader__) */
