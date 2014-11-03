class AnalyticsWorker
  def setup
    if defined?(Gabba)
      $stdout.puts "Setting up Gabba for analytics."
      @analytics_counter = 0
      @analytics = create_analytics
    else
      # TODO: We don't need this process.
      # Process.kill 'QUIT', Process.pid
    end
  end

  def process(action, parameters)
    return unless defined?(Gabba)
    case action
    when :event
      self.analytics.event *parameters
    when :page_view
      self.analytics.page_view *parameters
    end
  end

  def create_analytics
    Gabba::Gabba.new('UA-29866548-5', 'cocoapods.org')
  end

  def maybe_reset counter
    @analytics = nil if counter % 100 == 0
  end

  def analytics
    maybe_reset @analytics_counter += 1
    @analytics ||= create_analytics
  end
end
