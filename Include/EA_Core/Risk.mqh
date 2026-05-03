#pragma once
#include "Config.mqh"

bool IsSessionAllowedUTC()
{
   MqlDateTime tm;
   TimeToStruct(TimeCurrent(), tm);
   bool london = (tm.hour >= InpLondonStartHour && tm.hour < InpLondonEndHour);
   bool ny = (tm.hour >= InpNYStartHour && tm.hour < InpNYEndHour);
   return (london || ny);
}

bool DailyLossLimitHit(RuntimeStats &stats)
{
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   double ddPct = (stats.dayStartEquity - eq) / stats.dayStartEquity * 100.0;
   return ddPct >= InpDailyLossLimitPct;
}

bool CooldownActive(const RuntimeStats &stats)
{
   if(stats.lossStreak <= 0) return false;
   return (TimeCurrent() - stats.lastLossTime) < InpCooldownMinutesAfterLoss * 60;
}

double ComputeLotByRisk(double slPoints)
{
   if(slPoints <= 0.0) return 0.0;
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double riskMoney = equity * (InpRiskPerTradePct / 100.0);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

   if(tickSize <= 0 || tickValue <= 0 || point <= 0) return 0.0;

   double valuePerPointPerLot = tickValue * (point / tickSize);
   double lot = riskMoney / (slPoints * valuePerPointPerLot);

   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   lot = MathFloor(lot / lotStep) * lotStep;
   if(lot < minLot) lot = 0.0;
   if(lot > maxLot) lot = maxLot;
   return lot;
}
