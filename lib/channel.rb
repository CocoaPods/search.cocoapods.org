# frozen_string_literal: true
require 'cod'
require 'hashie/mash'

# This Channel connects the web worker processes with
# a worker process.
#
class Channel
  class << self
    attr_accessor :channels
    def instance(type)
      channels[type] ||= new(type)
    end
  end
  self.channels = {}

  def initialize(type)
    @type = type
  end

  # Start in master.
  #
  def start(children:, worker:)
    $stdout.puts "Channel [#{@type}] will fork #{children} children."

    @amount_of_children = children
    @to_processes = children.times.inject({}) do |engines, i|
      engines.tap { |e| e[i] = Cod.pipe }
    end
    @from_processes = children.times.inject({}) do |engines, i|
      engines.tap { |e| e[i] = Cod.pipe }
    end

    @worker = worker.new

    start_process
  end

  # Choose a channel in child.
  #
  def choose_channel(number)
    @channel_number = number
    @to_process = @to_processes[number]
    @from_process = @from_processes[number]
    
    $stdout.puts "Child [#{Process.pid}] chose channel #{number} using to: " \
      "#{@to_process} and from: #{@from_process}."
  end

  # This forks a process/thread that listens to child processes.
  #
  # Call this method only in master.
  #
  def start_process
    process_pid = fork do
      $stdout.puts "Worker process #{@type} will select on #{@to_processes}."

      # Tell worker to setup.
      #
      @worker.setup if @worker.respond_to? :setup

      post_process = @worker.respond_to? :post_process

      loop do
        begin
          # Wait for input from the child for a sub-second.
          #
          received = Cod.select 0.05, @to_processes

          #
          #
          process_channels received if received

          # Tell worker to post_process
          #
          @worker.post_process if post_process
        rescue StandardError => e
          # If anything goes wrong we print and ignore it.
          #
          $stderr.puts "[Warning] #{e.inspect}, #{e.backtrace}"
        end
      end
    end

    # On an INT, INT the forked process.
    #
    Signal.trap('INT') do
      Process.wait(process_pid)
    end
  rescue StandardError => e
    # Always return _something_.
    #
    $stderr.puts "[Warning] Calling #{action} with #{message} failed: #{e.message}"
    back_channel.put [] if back_channel
  end

  # Check which channels have received something.
  #
  def process_channels(received)
    @to_processes.each do |nr, channel|
      if received.key? nr
        process_channel channel
      end
    end
  end

  # Process a specific channel.
  # Only answer if a back_channel is passed in.
  #
  # It simply returns the timestamp it gets from the channel.
  #
  def process_channel(channel)
    timestamp, action, message, back_channel = channel.get
    response = @worker.process(action, message)
    back_channel.put [timestamp, response] if back_channel
  rescue StandardError => e
    # Always return _something_.
    #
    $stderr.puts "[Warning] Processing #{channel} in worker #{@worker} failed: #{e.message}"
    back_channel.put [] if back_channel
  end

  # Write the worker process,
  # expecting an answer.
  #
  # This checks if the timestamp is the one we sent.
  # If not, discard the response.
  #
  def call(action, message)
    timestamp = Time.now
    @to_process.put [timestamp, action, message, @from_process] if @to_process
    if @from_process
      response_timestamp = 0
      # The response timestamp can never be larger than the timestamp.
      # Therefore we can discard until we get "our" answer.
      # We assume that the search process will eventually answer.
      # -> This is optimistic code ;)
      until response_timestamp == timestamp
        response_timestamp, response = @from_process.get
      end
      response
    end
  rescue StandardError => e
    $stderr.puts "[Warning] Calling #{action} with #{message} failed: #{e.message}"
  end

  # Write the worker process,
  # not expecting an answer.
  #
  def notify(action, message)
    @to_process.put [nil, action, message, nil] if @to_process
  rescue StandardError => e
    $stderr.puts "[Warning] Notifying #{action} with #{message} failed: #{e.message}"
  end
end
