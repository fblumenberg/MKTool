// ///////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2010, Frank Blumenberg
//
// See License.txt for complete licensing and attribution information.
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// ///////////////////////////////////////////////////////////////////////////////


#import "MKSimConnection.h"
#import "IKParamSet.h"
#import "IKMixerTable.h"

#import "NSData+MKPayloadEncode.h"
#import "NSData+MKPayloadDecode.h"
#import "NSData+MKCommandEncode.h"

#import "MKDataConstants.h"

static IKMkParamset92 EE_Parameter;
static uint8_t PlatinenVersion = 21;

static void ParamSet_DefaultStickMapping(void) {
  EE_Parameter.Kanalbelegung[K_GAS] = 1;
  EE_Parameter.Kanalbelegung[K_ROLL] = 2;
  EE_Parameter.Kanalbelegung[K_NICK] = 3;
  EE_Parameter.Kanalbelegung[K_GIER] = 4;
  EE_Parameter.Kanalbelegung[K_POTI1] = 5;
  EE_Parameter.Kanalbelegung[K_POTI2] = 6;
  EE_Parameter.Kanalbelegung[K_POTI3] = 7;
  EE_Parameter.Kanalbelegung[K_POTI4] = 8;
  EE_Parameter.Kanalbelegung[K_POTI5] = 9;
  EE_Parameter.Kanalbelegung[K_POTI6] = 10;
  EE_Parameter.Kanalbelegung[K_POTI7] = 11;
  EE_Parameter.Kanalbelegung[K_POTI8] = 12;
}


/***************************************************/
/*    Default Values for parameter set 1           */
/***************************************************/
static void CommonDefaults(void) {
  EE_Parameter.Revision = EEPARAM_REVISION;
  memset(EE_Parameter.Name, 0, 12); // delete name
  if (PlatinenVersion >= 20) {
    EE_Parameter.Gyro_D = 10;
    EE_Parameter.Driftkomp = 0;
    EE_Parameter.GyroAccFaktor = 27;
    EE_Parameter.WinkelUmschlagNick = 78;
    EE_Parameter.WinkelUmschlagRoll = 78;
  }
  else {
    EE_Parameter.Gyro_D = 3;
    EE_Parameter.Driftkomp = 32;
    EE_Parameter.GyroAccFaktor = 30;
    EE_Parameter.WinkelUmschlagNick = 85;
    EE_Parameter.WinkelUmschlagRoll = 85;
  }
  EE_Parameter.GyroAccAbgleich = 32;        // 1/k
  EE_Parameter.BitConfig = 0;              // Looping usw.
  EE_Parameter.GlobalConfig = CFG_ACHSENKOPPLUNG_AKTIV | CFG_KOMPASS_AKTIV | CFG_GPS_AKTIV | CFG_HOEHEN_SCHALTER;
  EE_Parameter.ExtraConfig = CFG_GPS_AID | CFG2_VARIO_BEEP;
  EE_Parameter.GlobalConfig3 = CFG3_SPEAK_ALL;//CFG3_VARIO_FAILSAFE;
  EE_Parameter.Receiver = RECEIVER_HOTT;
  EE_Parameter.MotorSafetySwitch = 0;
  EE_Parameter.ExternalControl = 0;

  EE_Parameter.Gas_Min = 8;             // Wert : 0-32
  EE_Parameter.Gas_Max = 230;           // Wert : 33-247
  EE_Parameter.KompassWirkung = 64;    // Wert : 0-247

  EE_Parameter.Hoehe_MinGas = 30;
  EE_Parameter.MaxHoehe = 255;         // Wert : 0-247   255 -> Poti1
  EE_Parameter.Hoehe_P = 15;          // Wert : 0-32
  EE_Parameter.Luftdruck_D = 30;          // Wert : 0-247
  EE_Parameter.Hoehe_ACC_Wirkung = 0;     // Wert : 0-247
  EE_Parameter.Hoehe_HoverBand = 8;         // Wert : 0-247
  EE_Parameter.Hoehe_GPS_Z = 20;           // Wert : 0-247
  EE_Parameter.Hoehe_StickNeutralPoint = 0;// Wert : 0-247 (0 = Hover-Estimation)
  EE_Parameter.Hoehe_Verstaerkung = 15;    // Wert : 0-50 (15 -> ca. +/- 5m/sek bei Stick-Voll-Ausschlag)

  EE_Parameter.UserParam1 = 0;           // zur freien Verwendung
  EE_Parameter.UserParam2 = 0;           // zur freien Verwendung
  EE_Parameter.UserParam3 = 0;           // zur freien Verwendung
  EE_Parameter.UserParam4 = 0;           // zur freien Verwendung
  EE_Parameter.UserParam5 = 0;           // zur freien Verwendung
  EE_Parameter.UserParam6 = 0;           // zur freien Verwendung
  EE_Parameter.UserParam7 = 0;             // zur freien Verwendung
  EE_Parameter.UserParam8 = 0;             // zur freien Verwendung

  EE_Parameter.ServoNickControl = 128;     // Wert : 0-247     // Stellung des Servos
  EE_Parameter.ServoNickComp = 50;         // Wert : 0-247     // Einfluss Gyro/Servo
  EE_Parameter.ServoCompInvert = 2;        // Wert : 0-247     // Richtung Einfluss Gyro/Servo
  EE_Parameter.ServoNickMin = 15;          // Wert : 0-247     // Anschlag
  EE_Parameter.ServoNickMax = 230;         // Wert : 0-247     // Anschlag
  EE_Parameter.ServoNickRefresh = 4;
  EE_Parameter.Servo3 = 125;
  EE_Parameter.Servo4 = 125;
  EE_Parameter.Servo5 = 125;
  EE_Parameter.ServoRollControl = 128;     // Wert : 0-247     // Stellung des Servos
  EE_Parameter.ServoRollComp = 85;         // Wert : 0-247     // Einfluss Gyro/Servo
  EE_Parameter.ServoRollMin = 70;          // Wert : 0-247     // Anschlag
  EE_Parameter.ServoRollMax = 220;         // Wert : 0-247     // Anschlag
  EE_Parameter.ServoManualControlSpeed = 60;
  EE_Parameter.CamOrientation = 0;         // Wert : 0-24 -> 0-360 -> 15∞ steps

  EE_Parameter.J16Bitmask = 95;
  EE_Parameter.J17Bitmask = 243;
  EE_Parameter.WARN_J16_Bitmask = 0xAA;
  EE_Parameter.WARN_J17_Bitmask = 0xAA;
  EE_Parameter.J16Timing = 40;
  EE_Parameter.J17Timing = 40;
  EE_Parameter.NaviOut1Parameter = 0;       // Photo release in meter
  EE_Parameter.LoopGasLimit = 50;
  EE_Parameter.LoopThreshold = 90;         // Wert: 0-247  Schwelle f¸r Stickausschlag
  EE_Parameter.LoopHysterese = 50;

  EE_Parameter.NaviGpsModeControl = 254; // 254 -> Poti 2
  EE_Parameter.NaviGpsGain = 100;
  EE_Parameter.NaviGpsP = 90;
  EE_Parameter.NaviGpsI = 90;
  EE_Parameter.NaviGpsD = 90;
  EE_Parameter.NaviGpsPLimit = 75;
  EE_Parameter.NaviGpsILimit = 85;
  EE_Parameter.NaviGpsDLimit = 75;
  EE_Parameter.NaviGpsACC = 0;
  EE_Parameter.NaviGpsMinSat = 6;
  EE_Parameter.NaviStickThreshold = 8;
  EE_Parameter.NaviWindCorrection = 90;
  EE_Parameter.NaviAccCompensation = 42;
  EE_Parameter.NaviOperatingRadius = 245;
  EE_Parameter.NaviAngleLimitation = 140;
  EE_Parameter.NaviPH_LoginTime = 5;
  EE_Parameter.OrientationAngle = 0;
  EE_Parameter.CareFreeModeControl = 0;
  EE_Parameter.UnterspannungsWarnung = 33; // Wert : 0-247 ( Automatische Zellenerkennung bei < 50)
  EE_Parameter.NotGas = 65;                // Wert : 0-247     // Gaswert bei Empangsverlust (ggf. in Prozent)
  EE_Parameter.NotGasZeit = 90;            // Wert : 0-247     // Zeit bis auf NotGas geschaltet wird, wg. Rx-Problemen
  EE_Parameter.MotorSmooth = 0;
  EE_Parameter.ComingHomeAltitude = 0;     // 0 = don't change
  EE_Parameter.FailSafeTime = 0;             // 0 = off
  EE_Parameter.MaxAltitude = 150;           // 0 = off
  EE_Parameter.AchsKopplung1 = 90;
  EE_Parameter.AchsKopplung2 = 55;
  EE_Parameter.FailsafeChannel = 0;
  EE_Parameter.ServoFilterNick = 0;
  EE_Parameter.ServoFilterRoll = 0;
}

/***************************************************/
/*    Default Values for parameter set 1           */
/***************************************************/
void ParamSet_DefaultSet1(void) // normal
{
  CommonDefaults();
  EE_Parameter.Stick_P = 10;               // Wert : 1-20
  EE_Parameter.Stick_D = 16;               // Wert : 0-20
  EE_Parameter.StickGier_P = 6;                 // Wert : 1-20
  EE_Parameter.Gyro_P = 90;                // Wert : 0-247
  EE_Parameter.Gyro_I = 120;               // Wert : 0-247
  EE_Parameter.Gyro_Gier_P = 90;           // Wert : 0-247
  EE_Parameter.Gyro_Gier_I = 120;          // Wert : 0-247
  EE_Parameter.Gyro_Stability = 6;         // Wert : 1-8
  EE_Parameter.I_Faktor = 32;
  EE_Parameter.CouplingYawCorrection = 60;
  EE_Parameter.DynamicStability = 75;
  memcpy(EE_Parameter.Name, "Fast", 4);
}


/***************************************************/
/*    Default Values for parameter set 2           */
/***************************************************/
void ParamSet_DefaultSet2(void) // beginner
{
  CommonDefaults();
  EE_Parameter.Stick_P = 8;                // Wert : 1-20
  EE_Parameter.Stick_D = 16;               // Wert : 0-20
  EE_Parameter.StickGier_P = 6;                // Wert : 1-20
  EE_Parameter.Gyro_P = 100;               // Wert : 0-247
  EE_Parameter.Gyro_I = 120;               // Wert : 0-247
  EE_Parameter.Gyro_Gier_P = 100;          // Wert : 0-247
  EE_Parameter.Gyro_Gier_I = 120;          // Wert : 0-247
  EE_Parameter.Gyro_Stability = 6;         // Wert : 1-8
  EE_Parameter.I_Faktor = 16;
  EE_Parameter.CouplingYawCorrection = 70;
  EE_Parameter.DynamicStability = 70;
  memcpy(EE_Parameter.Name, "Normal", 6);
}

/***************************************************/
/*    Default Values for parameter set 3           */
/***************************************************/
void ParamSet_DefaultSet3(void) // beginner
{
  CommonDefaults();
  EE_Parameter.Stick_P = 6;                // Wert : 1-20
  EE_Parameter.Stick_D = 10;               // Wert : 0-20
  EE_Parameter.StickGier_P = 4;           // Wert : 1-20
  EE_Parameter.Gyro_P = 100;               // Wert : 0-247
  EE_Parameter.Gyro_I = 120;               // Wert : 0-247
  EE_Parameter.Gyro_Gier_P = 100;          // Wert : 0-247
  EE_Parameter.Gyro_Gier_I = 120;          // Wert : 0-247
  EE_Parameter.Gyro_Stability = 6;         // Wert : 1-8
  EE_Parameter.I_Faktor = 16;
  EE_Parameter.CouplingYawCorrection = 70;
  EE_Parameter.DynamicStability = 70;
  memcpy(EE_Parameter.Name, "Easy", 4);
}


@implementation MKSimConnection (Settings)

- (void)addParamSet {
  NSData *d;
  IKParamSet *paramSet;
  d = [NSData dataWithBytes:&EE_Parameter length:sizeof(EE_Parameter)];
  paramSet = [[IKParamSet alloc] initWithData:d];
  [self.settings addObject:paramSet];
}

- (void)initSettings {

  self.settings = [NSMutableArray arrayWithCapacity:5];

  ParamSet_DefaultSet1();
  ParamSet_DefaultStickMapping();
  [self addParamSet];
  ParamSet_DefaultSet2();
  ParamSet_DefaultStickMapping();
  [self addParamSet];
  ParamSet_DefaultSet3();
  ParamSet_DefaultStickMapping();
  [self addParamSet];
  ParamSet_DefaultSet3();
  ParamSet_DefaultStickMapping();
  [self addParamSet];
  ParamSet_DefaultSet3();
  ParamSet_DefaultStickMapping();
  [self addParamSet];
}


- (void)sendReadSettingsResponseForIndex:(NSUInteger)index {
  if (index == 0xFF) {
    index = self.activeSetting;
  }

  if (index < 1 || index > [self.settings count]) index = 1;

  self.activeSetting = index;

  index--;

  IKParamSet *p = [self.settings objectAtIndex:index];
  p.Index = [NSNumber numberWithInt:index + 1];

  NSData *payLoad = [p data];

  [self sendResponse:[payLoad dataWithCommand:MKCommandReadSettingsResponse forAddress:kIKMkAddressFC]];
}


- (void)handleWriteSettingResponse:(NSData *)payload {

  NSDictionary *d = [payload decodeReadSettingResponse];

  IKParamSet *p = [d objectForKey:kIKDataKeyParamSet];

  NSUInteger index = [[p Index] unsignedIntValue];

  self.activeSetting = index;

  [self.settings replaceObjectAtIndex:index - 1 withObject:p];

  NSData *newPayload = [NSData dataWithBytes:(void *) &index length:sizeof(index)];
  [self sendResponse:[newPayload dataWithCommand:MKCommandWriteSettingsResponse forAddress:kIKMkAddressFC]];
}

@end


/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

static IKMkMixerTable Mixer;


/***************************************************/
/*    Default Values for Mixer Table               */
/***************************************************/
static void MixerTable_Default(void) // Quadro
{
  uint8_t i;

  Mixer.Revision = EEMIXER_REVISION;
  // clear mixer table
  for (i = 0; i < 16; i++) {
    Mixer.Motor[i][MIX_GAS] = 0;
    Mixer.Motor[i][MIX_NICK] = 0;
    Mixer.Motor[i][MIX_ROLL] = 0;
    Mixer.Motor[i][MIX_YAW] = 0;
  }
  // default = Quadro
  Mixer.Motor[0][MIX_GAS] = 64;
  Mixer.Motor[0][MIX_NICK] = +64;
  Mixer.Motor[0][MIX_ROLL] = 0;
  Mixer.Motor[0][MIX_YAW] = +64;
  Mixer.Motor[1][MIX_GAS] = 64;
  Mixer.Motor[1][MIX_NICK] = -64;
  Mixer.Motor[1][MIX_ROLL] = 0;
  Mixer.Motor[1][MIX_YAW] = +64;
  Mixer.Motor[2][MIX_GAS] = 64;
  Mixer.Motor[2][MIX_NICK] = 0;
  Mixer.Motor[2][MIX_ROLL] = -64;
  Mixer.Motor[2][MIX_YAW] = -64;
  Mixer.Motor[3][MIX_GAS] = 64;
  Mixer.Motor[3][MIX_NICK] = 0;
  Mixer.Motor[3][MIX_ROLL] = +64;
  Mixer.Motor[3][MIX_YAW] = -64;
  memcpy(Mixer.Name, "Quadro\0", 7);
}


@implementation MKSimConnection (Mixer)

- (void)initMixer {
  MixerTable_Default();

  NSData *d = [NSData dataWithBytes:&Mixer length:sizeof(Mixer)];
  self.mixerTable = [[IKMixerTable alloc] initWithData:d];

}

- (void)sendReadMixerResponse {
  NSData *payLoad = [self.mixerTable data];

  [self sendResponse:[payLoad dataWithCommand:MKCommandMixerReadResponse forAddress:kIKMkAddressFC]];
}

- (void)handleWriteMixerResponse:(NSData *)payload {
  self.mixerTable = [IKMixerTable tableWithData:payload];
  [self sendResponse:[NSData dataWithCommand:MKCommandMixerWriteResponse forAddress:kIKMkAddressFC payloadForByte:1]];
}


@end