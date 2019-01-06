//+------------------------------------------------------------------+
//|                                                 clsTrendLine.mqh |
//|                                                      FutureRobot |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "FutureRobot"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <EDIT_clsFile.mqh>
#include <clsStruct.mqh>

#import "EDIT_clsHelperFunction.ex4"
      void QuickSortArray1Dimension5Struct(strGlobal &arr[], int StartPos, int EndPos, bool SmallestToLarges);
      string CreateMagicNumber();
#import


clsFile FileTLAbove("TL ROBOT_"+(string)AccountNumber() + "_"+Symbol()+"_"+(string)Period()+"_TLAbove.txt");
clsFile FileTLBelow("TL ROBOT_"+(string)AccountNumber() + "_"+Symbol()+"_"+(string)Period()+"_TLBelow.txt");

class clsTrendLine
  {
private:  
                    
                    int nPeriod;
                    int nCurBar;
                    int Limit;
                    int AutoTimeframe;
                    int NumOfTrendLineForArr;
                    int NumOfTrendLine;
                    int order;
                    int OpenedOrders;
                    int MagicNumber;
                    int CandleNumber;
                    int ArraySizeTrendLineAbove;
                    int ArraySizeTrendLineBelow;
                    double PriceDeviation;
                    double StopLoss;
                    double StopLossLine;                    
                    double minTakeProfit;
                    double TrendLinePriceBelow;
                    double TrendLinePriceAbove;
                    
                    strPrice arrLowS[];
                    strPrice arrHighR[];

                    strFunc arrFuncLine[];
                    strGlobal arrTrendLineAbove[];
                    strGlobal arrTrendLineBelow[];
                    
                    void SetArrayFunctionLine();
                    void SetTrendLinePeriod();
                    void SetNearestTL();
                    
                    bool LoopTrendLine(strGlobal &arr[],double price, int arrsize, int magicnumber,int ordertype, double OpenOrderPrice);
public:
                    void initTrendLine(int _OpenedOrders);
                    bool GetValueByShiftInFuncLine();
                    void SetNearestTrendLineArray();
                    bool CheckPriceIsInTrendLine(int magicnumber, int ordertype, double OpenOrderPrice);
                    int GetOrder(){return(order);};
                    int GetMagicNumber(){return(MagicNumber);};
                    double GetStopLoss(){return(StopLoss);};
                    void LoopArrayToMagicNumber(strGlobal &arr[], int &arrB[]);
                    
                     clsTrendLine(int _nPeriod, int _Limit, int _NumOfTrendLine, double _PriceDeviation, 
                     int _CandleNumber, double _StopLossLine, double minTakeProfit);
                    ~clsTrendLine();
  };

bool clsTrendLine::LoopTrendLine(strGlobal &arr[], double price, int arrsize, int magicnumber, int ordertype, double OpenOrderPrice)
{
   double CurrentPriceTrendLine;
   
   for (int i=0; i<=arrsize-1; i++)
   {
      if(arr[i].magicnumber==magicnumber)
      {
         CurrentPriceTrendLine = GetY(arr[i].a
                                       ,iBarShift(_Symbol,0,arr[i].xTimeDef)
                                       ,arr[i].b);
         
         if (ordertype == 0) //buy
         {
            if((price >= CurrentPriceTrendLine) && (price-(PriceDeviation*Point) <= CurrentPriceTrendLine
                && price > OpenOrderPrice - (minTakeProfit*Point)))          
               return(true);
         }   
         else if (ordertype == 1) //sell                                      
         {
            if((price <= CurrentPriceTrendLine) && (price+(PriceDeviation*Point) >= CurrentPriceTrendLine 
               && price < OpenOrderPrice + (minTakeProfit*Point)))          
               return(true);
         }     
      }
   }
   
   return(false);
}

bool clsTrendLine::CheckPriceIsInTrendLine(int magicnumber, int ordertype, double OpenOrderPrice)
{   
   int arrsizeAbove = ArraySize(arrTrendLineAbove);
   int arrsizeBelow = ArraySize(arrTrendLineBelow);
  
   if (ordertype == 0) //buy
      return(LoopTrendLine(arrTrendLineAbove,Bid,arrsizeAbove,magicnumber,ordertype,OpenOrderPrice));
   else if (ordertype == 1) //sell
      return (LoopTrendLine(arrTrendLineBelow,Ask,arrsizeBelow,magicnumber,ordertype,OpenOrderPrice));
   
   return (false);
}

void clsTrendLine::SetNearestTrendLineArray()
{
   int BarStart;
   int j=0, k=0;
   double TrendLinePrice;
   double CloseBar = Close[CandleNumber];
   
   for(int i=0;i<=(NumOfTrendLine*2)-1;i++)
   {            
      BarStart = iBarShift(Symbol(),0,arrFuncLine[i].xTimeDef);
      TrendLinePrice=GetY(arrFuncLine[i].a,BarStart-CandleNumber,arrFuncLine[i].b);

      if (TrendLinePrice > CloseBar)
      {
         ArrayResize(arrTrendLineAbove,j+1);
         arrTrendLineAbove[j].price = TrendLinePrice;                //price
         arrTrendLineAbove[j].a = arrFuncLine[i].a;                  //a
         arrTrendLineAbove[j].xTimeDef = arrFuncLine[i].xTimeDef;    //x time def
         arrTrendLineAbove[j].b = arrFuncLine[i].b;                  //b
         arrTrendLineAbove[j].magicnumber = 0;                       //magicnumber     
         j++;         
      }      
      else if (TrendLinePrice < CloseBar)
      {      
         ArrayResize(arrTrendLineBelow,k+1);
         arrTrendLineBelow[k].price = TrendLinePrice;                 //price
         arrTrendLineBelow[k].a = arrFuncLine[i].a;                   //a
         arrTrendLineBelow[k].xTimeDef = arrFuncLine[i].xTimeDef;     //x time def
         arrTrendLineBelow[k].b = arrFuncLine[i].b;                   //b
         arrTrendLineBelow[k].magicnumber = 0;                        //magicnumber   
         k++;
      }  
   }
    
   //Copy to file
   FileTLBelow.Write1DimensionArrayToFile(arrTrendLineBelow);
   FileTLAbove.Write1DimensionArrayToFile(arrTrendLineAbove);
   
}

bool clsTrendLine::GetValueByShiftInFuncLine()
 {
    double OpenBar;
    double CloseBar;
    double HighBar;
    double LowBar;
    bool b = false;
    
    OpenBar = Open[CandleNumber];
    CloseBar = Close[CandleNumber];
    HighBar = High[CandleNumber];
    LowBar = Low[CandleNumber];
        
    if ((TrendLinePriceBelow >= LowBar && (TrendLinePriceBelow <= CloseBar || TrendLinePriceBelow <= OpenBar))
         || (TrendLinePriceBelow + (PriceDeviation * Point) >= LowBar 
            && (TrendLinePriceBelow + (PriceDeviation * Point) <= CloseBar || TrendLinePriceBelow + (PriceDeviation * Point) <= OpenBar))
         || (TrendLinePriceBelow - (PriceDeviation * Point) >= LowBar 
            && (TrendLinePriceBelow - (PriceDeviation * Point) <= CloseBar || TrendLinePriceBelow - (PriceDeviation * Point) <= OpenBar)
            ))         
    {
      Print("Long position match");
      Print("Price Above: " + DoubleToString(TrendLinePriceAbove));
      Print("Price Below: " + DoubleToString(TrendLinePriceBelow));//long
      order=0;
      //create magicnumber      
      MagicNumber = (int)CreateMagicNumber();
      arrTrendLineAbove[0].magicnumber=MagicNumber;       
      //set stoploss
      StopLoss= MathAbs((((TrendLinePriceBelow-(StopLossLine*Point))-Ask)/Point));
      b=true;    
    }
    else if ((TrendLinePriceAbove <= HighBar && (TrendLinePriceAbove >=CloseBar || TrendLinePriceAbove >= OpenBar))
            || (TrendLinePriceAbove  + (PriceDeviation * Point) <= HighBar 
               && (TrendLinePriceAbove + (PriceDeviation * Point) >=CloseBar || TrendLinePriceAbove + (PriceDeviation * Point) >= OpenBar))
            || (TrendLinePriceAbove  - (PriceDeviation * Point) <= HighBar 
               && (TrendLinePriceAbove - (PriceDeviation * Point) >=CloseBar || TrendLinePriceAbove - (PriceDeviation * Point) >= OpenBar))
            )
    {
      Print("Short position match");
      Print("Price Above: " + DoubleToString(TrendLinePriceAbove));
      Print("Price Below: " + DoubleToString(TrendLinePriceBelow));//short
      order=1;    
      //create magicnumber 
      MagicNumber = (int)CreateMagicNumber();
      arrTrendLineBelow[0].magicnumber=MagicNumber;   
      //set stoploss
      StopLoss= MathAbs((((TrendLinePriceAbove+(StopLossLine*Point))-Bid)/Point));
      b=true; 
    }
    
  //Copy to file
   FileTLBelow.Write1DimensionArrayToFile(arrTrendLineBelow);
   FileTLAbove.Write1DimensionArrayToFile(arrTrendLineAbove);
   
  return (b);
}

double GetY(double a, double x, double b)
{
  double y = (a*x) + b;
  return (y);
}
double GetB(double a, double x, double y)
{   
  double b= -(a*x)+y;
  return (b);
}
double GetA(double Xa, double Ya, double Xb, double Yb)
{
  double a=0;  
  if((Xb-Xa)!=0)
      a = (Yb-Ya)/(Xb-Xa);
  
  return (a);
}

void clsTrendLine::SetArrayFunctionLine()
{  
   int j=0;
   for (int i=0; i<=NumOfTrendLine-1; i++)
   {      
      //Low
      arrFuncLine[j].xTimeDef=Time[MathAbs((int)arrLowS[i].barshift)];
      arrFuncLine[j].a=GetA(0,arrLowS[i].price,arrLowS[i+1].barshift-arrLowS[i].barshift,arrLowS[i+1].price);
      arrFuncLine[j].b=GetB(arrFuncLine[j].a,0,arrLowS[i].price);
   
      //High
      arrFuncLine[j+1].xTimeDef=Time[MathAbs((int)arrHighR[i].barshift)];
      arrFuncLine[j+1].a=GetA(0,arrHighR[i].price,arrHighR[i+1].barshift-arrHighR[i].barshift,arrHighR[i+1].price);
      arrFuncLine[j+1].b=GetB(arrFuncLine[j+1].a,0,arrHighR[i].price);
      
      j+=2;            
   }
   
}

void LoopArray(strPrice & arr[], int number)
{
  for (int i=number-1; i>0; i--)
  {
    arr[i].price=arr[i-1].price;
    arr[i].barshift=arr[i-1].barshift;
  }
}

void clsTrendLine::SetTrendLinePeriod()
{
    if(Bars<Limit) Limit=Bars-nPeriod;
    
    for(nCurBar=Limit; nCurBar>0; nCurBar--)
    {
      if(Low[nCurBar+(nPeriod-1)/2] == Low[iLowest(NULL,0,MODE_LOW,nPeriod,nCurBar)])
      {                
        LoopArray(arrLowS,NumOfTrendLineForArr);
        arrLowS[0].price=Low[nCurBar+(nPeriod-1)/2];
        arrLowS[0].barshift= -(nCurBar+(nPeriod-1)/2);
        
        //s6=s5; s5=s4; s4=s3; s3=s2; s2=s1; s1=Low[nCurBar+(nPeriod-1)/2];
        //st6=st5; st5=st4; st4=st3; st3=st2; st2=st1; st1=nCurBar+(nPeriod-1)/2;
      }
      if(High[nCurBar+(nPeriod-1)/2] == High[iHighest(NULL,0,MODE_HIGH,nPeriod,nCurBar)])
      {        
        LoopArray(arrHighR,NumOfTrendLineForArr);
        arrHighR[0].price=High[nCurBar+(nPeriod-1)/2];
        arrHighR[0].barshift= -(nCurBar+(nPeriod-1)/2);
        
        //r6=r5; r5=r4; r4=r3; r3=r2; r2=r1; r1=High[nCurBar+(nPeriod-1)/2];
        //rt6=rt5; rt5=rt4; rt4=rt3; rt3=rt2; rt2=rt1; rt1=nCurBar+(nPeriod-1)/2;
      }
    }    
}
void clsTrendLine::SetNearestTL()
{
    strGlobal arrAbove[];
    strGlobal arrBelow[];
     
    if(OpenedOrders==0)
      SetNearestTrendLineArray();
    else
    { 
      FileTLAbove.Read1DimensionArrayFromFile(arrAbove);
      FileTLAbove.Copy1DimensionArrayToArray(arrAbove,arrTrendLineAbove);
      FileTLBelow.Read1DimensionArrayFromFile(arrBelow);
      FileTLBelow.Copy1DimensionArrayToArray(arrBelow,arrTrendLineBelow);
    }
    
    ArraySizeTrendLineBelow=(ArraySize(arrTrendLineBelow));
    ArraySizeTrendLineAbove=(ArraySize(arrTrendLineAbove));
    
    if(ArraySizeTrendLineBelow>0)
    {
      QuickSortArray1Dimension5Struct(arrTrendLineBelow,0,(ArraySizeTrendLineBelow)-1,false);
      TrendLinePriceBelow=arrTrendLineBelow[0].price;
    }
    
    if (ArraySizeTrendLineAbove>0)
    {
      QuickSortArray1Dimension5Struct(arrTrendLineAbove,0,(ArraySizeTrendLineAbove)-1,true);
      TrendLinePriceAbove=arrTrendLineAbove[0].price;
    }
}

void clsTrendLine::initTrendLine(int _OpenedOrders)
{  
   OpenedOrders=_OpenedOrders;
   
   if(OpenedOrders==0)
   {
      SetTrendLinePeriod();
      SetArrayFunctionLine();   
   }
   
   SetNearestTL();
}

void clsTrendLine::LoopArrayToMagicNumber(strGlobal &arr[], int &arrB[])
{   
   int size =ArraySize(arr)/5;   
   ArrayResize(arrB,size);
   
   for (int i=0; i<size; i++)
   {
      arrB[i]=arr[i].magicnumber;
   }
}

clsTrendLine::clsTrendLine(int _nPeriod, int _Limit, int _NumOfTrendLine, double _PriceDeviation, 
                        int _CandleNumber, double _StopLossLine, double _minTakeProfit)
  {
    Print("Init Trend Line Class");
    nPeriod=_nPeriod;   
    nCurBar=0;
    Limit=_Limit;
    AutoTimeframe=60;
    NumOfTrendLineForArr=_NumOfTrendLine+1;
    NumOfTrendLine=_NumOfTrendLine;
    PriceDeviation=_PriceDeviation;
    CandleNumber=_CandleNumber;
    StopLossLine=_StopLossLine;
    minTakeProfit=_minTakeProfit;
    
    Print("Resize arrays");
    ArrayResize(arrLowS,NumOfTrendLineForArr);
    ArrayResize(arrHighR,NumOfTrendLineForArr);
    ArrayResize(arrFuncLine,NumOfTrendLine*2);
    
    Print("Check and correct current period");
    if (Period()<AutoTimeframe)
    {
        int AutoFactor = AutoTimeframe/Period();
        nPeriod=nPeriod*AutoFactor;
        Limit=Limit*AutoFactor;
    }
    
   Print("All set");
  }
clsTrendLine::~clsTrendLine()
  {
  }
