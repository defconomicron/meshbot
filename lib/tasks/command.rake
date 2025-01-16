namespace :command do
  desc 'Pull Down'
  task :pull do
    puts 'Downloading files from server...'
    `rsync -avzhe ssh kd5ef@192.168.1.49:/home/kd5ef/meshbot ~ --copy-links`
  end

  desc 'Push Up'
  task :push do
    print 'Checking integrity...'
    f = IO.popen('ssh kd5ef@192.168.1.49', 'r+')
    f.puts 'cat meshbot/integrity.dat'
    f.close_write
    key1 = f.readlines.last.to_i
    key2 = File.open('integrity.dat', 'rb').read.to_i
    if key1 != key2
      puts "FAILED!: Production code would be overwritten. #{key1} != #{key2}"
      exit
    end
    puts 'PASSED!'
    print 'Uploading files to server...'
    `rsync -avzhe ssh ~/meshbot kd5ef@192.168.1.49:/home/kd5ef --delete`
    puts 'Done!'
    print 'Configuring server...'
    f = IO.popen('ssh kd5ef@192.168.1.49', 'r+')
    f.puts 'sudo rm meshbot/storage/development.sqlite3'
    f.puts 'sudo ln -sf /home/kd5ef/development.sqlite3 /home/kd5ef/meshbot/storage/development.sqlite3'
    f.puts 'sudo chown -R kd5ef:kd5ef /home/kd5ef/meshbot'
    f.puts 'sudo chmod -R 777 /home/kd5ef/meshbot'
    f.puts 'cd meshbot'
    f.puts '/home/kd5ef/.rbenv/shims/bundle'
    f.puts '/home/kd5ef/.rbenv/shims/rake db:migrate'
    f.puts 'pkill -f meshbot'
    sleep 5
    f.puts 'sudo iptables -t nat -D PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 9292'
    f.puts 'sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 9292'
    f.puts '/home/kd5ef/.rbenv/shims/rails s -b 0.0.0.0 -p 9292 -d'
    f.puts "echo #{key1+1} > integrity.dat"
    f.close_write
    puts 'Done!'
    puts 'Server response:'
    puts f.readlines
    File.write('integrity.dat', key2+1)
  end
end
