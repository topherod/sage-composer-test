# config valid only for current version of Capistrano
require 'json'
lock '3.6.1'

set :scm, :git
set :application, 'hcp200'
set :repo_url, 'git@github.com:HarperCollins/hcp200.git'


set :deploy_via, :remote_cache

set :linked_files, ['.htaccess']
set :linked_dirs, ['wp-content/uploads']


task :set_branch_stage do
  if fetch(:stage) == :staging
	set :branch, fetch(:stage)
  else
	set :branch, 'master'
  end

  set :deploy_to, "/var/www/#{fetch(:application)}"
end

before :deploy, :set_branch_stage

namespace :deploy do

    desc 'Download core and update plugins'
    task :plugin_core do
        on roles(:app) do
            execute "cd #{release_path} && wp core download && composer install"
            execute "ln -s #{shared_path}/wp-config.php #{release_path}/wp-config.php"
        end
    end

    after 'updated', 'plugin_core'

    namespace :check do
        task :touch_files do
            on roles(:app) do
                fetch(:linked_files).each { |x| execute "cd #{shared_path} && touch #{x}" }
            end
        end
        before 'linked_files', 'touch_files'
    end
end
