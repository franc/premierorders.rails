class OrderMailer < ActionMailer::Base
  default :from => "mailer@premierorders.net"
  helper :jobs

  def order_placed_email(job)
    @job = job
    mail(:to => @job.franchisee.primary_contact.email,
         :bcc => 'customerservice@premiergarage.com',
         :reply_to => 'customerservice@premiergarage.com',
         :subject => "Your PremierGarage order \"#{job.name}\" has been placed.")
  end

  def order_shipped_email(job)
    @job = job
    mail(:to => @job.franchisee.primary_contact.email,
         :bcc => 'customerservice@premiergarage.com',
         :reply_to => 'customerservice@premiergarage.com',
         :subject => "Your PremierGarage order \"#{job.name}\" has been shipped.")
  end
end
