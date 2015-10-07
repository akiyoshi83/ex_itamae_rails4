# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'ex_itamae_rails4'
set :repo_url, 'https://github.com/akiyoshi83/ex_itamae_rails4.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/apps/ex_itamae_rails4'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# デプロイユーザーが変更できるように権限を整理
task 'reset_auth_app' do
  on roles(:app) do
    within deploy_to do
      execute :sudo, :chown, '-R', "app:app ."
      execute :sudo, :chmod, '-R', "g+rwx,o+r ."
    end
  end
end
before 'deploy', 'reset_auth_app'

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  task 'change_owner_app' do
    on roles(:app) do
      within deploy_to do
        execute :sudo, :chown, '-R', "app ."
      end
    end
  end
  after 'deploy', 'change_owner_app'
end

namespace :nginx do
  def do_nginx(command)
    on roles(:web) do
      execute :sudo, :service, :nginx, command
    end
  end

  task 'start' do do_nginx("start") end
  task 'stop' do do_nginx("stop") end
  task 'restart' do do_nginx("restart") end
  task 'configtest' do do_nginx("restart") end
  task 'reopen_logs' do do_nginx("reopen_logs") end
  task 'force_reload' do do_nginx("force-reload") end
  task 'upgrade' do do_nginx("upgrade") end
  task 'reload' do do_nginx("reload") end
  task 'status' do do_nginx("status") end
  task 'status_q' do do_nginx("status_q") end
  task 'condrestart' do do_nginx("condrestart") end
  task 'try_restart' do do_nginx("try-restart") end
end

namespace :unicorn do
  def do_unicorn(command)
    on roles(:app) do
      execute :sudo, :service, :unicorn, command
    end
  end

  task 'start' do do_unicorn(:start) end
  task 'stop' do do_unicorn(:stop) end
  task 'force_stop' do do_unicorn("force-stop") end
  task 'restart' do do_unicorn(:restart) end
  task 'upgrade' do do_unicorn(:upgrade) end
  task 'rotate' do do_unicorn(:rotate) end
end

after 'deploy', 'unicorn:restart'
