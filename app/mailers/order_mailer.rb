class OrderMailer < ActionMailer::Base
  default :from => "mailer@premierorders.net"
  helper :jobs
  helper :job_items

  def order_placed_email(job)
    @job = job
    mail(:to => @job.franchisee.primary_contact.user.email,
         :bcc => 'customerservice@premiergarage.com',
         :reply_to => 'customerservice@premiergarage.com',
         :subject => "Your PremierGarage order \"#{job.name}\" has been confirmed.")
  end

  def order_shipped_email(job)
    @job = job
    mail(:to => @job.franchisee.primary_contact.user.email,
         :bcc => 'customerservice@premiergarage.com',
         :reply_to => 'customerservice@premiergarage.com',
         :subject => "Your PremierGarage order \"#{job.name}\" has been shipped.")
  end
end
