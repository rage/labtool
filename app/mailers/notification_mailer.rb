class NotificationMailer < ActionMailer::Base

  def email(from, to, body, subject, course="Ohjelmoinnin harjoitustyo")
    from
    subject = "[#{course}] #{subject}"
    @mailbody = body
    mail(:from => from, :to => to, :cc => from, :subject => subject)
    mail(:from => from, :to => to, :subject => subject)
  end

end