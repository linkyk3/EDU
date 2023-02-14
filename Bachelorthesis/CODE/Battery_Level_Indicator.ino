void check_batt_level(){
  //7.4V Battery
  value_74 = analogRead(lvl_74) * resolutionVoltage;
  voltage_74 = value_74 * ((R1_74 + R2_74) / R1_74);
  //Serial.println(voltage_74);
  //Terminal.println("7.4V Battery Voltage Level:");
  //Terminal.print(voltage_74);
  if(voltage_74 <= limit_74){
    digitalWrite(led_74, HIGH);
    Serial.println("7.4V LOW VOLTAGE");
    Terminal.println("7.4V LOW VOLTAGE");
  }
  else{
    digitalWrite(led_74, LOW);
  }
  //11.1V Battery
  value_11 = analogRead(lvl_11) * resolutionVoltage;
  voltage_11 = value_11 * ((R1_11 + R2_11) / R1_11);
  Serial.println(voltage_11);
  Terminal.println("11.1V Battery Voltage Level:");
  Terminal.print(voltage_11);
  if(voltage_11 <= limit_11){
    digitalWrite(led_11, HIGH);
    Serial.println("11.1V LOW VOLTAGE");
    Terminal.println("11.1V LOW VOLTAGE");
  }
  else{
    digitalWrite(led_11, LOW);
  }
}
