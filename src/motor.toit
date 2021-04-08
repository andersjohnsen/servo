// Copyright (C) 2021 Toitware ApS. All rights reserved.
import math
import gpio
import gpio.pwm

/**
A Servo Motor abstraction for configuring and working with an servo motor
  using the Pulse-Width Modulation (PWM) sub-system.

The default configuration of an servo motor is to operate at 50 Hz with the
  following mappings:
  * 1500 us pulse for angle of 0 degrees.
  * 2500 us pulse for angle of 90 degrees.
  *  500 us pulse for minimum angle.
  * 2500 us pulse for maximum angle.
  which gives a total angle of +/- 90 degrees.
*/
class Motor:
  static DEFAULT_FREQUENCY ::= 50
  static ANGLE_0_US_   ::= 1500.0
  static ANGLE_90_US_  ::= 2500.0
  static ANGLE_MIN_US_ ::= 500.0
  static ANGLE_MAX_US_ ::= 2500.0

  pwm/gpio.Pwm?
  channel/gpio.PwmChannel

  angle_0_us_/float := ANGLE_0_US_
  angle_90_us_/float := ANGLE_90_US_
  angle_min_us_/float := ANGLE_MIN_US_
  angle_max_us_/float := ANGLE_MAX_US_

  constructor.from_channel .channel/gpio.PwmChannel:
    pwm = null

  constructor pin/gpio.Pin --pwm/gpio.Pwm?=null --frequency/int=DEFAULT_FREQUENCY:
    if not pwm: pwm = gpio.Pwm --frequency=frequency
    this.pwm = pwm
    channel = pwm.start pin

  set_angle degrees/float:
    us := angle_to_us_ degrees / 180 * math.PI
    apply_us_ us

  apply_us_ us/float:
    cycle_us := (1.0 / /*channel.pwm.frequency*/ DEFAULT_FREQUENCY) * 1_000_000
    channel.set_duty_factor us / cycle_us

  angle_to_us_ rads/float -> float:
    fraction := rads / math.PI
    pi_angle := (angle_90_us_ - angle_0_us_) * 2.0
    us := angle_0_us_ + fraction * pi_angle
    return min
      max us angle_min_us_
      angle_max_us_

  config --min_us/float?=null --max_us/float?=null:
    if min_us: angle_min_us_ = min_us
    if max_us: angle_max_us_ = max_us
