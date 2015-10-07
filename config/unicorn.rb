# http://qiita.com/PallCreaker/items/46eb7171f1eb2c3d77cf

APP_ROOT = "/var/apps/ex_itamae_rails4/current"
APP_NAME = "ex_itamae_rails4"
TMP_DIR = "#{APP_ROOT}/tmp"
SOCK_PATH = "#{TMP_DIR}/sockets/#{APP_NAME}-unicorn.sock"

worker_processes Integer(ENV["UNICORN_PROCESSES"] || 2)
working_directory APP_ROOT

stderr_path File.expand_path('log/unicorn.stderr.log', APP_ROOT)
stdout_path File.expand_path('log/unicorn.stdout.log', APP_ROOT)

listen SOCK_PATH
user 'app', 'app'

preload_app true

GC.respond_to?(:copy_on_write_friendly=) and GC.copy_on_write_friendly = true

# http://ikm.hatenablog.jp/entry/2013/06/27/164942
before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = File.expand_path('Gemfile', APP_ROOT)
end

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!

  old_pid = "#{ server.config[:pid] }.oldbin"
  unless old_pid == server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill sig, File.read(old_pid).to_i
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end


