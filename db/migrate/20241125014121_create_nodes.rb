class CreateNodes < ActiveRecord::Migration[7.2]
  def change
    # {:packet=>{:from=>2718567960, :to=>4294967295, :channel=>8, :id=>811365352, :rx_time=>1732492223, :rx_snr=>-18.75, :hop_limit=>0, :want_ack=>false, :priority=>:UNSET, :rx_rssi=>-128, :delayed=>:NO_DELAY, :via_mqtt=>false, :hop_start=>0, :decoded=>{:portnum=>:NODEINFO_APP, :payload=>{:id=>"!a20a0e18", :long_name=>"OKC Downtown SR", :short_name=>"ODS", :macaddr=>"cc:8d:a2:0a:0e:18", :hw_model=>:STATION_G2, :is_licensed=>false, :role=>:CLIENT}, :want_response=>false, :dest=>0, :source=>0, :request_id=>0, :reply_id=>0, :emoji=>0}, :encrypted=>:decrypted, :topic=>"msh/US/OK/2/e/LongFast/!da5cc71c", :node_id_from=>"!a20a0e18", :node_id_to=>"!ffffffff", :rx_time_utc=>"2024-11-24 23:50:23 UTC"}, :channel_id=>"LongFast", :gateway_id=>"!da5cc71c"}
    create_table :nodes do |t|
      t.string :number
      t.string :long_name
      t.string :short_name
      t.string :macaddr
      t.string :hw_model
      t.string :node_id_from
      t.text :nodeinfo_snapshot
      t.text :user_snapshot
      t.text :telemetry_snapshot
      t.text :position_snapshot
      t.text :device_metrics_snapshot
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :ignored_at
    end
  end
end
