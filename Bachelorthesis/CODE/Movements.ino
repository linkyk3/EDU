void neutral() {
  //Serial.println("STOP");
  s1_pos = s1_npos;
  s2_pos = s2_npos;
  servo1.writeMicroseconds(s1_pos);
  servo2.writeMicroseconds(s2_pos);
}

void forward() {
  //Serial.println("VOORUIT");
  s1_pos = s1_bpos;
  s2_pos = s2_fpos;
  servo1.writeMicroseconds(s1_pos);
  servo2.writeMicroseconds(s2_pos);
}

void backward() {
  //Serial.println("ACHTERUIT");
  s1_pos = s1_fpos;
  s2_pos = s2_bpos;
  servo1.writeMicroseconds(s1_pos);
  servo2.writeMicroseconds(s2_pos);
}

void left() {
  //Serial.println("LINKS");
  s1_pos = s1_fpos;
  s2_pos = s2_fpos;
  servo1.writeMicroseconds(s1_pos);
  servo2.writeMicroseconds(s2_pos);
}

void right() {
  //Serial.println("RECHTS");
  s1_pos = s1_bpos;
  s2_pos = s2_bpos;
  servo1.writeMicroseconds(s1_pos);
  servo2.writeMicroseconds(s2_pos);
}
