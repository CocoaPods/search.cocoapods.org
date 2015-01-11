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
    STDOUT.puts "Channel [#{@type}] will fork #{children} children."

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
    STDOUT.puts "Child [#{Process.pid}] chose channel #{number} using to: " \
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
        # Wait for input from the child for a sub-second.
        #
        received = Cod.select 0.05, @to_processes

        begin
          process_channels received if received

          # Tell worker to post_process
          #
          @worker.post_process if post_process

        rescue StandardError => e
          # If anything goes wrong in the worker
          # we print and ignore it.
          #
          $stderr.puts e.inspect, e.backtrace
        end
      end
    end

    # On an INT, INT the forked process.
    #
    Signal.trap('INT') do
      Process.wait(process_pid)
    end
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
  def process_channel(channel)
    *args, back_channel = channel.get
    response = @worker.process(*args)
    back_channel.put response if back_channel
  rescue StandardError => e
    # Always return _something_.
    #
    $stderr.puts "Processing #{args} in worker #{@worker} failed: #{e.message}"
    back_channel.put [] if back_channel
  end

  # Write the worker process,
  # expecting an answer.
  #
  def call(action, message)
    @to_process.put [action, message, @from_process] if @to_process
    @from_process.get if @from_process
  end

  # Write the worker process,
  # not expecting an answer.
  #
  def notify(action, message)
    @to_process.put [action, message, nil] if @to_process
  end
end
