#pragma once
#include "../EA_Core/Types.mqh"

TradeSignal EvalEMAPullback()
{
   TradeSignal s; s.signal = SIGNAL_NONE; s.strategy = STRAT_EMA_PULLBACK;

   double emaFast0 = iMA(_Symbol, PERIOD_M5, InpFastEMA, 0, MODE_EMA, PRICE_CLOSE, 0);
   double emaSlow0 = iMA(_Symbol, PERIOD_M5, InpSlowEMA, 0, MODE_EMA, PRICE_CLOSE, 0);
   double close1 = iClose(_Symbol, PERIOD_M5, 1);
   double open1 = iOpen(_Symbol, PERIOD_M5, 1);
   double atr = iATR(_Symbol, PERIOD_M5, InpATRPeriod, 0);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   bool bullTrend = emaFast0 > emaSlow0;
   bool bearTrend = emaFast0 < emaSlow0;

   if(bullTrend && close1 <= emaFast0 && close1 > emaSlow0 && close1 > open1)
   {
      s.signal = SIGNAL_BUY;
      s.entry = bid;
      s.sl = bid - InpSL_ATR_Mult * atr;
      s.tp = bid + (bid - s.sl) * InpMinRR;
      s.note = "EMAPullback BUY";
   }
   else if(bearTrend && close1 >= emaFast0 && close1 < emaSlow0 && close1 < open1)
   {
      s.signal = SIGNAL_SELL;
      s.entry = bid;
      s.sl = bid + InpSL_ATR_Mult * atr;
      s.tp = bid - (s.sl - bid) * InpMinRR;
      s.note = "EMAPullback SELL";
   }
   return s;
}
