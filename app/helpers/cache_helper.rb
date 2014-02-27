module CacheHelper
  def ccm_cache(key, competition_id, options={}, &block)
    cache key, ccm_cache_options(competition_id, options), &block
  end

  def ccm_cache_options(competition_id, options={})
    options.reverse_merge! expires_in: 5.minutes, race_condition_ttl: 10
    options[:expires_in] = 1.week if $redis.sismember("past_competition_ids", competition_id)
    options
  end
end
