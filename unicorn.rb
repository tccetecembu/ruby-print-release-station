# Set the working application directory
# working_directory "/path/to/your/app"
working_directory "/var/www/ruby-print-release-station"

# Unicorn PID file location
# pid "/path/to/pids/unicorn.pid"
pid "/var/www/ruby-print-release-station/pids/unicorn.pid"

# Path to logs
# stderr_path "/path/to/logs/unicorn.log"
# stdout_path "/path/to/logs/unicorn.log"
stderr_path "/var/www/ruby-print-release-station/logs/unicorn.log"
stdout_path "/var/www/ruby-print-release-station/logs/unicorn.log"

# Unicorn socket
# listen "/tmp/unicorn.[app name].sock"
listen "/tmp/unicorn.ruby-print-release-station.sock"

# Number of processes
# worker_processes 4
worker_processes 1

# Time-out
timeout 30
