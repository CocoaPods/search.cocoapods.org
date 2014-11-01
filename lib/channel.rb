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
  
  def initialize type
    @type = type
  end
  
  # Start in master.
  #
  def start(children: , worker: )
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
  def choose_channel number
    @channel_number = number
    @to_process = @to_processes[number]
    @from_process = @from_processes[number]
    STDOUT.puts "Child [#{Process.pid}] chose channel #{number} using to: #{@to_process} and from: #{@from_process}."
  end
  
  # This runs a process/thread that listens to child processes.
  #
  def start_process
    process_pid = fork do
      STDOUT.puts "Worker process #{@type} will select on #{@to_processes}."
      
      # Tell worker to setup.
      #
      @worker.setup if @worker.respond_to? :setup
      
      post_process = @worker.respond_to? :post_process
      
      loop do
        # Wait for input from the child for a sub-second.
        #
        received = Cod.select 0.05, @to_processes
        process_channels received if received
  
        # Tell worker to post_process
        #
        @worker.post_process if post_process

        # Fail hard on an error.
        #
      end
    end
    
    Signal.trap('INT') do
      Process.kill('INT', process_pid)
      Process.wait
    end
  end
  
  def process_channels received
    @to_processes.each do |nr, channel|
      if received.has_key? nr
        # STDOUT.puts "Received on #{nr} #{channel}."
        process_channel channel
      end
    end
  end
  
  def process_channel channel
    *args, back_channel = channel.get
    response = @worker.process *args
    back_channel.put response if back_channel
  end

  # Write the worker process,
  # expecting an answer.
  #
  def call action, message
    # STDOUT.puts "Child [#{Process.pid}] calls SE process with #{action}: #{message}."
    @to_process.put [action, message, @from_process] if @to_process
    @from_process.get if @from_process
  end
  
  # Write the worker process,
  # not expecting an answer.
  #
  def notify action, message
    # STDOUT.puts "Child [#{Process.pid}] notifies SE process with #{action}: #{message}."
    @to_process.put [action, message, nil] if @to_process
  end

end