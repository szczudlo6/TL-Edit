 //+------------------------------------------------------------------+
//|                                               TrendLineTrade.mq4 |
//|                                                      FutureRobot |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "FutureRobot"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <clsStruct.mqh>
#include <EDIT_hCandle.mqh>
#include <EDIT_clsTrendLine.mqh>
#include <EDIT_clsOrder.mqh>
#include <EDIT_clsFile.mqh>

extern double MoneyRisk = 2.0;
extern double StopLossLine = 100;
extern double MinTakeProfit = 100;

extern int CandleNumber = 1;

extern int TrendLinePeriod = 35;
extern int BarsLimit = 200;
extern int TrendLinesNum = 5;
   
extern double PriceDeviation = 10;
extern double TrailingStop = 300;

int OpenedOrders=0;
int MaxOpenPosition = 1;

clsTrendLine TrendLine(TrendLinePeriod,BarsLimit,TrendLinesNum,PriceDeviation,CandleNumber,StopLossLine,MinTakeProfit);
clsOrder Order(MoneyRisk,MaxOpenPosition);
clsFile FilesOrders("TL_ROBOT_"+(string)AccountNumber() + "_"+Symbol()+"_"+(string)Period()+"_Orders.txt");

int OnInit()
  { 
   strGlobal arr[];
  
   int CheckOpenPosition=0;
   //initTrendLineClass(TrendLinePeriod,BarsLimit,TrendLinesNum,PriceDeviation,CandleNumber);
   Comment("Account Balance: " + (string)NormalizeDouble(AccountBalance(),2));
   
   initTimeCandle(CandleNumber);
   FilesOrders.Init();
   //get open position
   CheckOpenPosition=FilesOrders.GetOpenOrder();
   
   if(CheckOpenPosition > OpenedOrders)
      OpenedOrders=CheckOpenPosition;
   
   //set trendline
   TrendLine.initTrendLine(OpenedOrders);
   
   //copy magic number array
   FilesOrders.GetOrderArrayFromFile(arr);
   Order.SetOrderArrayFromFile(arr);
                              
   return(INIT_SUCCEEDED);
   }
 
void OnTick()
{    
   if(OpenedOrders==0 && CheckCurrentCandle(CandleNumber))
   {     
      TrendLine.initTrendLine(OpenedOrders);
      if(TrendLine.GetValueByShiftInFuncLine())       
         if(Order.OpenOrder(OpenedOrders,TrendLine.GetOrder(),0,TrendLine.GetStopLoss(),0,TrendLine.GetMagicNumber()))
         {
            //add magicnumber to file
            if (!FilesOrders.AddMagicNumber(TrendLine.GetMagicNumber()))
               Print("Cannot add order to array");
               
            OpenedOrders++;            
         }     
  }   
   else if (OpenedOrders>0)
      CheckCurrentOrders();
}
  
void CheckCurrentOrders()
{  
   int magicnumber=0;
   int b=false;
   
   for (int i=OrdersTotal()-1; i >= 0 ;i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         magicnumber = OrderMagicNumber();
         if(Order.CheckMagicNumber(magicnumber))
         {
            b=true;
            Order.Trailing(magicnumber,TrailingStop);
            if(TrendLine.CheckPriceIsInTrendLine(magicnumber,OrderType(),OrderOpenPrice()))
               if(Order.CloseOrderByMagicNumber(magicnumber))
               {
                  OpenedOrders--;
                  FilesOrders.Init();
               }
         } 
      }
   }
   
   //if order was opened but not exist in server
   if (!b)
      OpenedOrders=0;
}