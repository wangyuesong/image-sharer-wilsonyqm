class ImageMailer < ApplicationMailer
  def send_email(image, share_form, user=nil)
    @recipient = share_form.recipient
    @sender = user.present? ? "#{user.name} (#{user.email})" : 'somebody'
    subject = share_form.subject.presence || 'Your friend sent you this image'
    @url = image.url
    @content = share_form.content
    mail(to: @recipient, subject: subject)
  end
end
