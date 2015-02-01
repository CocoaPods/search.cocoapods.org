class Pods
  def initialize
    reset
  end

  def reset
    @cache = GoogleHashSparseLongToRuby.new
  end

  def self.instance
    @instance ||= new
  end

  # Pods are ordered by popularity initially.
  #
  def each(amount = nil, &block)
    order_by_popularity = <<-EXPR
      -1 * (
        github_pod_metrics.contributors * 90 +
        github_pod_metrics.subscribers * 20 +
        github_pod_metrics.forks * 10 +
        github_pod_metrics.stargazers
      )
    EXPR

    pods = Pod.all do |all_pods|
      all_pods.order_by(order_by_popularity)
      all_pods.limit(amount) if amount
      all_pods
    end
    if block_given?
      pods.each(&block)
    else
      pods.each
    end
  end

  def cache_all
    each do |pod|
      self[pod.id] = pod
      pod.reduce_memory_usage
    end
    GC.start
  end

  def [](id)
    @cache[id]
  end

  def []=(id, pod)
    @cache[id] = pod
  end

  # Load the ids, also uses a cache.
  #
  def for(all_ids)
    uncached_ids = all_ids.reject { |id| @cache[id] }
    loaded_pods = Pod.all do |pods|
      pods.where(Domain.pods[:id].in => uncached_ids)
    end
    loaded_pods.each { |pod| @cache[pod.id] = pod }
    all_ids.map { |id| @cache[id] }
  rescue PG::UnableToSend
    STDOUT.puts 'PG::UnableToSend raised! Reconnecting to database.'
    load 'lib/database.rb'
    retry
  end
end
