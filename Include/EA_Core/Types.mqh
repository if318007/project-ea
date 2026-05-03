#pragma once

enum ENUM_STRATEGY_ID
{
   STRAT_SWEEP_MSS = 0,
   STRAT_LONDON_ORB = 1,
   STRAT_EMA_PULLBACK = 2
};

enum ENUM_SIGNAL
{
   SIGNAL_NONE = 0,
   SIGNAL_BUY  = 1,
   SIGNAL_SELL = -1
};

enum ENUM_ORDER_EXEC_STATE
{
   EXEC_IDLE = 0,
   EXEC_PRECHECK,
   EXEC_SEND,
   EXEC_VERIFY,
   EXEC_RETRY_WAIT,
   EXEC_ABORT
};

struct TradeSignal
{
   ENUM_SIGNAL signal;
   ENUM_STRATEGY_ID strategy;
   double sl;
   double tp;
   double entry;
   string note;
};
