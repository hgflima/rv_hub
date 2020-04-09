class Transaction < ApplicationRecord

  has_many :status_history, :class_name => "StatusHistory", :foreign_key => "transaction_id", :dependent => :destroy

  validates :carrier, presence: true
  validates :area_code, presence: true
  validates :cell_phone_number, presence: true
  validates :amount, presence: true, numericality: { only_integer: true, greater_than: 0 }

  before_create do
    self.uuid = UUID.new.generate
  end

  state_machine :status, initial: :pending do

    after_transition :to => :authorized,    :do => :after_all_transitions
    after_transition :to => :denied,        :do => :after_all_transitions
    after_transition :to => :captured,      :do => :after_all_transitions
    after_transition :to => :refunded,      :do => :after_all_transitions

    event :authorize! do
      transition :pending => :authorized, :if => :authorize
      transition :pending => :denied
    end

    event :capture! do
      transition :authorized => :captured, :if => :capture
    end

    event :refund! do
      transition :authorized => :refunded, :if => :refund
    end

  end

  def capture
    #puts "confirmando a transacao no cellcard"
    return true
  end

  def refund
    #puts "desfazendo a transacao no cellcard"
    return true
  end

  def authorize
    #puts "efetuando autorizacao no cellcard"
    return true if self.amount <= 10000
    return false
  end

  def after_all_transitions
    #puts "salvando a transacao"
    self.status_history.build(:status => self.status)
    self.save!
  end

end
