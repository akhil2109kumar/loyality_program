require "date"
require_relative "lib/loyalty_program"

# Create a new LoyaltyProgram instance
loyalty_program = LoyaltyProgram.new

# Create a new user and add them to the loyalty program
user = User.new(1, "John", Date.new(1990, 5, 15))  # Example: User with ID 1, name John, birthday May 15, 1990
loyalty_program.add_user(user)
puts "User #{user.name} added to the loyalty program."

transactions = [
  Transaction.new(150, Date.today),                   # Example: Transaction of $150 today
  Transaction.new(200, Date.today - 1),               # Example: Transaction of $200 yesterday
  Transaction.new(1000, Date.new(2024, 5, 1)),        # Example: Transaction of $1000 on May 1, 2024
  Transaction.new(75, Date.today - 10),               # Example: Transaction of $75 ten days ago
  Transaction.new(250, Date.today, true),             # Example: Foreign country transaction of $250 today
  Transaction.new(400, Date.today - 2, true)          # Example: Foreign country transaction of $400 two days ago
]

transactions.each do |transaction|
  loyalty_program.process_transaction(user, transaction)
  puts "Transaction processed: $#{transaction.amount} on #{transaction.date}"
end

# Check user's current points and rewards
puts "User #{user.name}'s current points: #{user.points}"
puts "User #{user.name}'s current rewards: #{user.rewards.map(&:name)}"
