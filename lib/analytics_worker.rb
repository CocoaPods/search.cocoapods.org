class AnalyticsWorker
  def setup
    if defined?(Gabba)
      $stdout.puts "Setting up Gabba for analytics."
      @analytics_counter = 0
      @analytics = maybe_create
    else
      # TODO: We don't need this process.
      # Process.kill 'QUIT', Process.pid
    end
  end

  def process(action, parameters)
    return unless defined?(Gabba)
    case action
    when :event
      analytics.event *parameters
    when :page_view
      analytics.page_view *parameters
    end
  end

  private

  def maybe_create(counter = 0)
    Gabba::Gabba.new('UA-29866548-5', 'cocoapods.org') if counter % 100 == 0
  end

  def analytics
    @analytics = maybe_create @analytics_counter || 0
    @analytics_counter += 1
    @analytics
  end
end
