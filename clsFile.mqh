//+------------------------------------------------------------------+
//|                                                      clsFile.mqh |
//|                                                      FutureRobot |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "FutureRobot"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <clsStruct.mqh>

class clsFile
  {
private:           
                     int fileOpenStatus;
                     int OpenOrder;   
                     string FileName;
                     strGlobal arrFromFile[];                  
                     
                     bool OpenFileArray();
                     void CloseFileArray();
                     bool AddMagicNumberToArray(int _magicnumber);
                     bool CompareCurrentOrderToFile();
                     bool AddMagicNumberToFile(int _magicnumber);                     
public:              
                     bool Read1DimensionArrayFromFile(strGlobal &arr[]);
                     bool Write1DimensionArrayToFile(strGlobal &arr[]);
                                          
                     bool AddMagicNumber(int _magicnumber);
                     void Init();
                     void Copy1DimensionArrayToArray(strGlobal &arrSource[], strGlobal &arrDestine[]);
                     void GetOrderArrayFromFile(strGlobal &arrFile[]){Copy1DimensionArrayToArray(arrFromFile,arrFile);};
                     
                     int GetOpenOrder(){return (OpenOrder);}; 
                     clsFile(string _filename);
                    ~clsFile();                    
  };
  
 void clsFile::Init()
 { 
   if(Read1DimensionArrayFromFile(arrFromFile))
      if(!CompareCurrentOrderToFile())
         FileDelete(FileName);         
 }
 
 bool clsFile::AddMagicNumber(int _magicnumber)
 {
   if(Read1DimensionArrayFromFile(arrFromFile))
      if(AddMagicNumberToArray(_magicnumber))   
         if(AddMagicNumberToFile(_magicnumber))
            return(true);
   
   return(false);
 }
 bool clsFile::AddMagicNumberToFile(int _magicnumber)
 {
   bool b= false;
   if(Write1DimensionArrayToFile(arrFromFile))
      b=true;
   
   return (b);
 }
 
 bool clsFile::AddMagicNumberToArray(int _magicnumber)
 {
   int arrsize = ArraySize(arrFromFile);
   
   for (int i=0; i<=arrsize-1;i++)
   {
      if(arrFromFile[i].magicnumber==_magicnumber)
         return(false);
   }
   
   ArrayResize(arrFromFile,arrsize+1);
   arrFromFile[arrsize].magicnumber=_magicnumber;
   
   return(true);
 }
 
 bool clsFile::CompareCurrentOrderToFile()
 {
   strGlobal arr[];
   int j=0;
   int arrsize;
   int arrsizeMN = ArraySize(arrFromFile);
   bool b = false;
   
   for (int h=0; h<=arrsizeMN-1; h++)
   {
      for (int i=OrdersTotal()-1; i>=0; i--)
      {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            if(arrFromFile[h].magicnumber == OrderMagicNumber())
            {
               arrsize = ArraySize(arr);
               ArrayResize(arr,arrsize+1);
               arr[j].magicnumber=arrFromFile[h].magicnumber;
               j++;
               break;
            }
      }
   }
   
   //check if is empty
   if (ArraySize(arr)<=0)      
      return(b);
   else
   {  
      if(Write1DimensionArrayToFile(arr))
      {
         Copy1DimensionArrayToArray(arr,arrFromFile);
         OpenOrder=ArraySize(arrFromFile);
         b=true;
      }         
      return(b);
   }
   
 }

 void clsFile::CloseFileArray()
 {
    FileClose(fileOpenStatus);
 }
 bool clsFile::OpenFileArray()
 { 
   fileOpenStatus = FileOpen(FileName,FILE_BIN|FILE_READ|FILE_WRITE);
   
   if (fileOpenStatus < 0)
     return(false);
      
   return (true);
 }
 
 void clsFile::Copy1DimensionArrayToArray(strGlobal &arrSource[],strGlobal &arrDestine[])
 {
   ArrayFree(arrDestine);
   ArrayCopy(arrDestine,arrSource);
 } 
 
 bool clsFile::Read1DimensionArrayFromFile(strGlobal &arr[])
 {
   bool b=false;
   if(OpenFileArray())
   {
      FileReadArray(fileOpenStatus,arr);  
      b=true;
   }      
   CloseFileArray();  
   
   return (b);
 }

bool clsFile::Write1DimensionArrayToFile(strGlobal &arr[])
{
   bool b=false;
   FileDelete(FileName);
   if(OpenFileArray())
   {      
      FileWriteArray(fileOpenStatus,arr);   
      b=true;
   }
   
   CloseFileArray(); 
   
   return (b);
}       

clsFile::clsFile(string _filename)
  {
      FileName =_filename;
  }
clsFile::~clsFile()
  {
      FileClose(fileOpenStatus);
  }

