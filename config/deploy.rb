require 'mongrel_cluster/recipes'

# This defines a deployment "recipe" that you can feed to capistrano
# (http://manuals.rubyonrails.com/read/book/17). It allows you to automate
# (among other things) the deployment of your application.

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The deploy_to path must be the path on each machine that will
# form the root of the application path.

set :application, "content_store"
set :repository, "svn+ssh://robert@app1.streamburst.net/srv/svn/repositories/svnrep/ContentStoreProductionV2"

default_run_options[:pty] = true

# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.

role :web, "app1.streamburst.net", "app3.streamburst.net"
role :app, "app2.streamburst.net", "app3.streamburst.net"
role :db,  "app2.streamburst.net", :primary => true

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
set :deploy_to, "/var/www/content_store" # defaults to "/u/apps/#{application}"
set :mongrel_conf, "#{current_path}/config/mongrel_cluster.yml"

# set :user, "flippy"            # defaults to the currently logged in user
# set :scm, :darcs               # defaults to :subversion
# set :svn, "/path/to/svn"       # defaults to searching the PATH
# set :darcs, "/path/to/darcs"   # defaults to searching the PATH
# set :cvs, "/path/to/cvs"       # defaults to searching the PATH
# set :gateway, "gate.host.com"  # default to no gateway

# =============================================================================
# SSH OPTIONS
# =============================================================================
# ssh_options[:keys] = %w(/path/to/my/key /path/to/another/key)
# ssh_options[:port] = 25

# =============================================================================
# TASKS
# =============================================================================
# Define tasks that run on all (or only some) of the machines. You can specify
# a role (or set of roles) that each task should be executed on. You can also
# narrow the set of servers to a subset of a role by specifying options, which
# must match the options given for the servers to select (like :primary => true)

desc <<DESC
An imaginary backup task. (Execute the 'show_tasks' task to display all
available tasks.)
DESC
task :backup, :roles => :db, :only => { :primary => true } do
  # the on_rollback handler is only executed if this task is executed within
  # a transaction (see below), AND it or a subsequent task fails.
  on_rollback { delete "/tmp/dump.sql" }

  filename = "content_store_production_#{Time.new.strftime("%d%m%y_%H%M%S")}.sql"

  run "mysqldump -u root --force --password=oK4jD9a3 content_store_production > /tmp/#{filename}"
  run "scp /tmp/#{filename} robert@video3.streamburst.tv:#{filename}"
end

# Tasks may take advantage of several different helper methods to interact
# with the remote server(s). These are:
#
# * run(command, options={}, &block): execute the given command on all servers
#   associated with the current task, in parallel. The block, if given, should
#   accept three parameters: the communication channel, a symbol identifying the
#   type of stream (:err or :out), and the data. The block is invoked for all
#   output from the command, allowing you to inspect output and act
#   accordingly.
# * sudo(command, options={}, &block): same as run, but it executes the command
#   via sudo.
# * delete(path, options={}): deletes the given file or directory from all
#   associated servers. If :recursive => true is given in the options, the
#   delete uses "rm -rf" instead of "rm -f".
# * put(buffer, path, options={}): creates or overwrites a file at "path" on
#   all associated servers, populating it with the contents of "buffer". You
#   can specify :mode as an integer value, which will be used to set the mode
#   on the file.
# * render(template, options={}) or render(options={}): renders the given
#   template and returns a string. Alternatively, if the :template key is given,
#   it will be treated as the contents of the template to render. Any other keys
#   are treated as local variables, which are made available to the (ERb)
#   template.

desc "Demonstrates the various helper methods available to recipes."
task :helper_demo do
  # "setup" is a standard task which sets up the directory structure on the
  # remote servers. It is a good idea to run the "setup" task at least once
  # at the beginning of your app's lifetime (it is non-destructive).
  setup

  buffer = render("maintenance.rhtml", :deadline => ENV['UNTIL'])
  put buffer, "#{shared_path}/system/maintenance.html", :mode => 0644
  sudo "killall -USR1 dispatch.fcgi"
  run "#{release_path}/script/spin"
  delete "#{shared_path}/system/maintenance.html"
end

# From http://pmade.com/articles/2006/12/27/mongrel-cluster-and-monit/
# When changing mongrel conf run: mongrel_monit --mongrel=/path/to/mongrel/config --monit=/path/to/monitrc

#desc "Restart the mongrel cluster via monit"
#task :restart_mongrel_cluster, :roles => :app do
#  sudo "monit -g mongrel restart all"
#end

# You can use "transaction" to indicate that if any of the tasks within it fail,
# all should be rolled back (for each task that specifies an on_rollback
# handler).

desc "A task demonstrating the use of transactions."
task :long_deploy do
  transaction do
    update_code
    disable_web
    symlink
    migrate
  end

  restart
  enable_web
end

task :after_setup do
  run "mkdir #{shared_path}/production"
  run "ln -nfs /personalized #{shared_path}/personalized"
  run "ln -nfs /var/www/sugar #{shared_path}/sugar"
end

task :after_symlink do
  # for uploaded files
  run "ln -nfs #{shared_path}/production #{release_path}/public/production"
  # for personalized file access
  run "ln -nfs #{shared_path}/personalized #{release_path}/public/personalized"
  # for sugar
  run "ln -nfs #{shared_path}/sugar #{release_path}/public/sugar"
end

