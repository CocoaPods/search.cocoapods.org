class Pods
  def initialize
    reset
  end

  def reset
    @cache = {}
  end

  def self.instance
    @instance ||= new
  end

  # Pods are ordered by popularity initially.
  #
  def each(amount = nil, &block)
    order_by_popularity = <<-EXPR
      -1 * (
        github_pod_metrics.stargazers +
        github_pod_metrics.stargazers * 90 +
        github_pod_metrics.stargazers * 20 +
        github_pod_metrics.stargazers * 10
      )
    EXPR
      
    pods = if amount
      Pod.all do |pods|
        pods.
          limit(100).
          order_by(order_by_popularity)
      end
    else
      Pod.all do |pods|
        pods.
          order_by(order_by_popularity)
      end
    end
    if block_given?
      pods.each &block
    else
      pods.each
    end
  end

  def cache_all
    each { |pod| self[pod.id] = pod }
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
    loaded_pods = Pod.all { |pods| pods.where(Domain.pods[:id].in => uncached_ids) }
    loaded_pods.each { |pod| @cache[pod.id] = pod }
    all_ids.map { |id| @cache[id] }
  end
end
