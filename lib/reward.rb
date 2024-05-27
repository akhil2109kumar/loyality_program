class Reward
  attr_accessor :name, :issued_on

  def initialize(name, issued_on)
    @name = name
    @issued_on = issued_on
  end
end
