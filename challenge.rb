#!/usr/bin/env ruby
# frozen_string_literal: true

# -*- ruby -*-

require 'optparse'
require 'rainbow'
require 'json'

# handle command line arguments
# borrowed from: https://ruby-doc.org/stdlib-2.1.3/libdoc/optparse/rdoc/OptionParser.html
class ChallengeOptParser
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def self.parse(args)
    options = {
      users: 'users.json',
      companies: 'companies.json',
      output: 'output.txt',
      verbose: false
    }

    # rubocop:disable Metrics/BlockLength
    opt_parser = OptionParser.new do |opt|
      opt.banner = 'Usage: challenge.rb [options]'

      opt.separator ''
      opt.separator 'Specific options:'

      opt.on('-u',
             '--users USERS',
             '(Optional) Path to the users json input file',
             '(Default is "users.json")') do |o|
        options.users = o
      end

      opt.on('-c',
             '--companies COMPANIES',
             '(Optional) Path to the companies json input file',
             '(Default is "companies.json")') do |o|
        options.companies = o
      end

      opt.on('-o',
             '--output OUTPUT',
             '(Optional) Path to the output file',
             '(Default is "output.txt")') do |o|
        options.output = o
      end

      opt.on('-v',
             '--[no-]verbose',
             'Run verbosely') do |o|
        options.verbose = o
      end

      opt.separator ''
      opt.separator 'Common options:'

      # No argument, shows at tail.  This will print an options summary.
      # Try it and see!
      opt.on_tail('-h', '--help', 'Show this message') do
        puts opt
        exit
      end
      # rubocop:enable Metrics/BlockLength
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize
    opt_parser.parse!(args)
    options
  end
end

# challenge script to parse and process json data to text output
class Challenge
  def initialize
    @options = ChallengeOptParser.parse(ARGV)
    @data = { users: [], companies: [] }
  end

  def parse_data(users = @options[:users], companies = @options[:companies])
    { users:, companies: }.each do |key, filename|
      file = File.read(filename)
      data = JSON.parse(file)
      @data[key] = data
    rescue Errno::ENOENT
      warn(Rainbow("File '#{filename}' not found").red)
    rescue JSON::ParserError => e
      warn(Rainbow("Error parsing '#{filename}'").red)
      warn(e.message)
    end
  end

  def write_data(filename, contents)
    File.write(filename, contents)
  rescue Errno::EACCES => e
    warn(Rainbow("Error writing '#{filename}'").red)
    warn(e.message)
  end

  def print(companies = @data[:companies], users = @data[:users])
    companies.sort! { |a, b| a['id'] <=> b['id'] }
    companies.map! do |company|
      company_users = users.select { |user| user['company_id'] == company['id'] }
      print_company(company, company_users)
    end.join
  end

  # rubocop:disable Metrics/AbcSize
  def print_company(company, users)
    users.select! { |user| user['active_status'] }
    return "\n" if users.empty?

    out  = "\n\tCompany Id: #{company['id']}\n"
    out << "\tCompany Name: #{company['name']}\n"
    out << "\tUsers Emailed:\n"
    out << print_users(users.select { |u| company['email_status'] && u['email_status'] }, company['top_up'])
    out << "\tUsers Not Emailed:\n"
    out << print_users(users.reject { |u| company['email_status'] && u['email_status'] }, company['top_up'])
    out << "\t\tTotal amount of top ups for #{company['name']}: #{company['top_up'] * users.size}\n"
  end
  # rubocop:enable Metrics/AbcSize

  def print_users(users, top_up)
    users.sort { |a, b| a['last_name'] <=> b['last_name'] }
         .map  { |user| print_user(user, top_up) }.join
  end

  def print_user(user, top_up)
    "\t\t#{user['last_name']}, #{user['first_name']}, #{user['email']}\n" \
      "\t\t  Previous Token Balance, #{user['tokens']}\n" \
      "\t\t  New Token Balance #{user['tokens'] + top_up}\n"
  end

  def run
    parse_data
    output = print
    write_data(@options[:output], output)
  end
end

challenge = Challenge.new
challenge.run
