class AtomDebugLogger
  def self.log(message, is_debug_mode)
      print message + "\n" if is_debug_mode
  end
end