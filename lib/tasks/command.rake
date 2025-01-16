namespace :command do
  desc 'Deploy'
  task :deploy do
    puts 'Deploying...'
    f = IO.popen('ssh kd5ef@192.168.1.49', 'r+')
    f.puts 'git -C meshbot pull || git clone https://github.com/defconomicron/meshbot.git'
    f.puts 'sudo chown -R kd5ef:kd5ef /home/kd5ef/meshbot'
    f.puts 'sudo chmod -R 777 /home/kd5ef/meshbot'
    f.puts 'cd meshbot'
    f.puts '/home/kd5ef/.rbenv/shims/bundle'
    f.puts '/home/kd5ef/.rbenv/shims/rake db:migrate'
    f.puts 'pkill -f main.rb'
    sleep 5
    f.puts '/home/kd5ef/.rbenv/shims/ruby main.rb'
    f.close_write
    puts 'Done!'
    puts 'Server response:'
    puts f.readlines
    puts 'Finished deploying!'
  end
end
