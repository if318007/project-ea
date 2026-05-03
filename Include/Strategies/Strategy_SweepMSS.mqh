#ifndef STRATEGY_SWEEP_MSS_MQH
#define STRATEGY_SWEEP_MSS_MQH

#include "../EA_Core/Config.mqh"

TradeSignal EvalSweepMSS()
{
   TradeSignal s; s.signal = SIGNAL_NONE; s.strategy = STRAT_SWEEP_MSS;

   double atr = iATR(_Symbol, PERIOD_M5, InpATRPeriod, 0);
   int hhIdx = iHighest(_Symbol, PERIOD_M5, MODE_HIGH, InpSweepLookbackBars, 1);
   int llIdx = iLowest(_Symbol, PERIOD_M5, MODE_LOW, InpSweepLookbackBars, 1);
   double hh = iHigh(_Symbol, PERIOD_M5, hhIdx);
   double ll = iLow(_Symbol, PERIOD_M5, llIdx);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   if(bid < ll - InpSweepBufferATR * atr && iClose(_Symbol, PERIOD_M1, 1) > ll)
   {
      s.signal = SIGNAL_BUY;
      s.entry = bid;
      s.sl = bid - InpSL_ATR_Mult * atr;
      s.tp = bid + (bid - s.sl) * InpMinRR;
      s.note = "SweepMSS BUY";
   }
   else if(bid > hh + InpSweepBufferATR * atr && iClose(_Symbol, PERIOD_M1, 1) < hh)
   {
      s.signal = SIGNAL_SELL;
      s.entry = bid;
      s.sl = bid + InpSL_ATR_Mult * atr;
      s.tp = bid - (s.sl - bid) * InpMinRR;
      s.note = "SweepMSS SELL";
   }
   return s;
}

#endif // STRATEGY_SWEEP_MSS_MQH
