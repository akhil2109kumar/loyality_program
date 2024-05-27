require_relative 'user'
require_relative 'transaction'
require_relative 'reward'

class LoyaltyProgram
  attr_accessor :users

  def initialize
    @users = []
  end

  def add_user(user)
    @users << user
  end

  def process_transaction(user, transaction)
    user.add_transaction(transaction)
    points = calculate_points(transaction)
    user.points += points
    evaluate_rewards(user, transaction.date)
    evaluate_tiers(user)
    quarterly_bonus(user, transaction.date)

    if transaction.date.month != user.birthday_date.month
      user.issued_rewards['birthday_coffee'] = false
    end
  end

  def calculate_points(transaction)
    points = (transaction.amount / 100).to_i * 10
    points *= 2 if transaction.foreign_country
    points
  end

  def evaluate_rewards(user,date)
    current_month_transactions = user.transactions.select { |t| t.date.month == date.month }
    current_month_points = current_month_transactions.sum { |t| calculate_points(t) }

    if current_month_points >= 100
      unless user.issued_rewards["monthly_coffee_#{date.year}_#{date.month}"]
        user.rewards << Reward.new('Free Coffee', date)
        user.issued_rewards["monthly_coffee_#{date.year}_#{date.month}"] = true
      end
    end

    if date.month == user.birthday_date.month
      unless user.issued_rewards['birthday_coffee']
        user.rewards << Reward.new('Free Coffee', date)
        user.issued_rewards['birthday_coffee'] = true
      end
    end

    high_value_transactions = user.transactions.select { |t| t.amount > 100 }.count

    if high_value_transactions >= 10 && !user.issued_rewards['cash_rebate']
      user.rewards << Reward.new('5% Cash Rebate', date)
      user.issued_rewards['cash_rebate'] = true
    end

    if user.transactions.sum(&:amount) > 1000 && (date - user.first_transaction_date).to_i <= 60 && !user.issued_rewards['movie_tickets']
      user.rewards << Reward.new('Free Movie Tickets', date)
      user.issued_rewards['movie_tickets'] = true
    end
  end

  def evaluate_tiers(user)
    highest_points_in_last_two_years = [user.points, calculate_points_last_two_years(user)].max

    case highest_points_in_last_two_years
    when 0..999
      user.tier = 'standard'
    when 1000..4999
      user.tier = 'gold'
      unless user.issued_rewards['airport_lounge_access']
        user.rewards << Reward.new('4x Airport Lounge Access', Time.now)
        user.issued_rewards['airport_lounge_access'] = true
      end
    else
      user.tier = 'platinum'
    end
  end

  def calculate_points_last_two_years(user)
    user.transactions.select { |t| (Time.now.year - t.date.year) <= 2 }.sum { |t| calculate_points(t) }
  end

  def quarterly_bonus(user, date)
    start_date, end_date = quarter_date_range(date)
    quarterly_spending = user.transactions.select { |t| t.date >= start_date && t.date <= end_date }.sum(&:amount)

    if quarterly_spending > 2000
      quarter_key = "quarterly_bonus_#{start_date.year}_Q#{(start_date.month - 1) / 3 + 1}"
      unless user.issued_rewards[quarter_key]
        user.points += 100
        user.issued_rewards[quarter_key] = true
      end
    end
  end
  
  def quarter_date_range(date)
    case (date.month - 1) / 3
    when 0
      start_date = Date.new(date.year, 1, 1)
      end_date = Date.new(date.year, 3, 31)
    when 1
      start_date = Date.new(date.year, 4, 1)
      end_date = Date.new(date.year, 6, 30)
    when 2
      start_date = Date.new(date.year, 7, 1)
      end_date = Date.new(date.year, 9, 30)
    when 3
      start_date = Date.new(date.year, 10, 1)
      end_date = Date.new(date.year, 12, 31)
    end
    [start_date, end_date]
  end
end