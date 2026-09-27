//+------------------------------------------------------------------+
//| RapidMove_RiskRadar_Experimental.mq5                             |
//| Experimental rapid-move RISK alert. No buy/sell recommendation.  |
//| Trained and walk-forward checked on supplied broker OHLC exports. |
//+------------------------------------------------------------------+
#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_label1  "Rapid move risk"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrOrangeRed
#property indicator_width1  2

enum ENUM_RM_ASSET_PROFILE
  {
   PROFILE_AUTO=0,
   PROFILE_GOLD=1,
   PROFILE_NASDAQ=2
  };

input ENUM_RM_ASSET_PROFILE InpAssetProfile=PROFILE_AUTO;
input int  InpHistoryBars=5000;
input bool InpPopupAlert=true;

double RiskBuffer[];
datetime g_last_bar=0;
bool g_initialized=false;

// Model feature order:
// current abs return, current range, abs returns/ranges for lags 1..3,
// absolute 3-bar momentum, absolute 10-bar momentum.

ENUM_RM_ASSET_PROFILE DetectAsset()
  {
   if(InpAssetProfile!=PROFILE_AUTO) return InpAssetProfile;
   string s=_Symbol;
   StringToUpper(s);
   if(StringFind(s,"XAU")>=0 || StringFind(s,"GOLD")>=0) return PROFILE_GOLD;
   if(StringFind(s,"NAS")>=0 || StringFind(s,"NDX")>=0 ||
      StringFind(s,"USTEC")>=0 || StringFind(s,"US100")>=0 ||
      StringFind(s,"NQ100")>=0) return PROFILE_NASDAQ;
   return PROFILE_AUTO;
  }

bool LoadModel(ENUM_RM_ASSET_PROFILE asset,ENUM_TIMEFRAMES timeframe,
               double &means[],double &scales[],double &weights[],
               double &intercept,double &threshold,string &profile)
  {
   ArrayResize(means,10); ArrayResize(scales,10); ArrayResize(weights,10);
   if(asset==PROFILE_GOLD && timeframe==PERIOD_M1)
   {
      ArrayResize(means,10);
      means[0]=0.755746936182;
      means[1]=1.40457282537;
      means[2]=0.754856429932;
      means[3]=1.40303001178;
      means[4]=0.754356451127;
      means[5]=1.40191840928;
      means[6]=0.753826209835;
      means[7]=1.40089286818;
      means[8]=1.32101052625;
      means[9]=2.38529269748;
      ArrayResize(scales,10);
      scales[0]=0.680397813101;
      scales[1]=0.77206951548;
      scales[2]=0.675811743482;
      scales[3]=0.763040751108;
      scales[4]=0.673155991592;
      scales[5]=0.757188827652;
      scales[6]=0.670331081983;
      scales[7]=0.751753813634;
      scales[8]=1.14547582956;
      scales[9]=1.99432765648;
      ArrayResize(weights,10);
      weights[0]=-0.17935195559;
      weights[1]=0.459246215135;
      weights[2]=-0.18377809828;
      weights[3]=0.309673351732;
      weights[4]=-0.159910872664;
      weights[5]=0.265773868171;
      weights[6]=-0.151704492884;
      weights[7]=0.268481200684;
      weights[8]=0.0581484044259;
      weights[9]=0.11344515346;
      intercept=-0.234148676582; threshold=0.718710152475; profile="Gold M1"; return true;
   }
   if(asset==PROFILE_GOLD && timeframe==PERIOD_M5)
   {
      ArrayResize(means,10);
      means[0]=0.759638523726;
      means[1]=1.51990769558;
      means[2]=0.758808053756;
      means[3]=1.51810092107;
      means[4]=0.758136222614;
      means[5]=1.51641436425;
      means[6]=0.757255130105;
      means[7]=1.51488395453;
      means[8]=1.31147988549;
      means[9]=2.39263390622;
      ArrayResize(scales,10);
      scales[0]=0.711894808843;
      scales[1]=0.889235984708;
      scales[2]=0.706000013278;
      scales[3]=0.871553904086;
      scales[4]=0.702292014797;
      scales[5]=0.859101236534;
      scales[6]=0.698157446069;
      scales[7]=0.849994756002;
      scales[8]=1.22389565517;
      scales[9]=2.12281866469;
      ArrayResize(weights,10);
      weights[0]=-0.179269270933;
      weights[1]=0.58809607254;
      weights[2]=-0.141315914335;
      weights[3]=0.346700608673;
      weights[4]=-0.163446944015;
      weights[5]=0.288140616392;
      weights[6]=-0.160698798182;
      weights[7]=0.29114796477;
      weights[8]=0.057186910332;
      weights[9]=0.106508820782;
      intercept=-0.362915505181; threshold=0.78264567131; profile="Gold M5"; return true;
   }
   if(asset==PROFILE_GOLD && timeframe==PERIOD_M15)
   {
      ArrayResize(means,10);
      means[0]=0.747670083488;
      means[1]=1.52761000376;
      means[2]=0.750059949189;
      means[3]=1.53209745454;
      means[4]=0.754626547725;
      means[5]=1.53990387326;
      means[6]=0.753451727274;
      means[7]=1.53825624847;
      means[8]=1.30452677444;
      means[9]=2.41631440169;
      ArrayResize(scales,10);
      scales[0]=0.725820943231;
      scales[1]=0.902851449102;
      scales[2]=0.719905074432;
      scales[3]=0.888025486048;
      scales[4]=0.719219568546;
      scales[5]=0.878598092484;
      scales[6]=0.714215037219;
      scales[7]=0.866874375191;
      scales[8]=1.23167552363;
      scales[9]=2.13825907429;
      ArrayResize(weights,10);
      weights[0]=-0.320570520452;
      weights[1]=0.85208888838;
      weights[2]=-0.22991452457;
      weights[3]=0.449148205497;
      weights[4]=-0.145360896503;
      weights[5]=0.221719161493;
      weights[6]=-0.0382525560155;
      weights[7]=0.138080815953;
      weights[8]=0.165654920926;
      weights[9]=-0.115115721876;
      intercept=-0.406301578147; threshold=0.798747856745; profile="Gold M15"; return true;
   }
   if(asset==PROFILE_NASDAQ && timeframe==PERIOD_M1)
   {
      ArrayResize(means,10);
      means[0]=0.750495194905;
      means[1]=1.4634446179;
      means[2]=0.749223371404;
      means[3]=1.46099728561;
      means[4]=0.748409391281;
      means[5]=1.45943894177;
      means[6]=0.747752926511;
      means[7]=1.45817945769;
      means[8]=1.32061952271;
      means[9]=2.44013390233;
      ArrayResize(scales,10);
      scales[0]=0.695175397505;
      scales[1]=0.802673874591;
      scales[2]=0.690073384145;
      scales[3]=0.789709192753;
      scales[4]=0.68678179064;
      scales[5]=0.781491645724;
      scales[6]=0.68377978142;
      scales[7]=0.774796367951;
      scales[8]=1.16122974588;
      scales[9]=2.00800613136;
      ArrayResize(weights,10);
      weights[0]=-0.155598759633;
      weights[1]=0.450802034794;
      weights[2]=-0.10604218695;
      weights[3]=0.245949685752;
      weights[4]=-0.124064942627;
      weights[5]=0.293493910661;
      weights[6]=-0.1416770916;
      weights[7]=0.291163757997;
      weights[8]=-0.0188498345095;
      weights[9]=0.122724278394;
      intercept=-0.232661785889; threshold=0.747182189518; profile="Nasdaq M1"; return true;
   }
   if(asset==PROFILE_NASDAQ && timeframe==PERIOD_M5)
   {
      ArrayResize(means,10);
      means[0]=0.768951194697;
      means[1]=1.55711559741;
      means[2]=0.765888714048;
      means[3]=1.55105185001;
      means[4]=0.763223659789;
      means[5]=1.5459014137;
      means[6]=0.760667289965;
      means[7]=1.54112724604;
      means[8]=1.34754024045;
      means[9]=2.47578785197;
      ArrayResize(scales,10);
      scales[0]=0.753156442558;
      scales[1]=0.960934005269;
      scales[2]=0.741834943103;
      scales[3]=0.936356515807;
      scales[4]=0.73311110739;
      scales[5]=0.917382120291;
      scales[6]=0.725165862599;
      scales[7]=0.90115804068;
      scales[8]=1.27946850064;
      scales[9]=2.22871416926;
      ArrayResize(weights,10);
      weights[0]=-0.182820096164;
      weights[1]=0.735905184463;
      weights[2]=-0.10136054986;
      weights[3]=0.324164295451;
      weights[4]=-0.0972609704182;
      weights[5]=0.271027266913;
      weights[6]=-0.130118711167;
      weights[7]=0.329739675618;
      weights[8]=0.0142640388885;
      weights[9]=0.036010566614;
      intercept=-0.46536175452; threshold=0.761653257274; profile="Nasdaq M5"; return true;
   }
   if(asset==PROFILE_NASDAQ && timeframe==PERIOD_M15)
   {
      ArrayResize(means,10);
      means[0]=0.736156236861;
      means[1]=1.4953820388;
      means[2]=0.731104617816;
      means[3]=1.48314151181;
      means[4]=0.724627014695;
      means[5]=1.46936339189;
      means[6]=0.718846822544;
      means[7]=1.45699304812;
      means[8]=1.27583232822;
      means[9]=2.35590887143;
      ArrayResize(scales,10);
      scales[0]=0.814287541957;
      scales[1]=1.13985233488;
      scales[2]=0.798076293974;
      scales[3]=1.10642554427;
      scales[4]=0.786434617447;
      scales[5]=1.0854462182;
      scales[6]=0.777168208014;
      scales[7]=1.07021391819;
      scales[8]=1.35549754431;
      scales[9]=2.29797810426;
      ArrayResize(weights,10);
      weights[0]=-0.166701836694;
      weights[1]=0.793690760558;
      weights[2]=-0.0923826124376;
      weights[3]=0.368920891525;
      weights[4]=-0.0908206445503;
      weights[5]=0.285308303991;
      weights[6]=-0.0765779699654;
      weights[7]=0.269627745721;
      weights[8]=-0.00595509263492;
      weights[9]=-0.00476479569252;
      intercept=-0.51473388554; threshold=0.834059926895; profile="Nasdaq M15"; return true;
   }
   return false;
  }

bool IsContiguous(const MqlRates &rates[],int count,int shift,int expected_seconds)
  {
   if(shift<0 || shift+1>=count || expected_seconds<=0) return false;
   long seconds=(long)rates[shift].time-(long)rates[shift+1].time;
   return (seconds>=(long)(expected_seconds*0.5) &&
           seconds<=(long)(expected_seconds*1.5));
  }

bool BuildFeatures(const MqlRates &rates[],int count,int shift,int expected_seconds,
                   double &features[])
  {
   if(shift<1 || shift+80>=count) return false;
   // The 10-bar momentum must not cross a session/data gap.
   for(int j=shift;j<shift+10;j++)
      if(!IsContiguous(rates,count,j,expected_seconds)) return false;

   double sum=0.0, sum2=0.0;
   int n=0;
   for(int j=shift;j<shift+80;j++)
     {
      if(!IsContiguous(rates,count,j,expected_seconds)) continue;
      if(rates[j].close<=0.0 || rates[j+1].close<=0.0) continue;
      double r=MathLog(rates[j].close/rates[j+1].close);
      sum+=r; sum2+=r*r; n++;
     }
   if(n<40) return false;
   double variance=(sum2-(sum*sum)/n)/(n-1);
   if(variance<=0.0) return false;
   double sigma=MathSqrt(variance);
   if(rates[shift].close<=0.0 || rates[shift].high<=0.0 || rates[shift].low<=0.0) return false;

   ArrayResize(features,10);
   features[0]=MathAbs(MathLog(rates[shift].close/rates[shift+1].close))/sigma;
   features[1]=MathLog(rates[shift].high/rates[shift].low)/sigma;
   int k=2;
   for(int lag=1;lag<=3;lag++)
     {
      int j=shift+lag;
      if(rates[j].close<=0.0 || rates[j+1].close<=0.0 || rates[j].high<=0.0 || rates[j].low<=0.0) return false;
      features[k++]=MathAbs(MathLog(rates[j].close/rates[j+1].close))/sigma;
      features[k++]=MathLog(rates[j].high/rates[j].low)/sigma;
     }
   features[8]=MathAbs(MathLog(rates[shift].close/rates[shift+3].close))/sigma;
   features[9]=MathAbs(MathLog(rates[shift].close/rates[shift+10].close))/sigma;
   return true;
  }

double ModelScore(const double &features[],const double &means[],const double &scales[],
                  const double &weights[],double intercept)
  {
   double z=intercept;
   for(int i=0;i<10;i++)
     {
      if(scales[i]<=0.0) return 0.0;
      z+=weights[i]*((features[i]-means[i])/scales[i]);
     }
   if(z>35.0) return 1.0;
   if(z< -35.0) return 0.0;
   return 1.0/(1.0+MathExp(-z));
  }

int OnInit()
  {
   SetIndexBuffer(0,RiskBuffer,INDICATOR_DATA);
   ArraySetAsSeries(RiskBuffer,true);
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetString(0,PLOT_LABEL,"Rapid move risk");
   IndicatorSetString(INDICATOR_SHORTNAME,"RapidMove Risk Radar (experimental)");
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   Comment("");
  }

int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &time[],const double &open[],const double &high[],
                const double &low[],const double &close[],const long &tick_volume[],
                const long &volume[],const int &spread[])
  {
   if(_Period!=PERIOD_M1 && _Period!=PERIOD_M5 && _Period!=PERIOD_M15)
     {
      Comment("RapidMove: use M1, M5 or M15. This model was not tested on other timeframes.");
      return rates_total;
     }
   ENUM_RM_ASSET_PROFILE asset=DetectAsset();
   if(asset==PROFILE_AUTO)
     {
      Comment("RapidMove: select Gold or Nasdaq in indicator settings, or use a recognized symbol name.");
      return rates_total;
     }
   double means[],scales[],weights[],intercept=0.0,threshold=0.0;
   string profile="";
   if(!LoadModel(asset,(ENUM_TIMEFRAMES)_Period,means,scales,weights,intercept,threshold,profile))
     {
      Comment("RapidMove: no tested model for this asset/timeframe.");
      return rates_total;
     }

   int requested=InpHistoryBars;
   if(requested<700) requested=700;
   if(requested>50000) requested=50000;
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(_Symbol,_Period,0,requested,rates);
   if(copied<100)
     {
      Comment("RapidMove: waiting for at least 100 historical bars.");
      return rates_total;
     }
   bool new_bar=(rates[0].time!=g_last_bar);
   if(!new_bar && prev_calculated>0) return rates_total;
   g_last_bar=rates[0].time;

   ArrayInitialize(RiskBuffer,EMPTY_VALUE);
   double latest_score=0.0;
   bool latest_ready=false;
   int expected=PeriodSeconds((ENUM_TIMEFRAMES)_Period);
   for(int shift=copied-81;shift>=1;shift--)
     {
      double x[];
      if(!BuildFeatures(rates,copied,shift,expected,x)) continue;
      double score=ModelScore(x,means,scales,weights,intercept);
      if(shift==1) { latest_score=score; latest_ready=true; }
      if(score>=threshold)
        {
         double offset=MathMax((rates[shift].high-rates[shift].low)*0.15,_Point*10.0);
         RiskBuffer[shift]=rates[shift].low-offset;
        }
     }

   string status="INSUFFICIENT HISTORY";
   if(latest_ready) status=(latest_score>=threshold ? "ELEVATED" : "NORMAL");
   if(latest_ready)
      Comment(StringFormat("RapidMove risk | %s | score index %.1f/100 | alert cutoff %.1f/100\nRelative ranking only; not a probability or buy/sell signal.",
                           status,latest_score*100.0,threshold*100.0));
   else
      Comment(StringFormat("RapidMove risk | %s | waiting for 10 continuous bars and enough volatility history.\nRelative ranking only; not a probability or buy/sell signal.",profile));

   if(g_initialized && new_bar && latest_ready && latest_score>=threshold && InpPopupAlert)
      Alert(StringFormat("RapidMove elevated risk: %s %s, score %.1f/100 (risk alert only)",
                         _Symbol,EnumToString((ENUM_TIMEFRAMES)_Period),latest_score*100.0));
   g_initialized=true;
   return rates_total;
  }
