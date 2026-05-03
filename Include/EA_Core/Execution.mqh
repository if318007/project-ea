#pragma once
#include "Risk.mqh"

class OrderExecutor
{
private:
   CTrade m_trade;
   ENUM_ORDER_EXEC_STATE m_state;
   int m_retryCount;
   ulong m_lastTicket;

public:
   void Init(long magic)
   {
      m_trade.SetExpertMagicNumber(magic);
      m_trade.SetDeviationInPoints(InpSlippageMaxPoints);
      m_state = EXEC_IDLE;
      m_retryCount = 0;
      m_lastTicket = 0;
   }

   bool SpreadTooHigh()
   {
      int spread = (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
      return spread > InpMaxSpreadPoints;
   }

   bool SpreadSpikeGuard()
   {
      if(!InpUseSpreadSpikeGuard) return false;
      int curr = (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
      double avg = 0.0;
      for(int i=1;i<=20;i++) avg += (double)iHigh(_Symbol, PERIOD_M1, i) - (double)iLow(_Symbol, PERIOD_M1, i);
      avg = avg / 20.0;
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      if(point <= 0) return false;
      double pseudoSpreadAvgPoints = (avg / point) * 0.02;
      return (curr > pseudoSpreadAvgPoints * (InpSpreadSpikeMultiplierX10 / 10.0));
   }

   bool ExecuteSignal(const TradeSignal &sig, RuntimeStats &stats)
   {
      if(sig.signal == SIGNAL_NONE) return false;

      m_state = EXEC_PRECHECK;
      while(m_state != EXEC_IDLE && m_state != EXEC_ABORT)
      {
         switch(m_state)
         {
            case EXEC_PRECHECK:
               if(SpreadTooHigh() || SpreadSpikeGuard()) { m_state = EXEC_ABORT; break; }
               m_state = EXEC_SEND;
               break;

            case EXEC_SEND:
            {
               bool ok = false;
               double lot = ComputeLotByRisk(MathAbs(sig.entry - sig.sl) / _Point);
               if(lot <= 0) { m_state = EXEC_ABORT; break; }

               if(sig.signal == SIGNAL_BUY)
                  ok = m_trade.Buy(lot, _Symbol, 0.0, sig.sl, sig.tp, sig.note);
               else if(sig.signal == SIGNAL_SELL)
                  ok = m_trade.Sell(lot, _Symbol, 0.0, sig.sl, sig.tp, sig.note);

               if(ok) m_state = EXEC_VERIFY;
               else
               {
                  int ret = (int)m_trade.ResultRetcode();
                  bool retriable = (ret == TRADE_RETCODE_REQUOTE || ret == TRADE_RETCODE_PRICE_CHANGED || ret == TRADE_RETCODE_REJECT);
                  if(retriable && m_retryCount < InpOrderRetries)
                  {
                     m_retryCount++;
                     m_state = EXEC_RETRY_WAIT;
                  }
                  else m_state = EXEC_ABORT;
               }
               break;
            }

            case EXEC_VERIFY:
               stats.tradesToday++;
               m_retryCount = 0;
               m_state = EXEC_IDLE;
               return true;

            case EXEC_RETRY_WAIT:
               Sleep(InpRetryDelayMs);
               m_state = EXEC_PRECHECK;
               break;

            default:
               m_state = EXEC_ABORT;
               break;
         }
      }
      m_retryCount = 0;
      m_state = EXEC_IDLE;
      return false;
   }
};
