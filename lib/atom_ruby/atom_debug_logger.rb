class AtomDebugLogger
  def self.log(message, is_debug_mode)
      p message if is_debug_mode
  end
end