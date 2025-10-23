
class Notifier
  def initialize(adapter)
    @adapter = adapter
  end

  def notify(message)
    @adapter.deliver(message)
  end
end

class EmailAdapter
  def deliver(message)
    puts "Email відправлено: #{message}"
  end
end


class SlackAdapter
  def deliver(message)
    puts "Slack повідомлення відправлено: #{message}"
  end
end


email_adapter = EmailAdapter.new
slack_adapter = SlackAdapter.new

notifier1 = Notifier.new(email_adapter)
notifier2 = Notifier.new(slack_adapter)

notifier1.notify("Привіт1 Email!")
notifier2.notify("Привіт2 Slack!")
