class AtomDebugLogger
  def self.log (message, is_debug_mode)
    if is_debug_mode
      puts (message)
    end
  end
end