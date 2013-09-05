# Simple cache for ETL stuff
module ETLCache
  extend self

  def resolvers
    Thread.current[:etl_engine_resolvers] ||= {}
  end

  def sweep_resolvers!
    Thread.current[:etl_engine_resolvers] = nil
  end
end
