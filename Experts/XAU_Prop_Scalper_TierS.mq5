#property strict
#property version   "1.00"
#property description "Tier-S XAUUSD Prop EA: Sweep+MSS, London ORB, EMA Pullback"

#include "../Include/EA_Core/Execution.mqh"
#include "../Include/Strategies/Strategy_SweepMSS.mqh"
#include "../Include/Strategies/Strategy_LondonORB.mqh"
#include "../Include/Strategies/Strategy_EMAPullback.mqh"

RuntimeStats g_stats;
OrderExecutor g_exec;

datetime g_lastBarTime = 0;

bool IsNewBar(ENUM_TIMEFRAMES tf)
{
   datetime t = iTime(_Symbol, tf, 0);
   if(t != g_lastBarTime)
   {
      g_lastBarTime = t;
      return true;
   }
   return false;
}

TradeSignal SelectSignal()
{
   TradeSignal n; n.signal = SIGNAL_NONE;

   if(InpUseSweepMSS)
   {
      TradeSignal s1 = EvalSweepMSS();
      if(s1.signal != SIGNAL_NONE) return s1;
   }
   if(InpUseLondonORB)
   {
      TradeSignal s2 = EvalLondonORB();
      if(s2.signal != SIGNAL_NONE) return s2;
   }
   if(InpUseEMAPullback)
   {
      TradeSignal s3 = EvalEMAPullback();
      if(s3.signal != SIGNAL_NONE) return s3;
   }

   return n;
}

int OnInit()
{
   g_exec.Init(InpMagicNumber);
   g_stats.cachedDay = -1;
   g_stats.ResetDayIfNeeded();
   return(INIT_SUCCEEDED);
}

void OnTick()
{
   g_stats.ResetDayIfNeeded();

   if(!IsNewBar(InpEntryTF)) return;
   if(!IsSessionAllowedUTC()) return;
   if(g_stats.tradesToday >= InpMaxTradesPerDay) return;
   if(g_stats.lossStreak >= InpMaxConsecutiveLoss) return;
   if(DailyLossLimitHit(g_stats)) return;
   if(CooldownActive(g_stats)) return;
   if(PositionsTotal() > 0) return;

   TradeSignal sig = SelectSignal();
   if(sig.signal == SIGNAL_BUY && !InpAllowBuy) return;
   if(sig.signal == SIGNAL_SELL && !InpAllowSell) return;

   g_exec.ExecuteSignal(sig, g_stats);
}

void OnTradeTransaction(const MqlTradeTransaction &trans, const MqlTradeRequest &req, const MqlTradeResult &res)
{
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD) return;
   if((long)HistoryDealGetInteger(trans.deal, DEAL_MAGIC) != InpMagicNumber) return;

   double profit = HistoryDealGetDouble(trans.deal, DEAL_PROFIT);
   if(profit < 0)
   {
      g_stats.lossStreak++;
      g_stats.lastLossTime = TimeCurrent();
   }
   else if(profit > 0)
   {
      g_stats.lossStreak = 0;
   }
}
