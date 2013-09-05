module ETLExampleGroup
  extend ActiveSupport::Concern

  included do
    metadata[:type] = :etl

    # Always clear the cache before a spec
    before { ETLCache.sweep_resolvers! }
  end
end
