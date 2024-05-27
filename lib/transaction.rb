class Transaction
  attr_accessor :amount, :date, :foreign_country

  def initialize(amount, date, foreign_country = false)
    @amount = amount
    @date = date
    @foreign_country = foreign_country
  end
end
  