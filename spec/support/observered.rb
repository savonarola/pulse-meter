class ObservedDummy
  attr_reader :count
  @@count = 0

  def initialize
    @count = 0
  end

  def incr(value = 1, &proc)
    Timecop.travel(Time.now + 1)
    @count += value
    @count += proc.call if proc
    @count
  end

  def error
    raise RuntimeError
  end

  class << self
    def count
      @@count
    end

    def reset
      @@count = 0
    end

    def incr(value = 1, &proc)
      Timecop.travel(Time.now + 1)
      @@count += value
      @@count += proc.call if proc
      @@count
    end

    def error
      raise RuntimeError
    end
  end
end