class NotificationMailer < ActionMailer::Base

  def email(from, to, body, subject, cc, course="Ohjelmoinnin harjoitustyo")
    from
    subject = "[#{course}] #{subject}"
    @mailbody = body
    if cc
      mail(:from => from, :to => to, :cc => from, :subject => subject)
    else
      mail(:from => from, :to => to, :subject => subject)
    end
  end

end