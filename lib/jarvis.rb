#!/usr/bin/env ruby

# Resolve symlinks so this works when bin/jarvis is linked or run from anywhere
JARVIS_ROOT = File.expand_path("..", File.dirname(File.realpath(__FILE__)))
ENV['BUNDLE_GEMFILE'] ||= File.join(JARVIS_ROOT, "Gemfile")

require 'bundler'
require 'yaml'

Bundler.require(:default)

$pastel = Pastel.new

module Jarvis

  module OutputHelpers

    def print_line(msg, color = :green)
      puts $pastel.send(color.to_sym, msg)
    end

    def print_error(msg, color = :red)
      puts $pastel.send(color.to_sym, msg)
    end
  end

  module CommandHelpers

    def run_secure_connect_command(type, server, user)
      ip = Jarvis.config['servers'][server]

      if ip.nil?
        print_error "#{server}: server not found in the list"
        exit(1)
      end

      command = "#{type} #{user}@#{ip}"

      begin
        print_line "Running: #{command} use Password: #{Jarvis.config['dev_password']} for dev"
        system(command)
      rescue => ex
        print_error ex.message
      end
    end

    def histogram(label, n, max=100)
      max = max < 100 ? 100 : max
      count = (n/max.to_f)*100
      count = 1 if count < 1
      str = "*" * count
      [label, n, "#{str} #{n}"].join("\t")
    end
  end

  class Jarvis < Thor
    def self.config
      @config ||= YAML.load(File.read(File.join(JARVIS_ROOT, "config.yml")))
    end

    no_commands do
      include OutputHelpers
      include CommandHelpers
    end

    desc "hello", "Say hello to Jarvis"
    def hello
      print_line "Hello! Jarvis at your service. Need some help? Just call help.", :yellow
      progress = ProgressBar.create
      50.times { progress.increment; sleep 0.1 }
    end

    desc "servers", "List servers"
    def servers
      require 'terminal-table'
      rows = Jarvis.config['servers'].to_a
      table = Terminal::Table.new(:title => "Server List", :headings => ['Name', 'IP'], :rows => rows)
      table.align_column(1, :right)
      puts table
    end

    desc "ssh SERVER [USER]", "SSH to a server (default user: dev)"
    def ssh(server, user='dev')
      run_secure_connect_command("ssh", server, user)
    end

    desc "sftp SERVER [USER]", "SFTP to a server (default user: dev)"
    def sftp(server, user='dev')
      run_secure_connect_command("sftp", server, user)
    end

    desc "start SERVICE", "Start a service (server, mongodb, redis, vm)"
    def start(name)
      case name
      when 'server' then
        command = "ruby -run -e httpd -- -p 5000 ."
        print_line "Running #{command}"
        system(command)
      when 'mongodb' then
        command = "mongod --journal --fork --logpath=/dev/null"
        print_line "Starting mongodb server"
        print_line "Running #{command}"
        system(command)
      when 'redis'
        command = "redis-server ~/.env/conf/redis.conf"
        print_line "Starting redis server"
        print_line "Running #{command}"
        system(command)
      when 'vm', 'tm'
        command = "VBoxManage startvm turingmachine --type headless"
        print_line "Starting VirtualBox loading turingmachine"
        print_line "Running #{command}"
        system(command)
      else
        print_line "Teach me how to start #{name}, I will do it next time."
      end
    end

    desc "scan HOSTNAME [RANGE]", "Scan a host or subnet with nmap"
    def scan(hostname, range=0)
      command = "nmap -n -sP #{hostname}/#{range}"
      system(command)
    end

    desc "commits", "View commit histogram by date"
    def commits
      command = 'git log --date=short | grep Date: | cut -d " " -f4 | uniq -c'
      result = IO.popen(command).read
      lines = result.split("\n")
      max = lines.map { |line| line.split.first.to_i }.max

      puts max

      lines.each do |line|
        label, count = line.split.reverse
        print_line histogram(label, count.to_i, max), :cyan
      end
    end

    desc "authors_commits", "View commit histogram by author"
    def authors_commits
      command = 'git log | grep Author: |  cut -d "<" -f2 | cut -d "@" -f1 | sort | uniq -c'
      result = IO.popen(command).read
      lines = result.split("\n")
      max = lines.map { |line| line.split.first.to_i }.max

      to_name = Proc.new do |name|
        name.gsub(/\W/, " ").strip.split.map(&:capitalize).join(" ")
      end

      lines.each do |line|
        label, count = line.split.reverse
        print_line histogram(to_name.call(label).ljust(30), count.to_i, max), :cyan
      end
    end
  end
end

$PROGRAM_NAME = "jarvis" # shown in Thor's help output
Jarvis::Jarvis.start(ARGV)
