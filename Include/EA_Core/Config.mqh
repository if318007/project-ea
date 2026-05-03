#pragma once
#include <Trade/Trade.mqh>
#include "Types.mqh"

input group "=== General ==="
input long InpMagicNumber = 26050301;
input ENUM_TIMEFRAMES InpEntryTF = PERIOD_M5;
input ENUM_TIMEFRAMES InpConfirmTF = PERIOD_M15;
input bool InpAllowBuy = true;
input bool InpAllowSell = true;

input group "=== Risk Management ==="
input double InpRiskPerTradePct = 0.50;
input double InpDailyLossLimitPct = 1.50;
input int InpMaxTradesPerDay = 3;
input int InpMaxConsecutiveLoss = 2;
input int InpCooldownMinutesAfterLoss = 60;
input double InpMinRR = 2.0;

input group "=== Execution Guards ==="
input int InpMaxSpreadPoints = 35;
input int InpSpreadSpikeMultiplierX10 = 13; // 1.3x
input int InpSlippageMaxPoints = 20;
input int InpOrderRetries = 3;
input int InpRetryDelayMs = 400;
input bool InpUseSpreadSpikeGuard = true;

input group "=== Session Filter (UTC) ==="
input int InpLondonStartHour = 7;
input int InpLondonEndHour = 11;
input int InpNYStartHour = 12;
input int InpNYEndHour = 16;

input group "=== Strategy Selection ==="
input bool InpUseSweepMSS = true;
input bool InpUseLondonORB = true;
input bool InpUseEMAPullback = true;

input group "=== Strategy Params: Sweep + MSS ==="
input int InpSweepLookbackBars = 30;
input int InpMSSBreakBars = 5;
input double InpSweepBufferATR = 0.10;

input group "=== Strategy Params: London ORB ==="
input int InpORBMinutes = 30;
input double InpORBBufferATR = 0.20;

input group "=== Strategy Params: EMA Pullback ==="
input int InpFastEMA = 20;
input int InpSlowEMA = 50;
input int InpATRPeriod = 14;
input double InpSL_ATR_Mult = 1.2;

class RuntimeStats
{
public:
   int tradesToday;
   int lossStreak;
   datetime lastLossTime;
   double dayStartEquity;
   int cachedDay;

   void ResetDayIfNeeded()
   {
      MqlDateTime tm;
      TimeToStruct(TimeCurrent(), tm);
      if(cachedDay != tm.day)
      {
         cachedDay = tm.day;
         tradesToday = 0;
         lossStreak = 0;
         dayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      }
   }
};
