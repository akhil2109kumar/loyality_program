require 'date'
require_relative '../lib/user'
require_relative '../lib/transaction'
require_relative '../lib/reward'
require_relative '../lib/loyalty_program'

RSpec.describe LoyaltyProgram do
  let(:user) { User.new(1, 'smith', Date.today()) }
  let(:loyalty_program) { LoyaltyProgram.new }

  before do
    loyalty_program.add_user(user)
  end

  describe '#process_transaction' do
    let(:transaction) { Transaction.new(100, Date.new(2024, 5, 26)) }

    it 'adds a transaction to the user' do
      expect { loyalty_program.process_transaction(user, transaction) }.to change { user.transactions.count }.by(1)
    end

    it 'updates user points' do
      expect { loyalty_program.process_transaction(user, transaction) }.to change { user.points }.by(10)
    end
  end

  describe '#evaluate_rewards' do
    let(:transaction1) { Transaction.new(500, Date.new(2024, 5, 1)) }
    let(:transaction2) { Transaction.new(600, Date.new(2024, 5, 10)) }

    it 'gives a Free Coffee reward when user accumulates 100 points in a month' do
      loyalty_program.process_transaction(user, transaction1)
      loyalty_program.process_transaction(user, transaction2)
      expect(user.rewards.map(&:name)).to include('Free Coffee')
    end

    it 'gives a Free Coffee reward during the user\'s birthday month' do
      loyalty_program.process_transaction(user, transaction1)
      expect(user.rewards.map(&:name)).to include('Free Coffee')
      expect(user.issued_rewards["birthday_coffee"]).to be_truthy
    end

    it 'does not give duplicate Free Coffee reward in the same month' do
      transaction1.date =  Date.new(2024, 6, 1)
      transaction2.date =  Date.new(2024, 6, 1)
      loyalty_program.process_transaction(user, transaction1)
      loyalty_program.process_transaction(user, transaction2)
      expect(user.rewards.select { |r| r.name == 'Free Coffee' }.count).to eq(1)
    end
  end

  describe '#quarterly_bonus' do
    let(:transaction) { Transaction.new(3000, Date.new(2024, 2, 1)) }

    it 'gives 100 bonus points for spending more than $2000 in a quarter' do
      loyalty_program.process_transaction(user, transaction)
      expect(user.points).to eq(400)
      expect(user.issued_rewards["quarterly_bonus_2024_Q1"]).to be_truthy
    end

    it 'does not give duplicate quarterly bonus points' do
      loyalty_program.process_transaction(user, transaction)
      loyalty_program.process_transaction(user, transaction)
      expect(user.points).to eq(700) # 2x 3000/100*10 = 600 + 100 once
      expect(user.issued_rewards["quarterly_bonus_2024_Q1"]).to be_truthy
    end
  end

  describe '#evaluate_tiers' do
    let(:transaction) { Transaction.new(5000, Date.new(2024, 1, 1),true) }

    it 'upgrades user to gold tier' do
      loyalty_program.process_transaction(user, transaction)
      expect(user.tier).to eq('gold')
      expect(user.issued_rewards["airport_lounge_access"]).to be_truthy
    end

    it 'does not give duplicate lounge access rewards' do
      loyalty_program.process_transaction(user, transaction)
      loyalty_program.process_transaction(user, transaction)
      expect(user.rewards.select { |r| r.name == '4x Airport Lounge Access' }.count).to eq(1)
    end
  end
end

