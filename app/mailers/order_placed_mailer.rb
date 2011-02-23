class OrderPlacedMailer < ActionMailer::Base
  default :from => "mailer@premierorders.net"
  helper :jobs

  def order_placed_email(job)
    @job = job
    mail(:to => @job.primary_contact.email,
         :bcc => 'customerservice@premiergarage.com',
         :reply_to => 'customerservice@premiergarage.com',
         :subject => "Your order \"#{job.name}\" has been placed.")
  end
end
