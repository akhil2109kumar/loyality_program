class User
  attr_accessor :id, :name, :points, :transactions, :rewards, :tier, :birthday_date, :first_transaction_date, :issued_rewards

  def initialize(id, name, birthday_date)
    @id = id
    @name = name
    @points = 0
    @transactions = []
    @rewards = []
    @tier = 'standard'
    @birthday_date = birthday_date
    @first_transaction_date = nil
    @issued_rewards = {}
  end

  def add_transaction(transaction)
    @transactions << transaction
    @first_transaction_date ||= transaction.date
  end
end
  