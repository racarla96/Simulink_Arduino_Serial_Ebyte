//SerialEbyteDriver.h
#ifndef _SERIALEBYTEDRIVER_H_
#define _SERIALEBYTEDRIVER_H_
#ifdef __cplusplus
extern "C" {
#endif
    #if (defined(MATLAB_MEX_FILE) || defined(RSIM_PARAMETER_LOADING) ||  defined(RSIM_WITH_SL_SOLVER))
        /* This will be run in Rapid Accelerator Mode */
        #define SerialEbyteDriver_Init(a)            (0)
        #define SerialEbyteDriver_Step_Send(a,b,c)   (0)
        #define SerialEbyteDriver_Step_Recv(a,b,c)   (0)
        //#define SerialEbyteDriver_Terminate()        (0)
    #else
        #include <stdint.h>

        void SerialEbyteDriver_Init(int8_t);
        void SerialEbyteDriver_Step_Send(int8_t, int8_t*, int8_t);
        void SerialEbyteDriver_Step_Recv(int8_t, uint8_t*, int8_t*);
        //void SerialEbyteDriver_Terminate(void);
#endif
#ifdef __cplusplus
}
#endif
#endif 