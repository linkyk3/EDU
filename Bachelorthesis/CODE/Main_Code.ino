#define CUSTOM_SETTINGS
#define INCLUDE_GAMEPAD_MODULE
#define INCLUDE_TERMINAL_MODULE
#include <DabbleESP32.h>
#include <ESP32Servo.h>
#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BNO055.h>
#include <utility/imumaths.h>

//---Servo's---//
//Objects
Servo servo1;
Servo servo2;
//Pin Numbers
const int s1_pin = 13;
const int s2_pin = 14;
//Neutral Positions
const int s1_npos = 1550;
const int s2_npos = 1575;
//Forward Positions
const int s1_fpos = 1649; //Slower: 1649, Faster: 1749
const int s2_fpos = 1689; //Slower: 1689, Faster: 2000
//Backward Positions
const int s1_bpos = 1440; // Slower: 1440, Faster: 1355
const int s2_bpos = 1440; // Slower: 1440, Faster: 1000
//Current Positions
int s1_pos = 0;
int s2_pos = 0;

//---Battery Level---//
//IO Pins
const int lvl_74 = 27;
const int lvl_11 = 32;
const int led_74 = 25;
const int led_11 = 26;
//Other vars
double resolutionVoltage = 0.000805861; //3.3V -> 4095, 0V = 0 => 3.3/4095
const int R1_74 = 2.2; const int R2_74 = 2.7;
const int R1_11 = 3.3; const int R2_11 = 2.7;
const int limit_74 = 5;
const int limit_11 = 4;
double value_74; double voltage_74;
double value_11; double voltage_11;

//---IMU Sensor---//
#define BNO055_SAMPLERATE_DELAY_MS (100)
Adafruit_BNO055 bno = Adafruit_BNO055(55, 0x29);



void setup() {
  //Serial Monitor
  Serial.begin(115200);
  //Bluetooth
  Dabble.begin("ESP32");
  
  //Servo
  servo1.attach(s1_pin);
  servo2.attach(s2_pin);
  s1_pos = s1_npos;
  s2_pos = s2_npos;

  //Battery Levels
  pinMode(lvl_74, INPUT);
  pinMode(lvl_11, INPUT);
  pinMode(led_74, OUTPUT);
  pinMode(led_11, OUTPUT);
  digitalWrite(led_74, LOW);
  digitalWrite(led_11, LOW);

  //IMU
   if(!bno.begin())
  {
    /* There was a problem detecting the BNO055 ... check your connections */
    Serial.print("Ooops, no BNO055 detected ... Check your wiring or I2C ADDR!");
    while(1);
  }
  delay(1000);
  /* Display some basic information on this sensor */
  displaySensorDetails();
}

void loop() {
  //Bluetooth and Servo Control
  Dabble.processInput();
  if (GamePad.getRadius() <= 1) {
    neutral();
  }
  if (GamePad.getAngle() >= 60 && GamePad.getAngle() <= 120)
  {
    forward();
  }
  if (GamePad.getAngle() >= 240 && GamePad.getAngle() <= 300)
  {
    backward();
  }
  if (GamePad.getAngle() >= 150 && GamePad.getAngle() <= 210)
  {
    left();
  }
  if (GamePad.getXaxisData() >= 5.20 && GamePad.getYaxisData() >= -3 && GamePad.getYaxisData() <= 3) // angle cant be >= 330 and <= 30 at the same time
  {
    right();
  }

  //Battery Level Checker
  //check_batt_level();

  //IMU
  //IMU_info();
}
