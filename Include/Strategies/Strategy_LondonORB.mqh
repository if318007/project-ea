#pragma once
#include "../EA_Core/Types.mqh"

TradeSignal EvalLondonORB()
{
   TradeSignal s; s.signal = SIGNAL_NONE; s.strategy = STRAT_LONDON_ORB;
   MqlDateTime tm; TimeToStruct(TimeCurrent(), tm);
   if(tm.hour < InpLondonStartHour || tm.hour >= InpLondonEndHour) return s;

   int bars = MathMax(1, InpORBMinutes / 5);
   int hi = iHighest(_Symbol, PERIOD_M5, MODE_HIGH, bars, 1);
   int lo = iLowest(_Symbol, PERIOD_M5, MODE_LOW, bars, 1);
   double rangeHigh = iHigh(_Symbol, PERIOD_M5, hi);
   double rangeLow = iLow(_Symbol, PERIOD_M5, lo);
   double atr = iATR(_Symbol, PERIOD_M5, InpATRPeriod, 0);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   if(bid > rangeHigh + InpORBBufferATR * atr)
   {
      s.signal = SIGNAL_BUY;
      s.entry = bid;
      s.sl = rangeLow;
      s.tp = bid + (bid - s.sl) * InpMinRR;
      s.note = "LondonORB BUY";
   }
   else if(bid < rangeLow - InpORBBufferATR * atr)
   {
      s.signal = SIGNAL_SELL;
      s.entry = bid;
      s.sl = rangeHigh;
      s.tp = bid - (s.sl - bid) * InpMinRR;
      s.note = "LondonORB SELL";
   }
   return s;
}
