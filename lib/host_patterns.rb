module HostPatterns
  DEFAULT_HOST_PATTERNS = [
    /localhost/,
    /127.0.0.1/,
    /\A[a-z0-9-]+\.app\.github\.dev\z/i,
    /\A[a-z0-9-]+\.gitpod\.dev\z/i,
    /admin\.forms\.service\.gov\.uk/,
    /admin\.[^.]*\.forms\.service\.gov\.uk/,
    /admin\.internal.[^.]*\.forms\.service\.gov\.uk/,
    /pr-[^.]*\.admin\.review\.forms\.service\.gov\.uk/,
    /pr-[^.]*-admin\.submit\.review\.forms\.service\.gov\.uk/,
  ].freeze

  def self.allowed_host_patterns
    additional_patterns = ENV.fetch("ALLOWED_HOST_PATTERNS", "").split(",").map { |pattern| Regexp.new(pattern.strip) }

    [*DEFAULT_HOST_PATTERNS, *additional_patterns]
  end
end
