//+------------------------------------------------------------------+
//|                                                    clsCandle.mqh |
//|                                                      FutureRobot |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "FutureRobot"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class clsCandle
  {
private:
                     datetime arrCurrentTimeCandle[1];                     
public:
                     clsCandle();
                    ~clsCandle();
                    bool CheckCurrentCandle();
                    datetime GetCurrentCandle(){ return(arrCurrentTimeCandle[0]);};
  };

bool clsCandle::CheckCurrentCandle()
{
   if (Time[1] != arrCurrentTimeCandle[0])
   {  
      arrCurrentTimeCandle[0] = Time[1];
      return(true);
   }
   
   return(false);
      
}
clsCandle::clsCandle()
  {
  }

clsCandle::~clsCandle()
  {
  }
//+------------------------------------------------------------------+
