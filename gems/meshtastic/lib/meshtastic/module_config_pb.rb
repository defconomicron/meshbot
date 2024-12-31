# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: meshtastic/module_config.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("meshtastic/module_config.proto", :syntax => :proto3) do
    add_message "meshtastic.ModuleConfig" do
      oneof :payload_variant do
        optional :mqtt, :message, 1, "meshtastic.ModuleConfig.MQTTConfig"
        optional :serial, :message, 2, "meshtastic.ModuleConfig.SerialConfig"
        optional :external_notification, :message, 3, "meshtastic.ModuleConfig.ExternalNotificationConfig"
        optional :store_forward, :message, 4, "meshtastic.ModuleConfig.StoreForwardConfig"
        optional :range_test, :message, 5, "meshtastic.ModuleConfig.RangeTestConfig"
        optional :telemetry, :message, 6, "meshtastic.ModuleConfig.TelemetryConfig"
        optional :canned_message, :message, 7, "meshtastic.ModuleConfig.CannedMessageConfig"
        optional :audio, :message, 8, "meshtastic.ModuleConfig.AudioConfig"
        optional :remote_hardware, :message, 9, "meshtastic.ModuleConfig.RemoteHardwareConfig"
        optional :neighbor_info, :message, 10, "meshtastic.ModuleConfig.NeighborInfoConfig"
        optional :ambient_lighting, :message, 11, "meshtastic.ModuleConfig.AmbientLightingConfig"
        optional :detection_sensor, :message, 12, "meshtastic.ModuleConfig.DetectionSensorConfig"
        optional :paxcounter, :message, 13, "meshtastic.ModuleConfig.PaxcounterConfig"
      end
    end
    add_message "meshtastic.ModuleConfig.MQTTConfig" do
      optional :enabled, :bool, 1
      optional :address, :string, 2
      optional :username, :string, 3
      optional :password, :string, 4
      optional :encryption_enabled, :bool, 5
      optional :json_enabled, :bool, 6
      optional :tls_enabled, :bool, 7
      optional :root, :string, 8
      optional :proxy_to_client_enabled, :bool, 9
      optional :map_reporting_enabled, :bool, 10
      optional :map_report_settings, :message, 11, "meshtastic.ModuleConfig.MapReportSettings"
    end
    add_message "meshtastic.ModuleConfig.MapReportSettings" do
      optional :publish_interval_secs, :uint32, 1
      optional :position_precision, :uint32, 2
    end
    add_message "meshtastic.ModuleConfig.RemoteHardwareConfig" do
      optional :enabled, :bool, 1
      optional :allow_undefined_pin_access, :bool, 2
      repeated :available_pins, :message, 3, "meshtastic.RemoteHardwarePin"
    end
    add_message "meshtastic.ModuleConfig.NeighborInfoConfig" do
      optional :enabled, :bool, 1
      optional :update_interval, :uint32, 2
    end
    add_message "meshtastic.ModuleConfig.DetectionSensorConfig" do
      optional :enabled, :bool, 1
      optional :minimum_broadcast_secs, :uint32, 2
      optional :state_broadcast_secs, :uint32, 3
      optional :send_bell, :bool, 4
      optional :name, :string, 5
      optional :monitor_pin, :uint32, 6
      optional :detection_triggered_high, :bool, 7
      optional :use_pullup, :bool, 8
    end
    add_message "meshtastic.ModuleConfig.AudioConfig" do
      optional :codec2_enabled, :bool, 1
      optional :ptt_pin, :uint32, 2
      optional :bitrate, :enum, 3, "meshtastic.ModuleConfig.AudioConfig.Audio_Baud"
      optional :i2s_ws, :uint32, 4
      optional :i2s_sd, :uint32, 5
      optional :i2s_din, :uint32, 6
      optional :i2s_sck, :uint32, 7
    end
    add_enum "meshtastic.ModuleConfig.AudioConfig.Audio_Baud" do
      value :CODEC2_DEFAULT, 0
      value :CODEC2_3200, 1
      value :CODEC2_2400, 2
      value :CODEC2_1600, 3
      value :CODEC2_1400, 4
      value :CODEC2_1300, 5
      value :CODEC2_1200, 6
      value :CODEC2_700, 7
      value :CODEC2_700B, 8
    end
    add_message "meshtastic.ModuleConfig.PaxcounterConfig" do
      optional :enabled, :bool, 1
      optional :paxcounter_update_interval, :uint32, 2
    end
    add_message "meshtastic.ModuleConfig.SerialConfig" do
      optional :enabled, :bool, 1
      optional :echo, :bool, 2
      optional :rxd, :uint32, 3
      optional :txd, :uint32, 4
      optional :baud, :enum, 5, "meshtastic.ModuleConfig.SerialConfig.Serial_Baud"
      optional :timeout, :uint32, 6
      optional :mode, :enum, 7, "meshtastic.ModuleConfig.SerialConfig.Serial_Mode"
      optional :override_console_serial_port, :bool, 8
    end
    add_enum "meshtastic.ModuleConfig.SerialConfig.Serial_Baud" do
      value :BAUD_DEFAULT, 0
      value :BAUD_110, 1
      value :BAUD_300, 2
      value :BAUD_600, 3
      value :BAUD_1200, 4
      value :BAUD_2400, 5
      value :BAUD_4800, 6
      value :BAUD_9600, 7
      value :BAUD_19200, 8
      value :BAUD_38400, 9
      value :BAUD_57600, 10
      value :BAUD_115200, 11
      value :BAUD_230400, 12
      value :BAUD_460800, 13
      value :BAUD_576000, 14
      value :BAUD_921600, 15
    end
    add_enum "meshtastic.ModuleConfig.SerialConfig.Serial_Mode" do
      value :DEFAULT, 0
      value :SIMPLE, 1
      value :PROTO, 2
      value :TEXTMSG, 3
      value :NMEA, 4
      value :CALTOPO, 5
    end
    add_message "meshtastic.ModuleConfig.ExternalNotificationConfig" do
      optional :enabled, :bool, 1
      optional :output_ms, :uint32, 2
      optional :output, :uint32, 3
      optional :output_vibra, :uint32, 8
      optional :output_buzzer, :uint32, 9
      optional :active, :bool, 4
      optional :alert_message, :bool, 5
      optional :alert_message_vibra, :bool, 10
      optional :alert_message_buzzer, :bool, 11
      optional :alert_bell, :bool, 6
      optional :alert_bell_vibra, :bool, 12
      optional :alert_bell_buzzer, :bool, 13
      optional :use_pwm, :bool, 7
      optional :nag_timeout, :uint32, 14
      optional :use_i2s_as_buzzer, :bool, 15
    end
    add_message "meshtastic.ModuleConfig.StoreForwardConfig" do
      optional :enabled, :bool, 1
      optional :heartbeat, :bool, 2
      optional :records, :uint32, 3
      optional :history_return_max, :uint32, 4
      optional :history_return_window, :uint32, 5
    end
    add_message "meshtastic.ModuleConfig.RangeTestConfig" do
      optional :enabled, :bool, 1
      optional :sender, :uint32, 2
      optional :save, :bool, 3
    end
    add_message "meshtastic.ModuleConfig.TelemetryConfig" do
      optional :device_update_interval, :uint32, 1
      optional :environment_update_interval, :uint32, 2
      optional :environment_measurement_enabled, :bool, 3
      optional :environment_screen_enabled, :bool, 4
      optional :environment_display_fahrenheit, :bool, 5
      optional :air_quality_enabled, :bool, 6
      optional :air_quality_interval, :uint32, 7
      optional :power_measurement_enabled, :bool, 8
      optional :power_update_interval, :uint32, 9
      optional :power_screen_enabled, :bool, 10
    end
    add_message "meshtastic.ModuleConfig.CannedMessageConfig" do
      optional :rotary1_enabled, :bool, 1
      optional :inputbroker_pin_a, :uint32, 2
      optional :inputbroker_pin_b, :uint32, 3
      optional :inputbroker_pin_press, :uint32, 4
      optional :inputbroker_event_cw, :enum, 5, "meshtastic.ModuleConfig.CannedMessageConfig.InputEventChar"
      optional :inputbroker_event_ccw, :enum, 6, "meshtastic.ModuleConfig.CannedMessageConfig.InputEventChar"
      optional :inputbroker_event_press, :enum, 7, "meshtastic.ModuleConfig.CannedMessageConfig.InputEventChar"
      optional :updown1_enabled, :bool, 8
      optional :enabled, :bool, 9
      optional :allow_input_source, :string, 10
      optional :send_bell, :bool, 11
    end
    add_enum "meshtastic.ModuleConfig.CannedMessageConfig.InputEventChar" do
      value :NONE, 0
      value :UP, 17
      value :DOWN, 18
      value :LEFT, 19
      value :RIGHT, 20
      value :SELECT, 10
      value :BACK, 27
      value :CANCEL, 24
    end
    add_message "meshtastic.ModuleConfig.AmbientLightingConfig" do
      optional :led_state, :bool, 1
      optional :current, :uint32, 2
      optional :red, :uint32, 3
      optional :green, :uint32, 4
      optional :blue, :uint32, 5
    end
    add_message "meshtastic.RemoteHardwarePin" do
      optional :gpio_pin, :uint32, 1
      optional :name, :string, 2
      optional :type, :enum, 3, "meshtastic.RemoteHardwarePinType"
    end
    add_enum "meshtastic.RemoteHardwarePinType" do
      value :UNKNOWN, 0
      value :DIGITAL_READ, 1
      value :DIGITAL_WRITE, 2
    end
  end
end

module Meshtastic
  ModuleConfig = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("meshtastic.ModuleConfig").msgclass
  ModuleConfig::MQTTConfig = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("meshtastic.ModuleConfig.MQTTConfig").msgclass
  ModuleConfig::MapReportSettings = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("meshtastic.ModuleConfig.MapReportSettings").msgclass
  ModuleConfig::RemoteHardwareConfig = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("meshtastic.ModuleConfig.RemoteHardwareConfig").msgclass
  ModuleConfig::NeighborInfoConfig = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("meshtastic.ModuleConfig.NeighborInfoConfig").msgclass
  ModuleConfig::DetectionSensorConfig = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("meshtastic.ModuleConfig.DetectionSensorConfig").msgclass
  ModuleConfig::AudioConfig = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("meshtastic.ModuleConfig.AudioConfig").msgclass
  ModuleConfig::AudioConfig::Audio_Baud = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("meshtastic.ModuleConfig.AudioConfig.Audio_Baud").enummodule
  ModuleConfig::PaxcounterConfig = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("meshtastic.ModuleConfig.PaxcounterConfig").msgclass
  ModuleConfig::SerialConfig = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("meshtastic.ModuleConfig.SerialConfig").msgclass
  ModuleConfig::SerialConfig::Serial_Baud = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("meshtastic.ModuleConfig.SerialConfig.Serial_Baud").enummodule
  ModuleConfig::SerialConfig::Serial_Mode = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("meshtastic.ModuleConfig.SerialConfig.Serial_Mode").enummodule
  ModuleConfig::ExternalNotificationConfig = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("meshtastic.ModuleConfig.ExternalNotificationConfig").msgclass
  ModuleConfig::StoreForwardConfig = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("meshtastic.ModuleConfig.StoreForwardConfig").msgclass
  ModuleConfig::RangeTestConfig = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("meshtastic.ModuleConfig.RangeTestConfig").msgclass
  ModuleConfig::TelemetryConfig = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("meshtastic.ModuleConfig.TelemetryConfig").msgclass
  ModuleConfig::CannedMessageConfig = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("meshtastic.ModuleConfig.CannedMessageConfig").msgclass
  ModuleConfig::CannedMessageConfig::InputEventChar = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("meshtastic.ModuleConfig.CannedMessageConfig.InputEventChar").enummodule
  ModuleConfig::AmbientLightingConfig = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("meshtastic.ModuleConfig.AmbientLightingConfig").msgclass
  RemoteHardwarePin = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("meshtastic.RemoteHardwarePin").msgclass
  RemoteHardwarePinType = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("meshtastic.RemoteHardwarePinType").enummodule
end
