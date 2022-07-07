class CalculateRest
  attr_accessor :final_date

  def initialize(final_date:)
    @final_date = final_date
  end

  def rest
    "days: #{days}, hours: #{hours}, minutes: #{minutes}, seconds: #{seconds} ☺️"
  end

  private

  def days
    (rest_in_seconds / seconds_in_day) - 1
  end

  def hours
    rest_in_seconds / 3600 % 24
  end

  def minutes
    rest_in_seconds / 60 % 60
  end

  def seconds
    rest_in_seconds % 60
  end

  def rest_in_seconds
    (final_date - start_date).to_i
  end

  def start_date
    Time.new
  end

  def seconds_in_day
    86400
  end
end
