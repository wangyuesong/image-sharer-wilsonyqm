class ImageMailer < ApplicationMailer
  def send_email(image, share_form)
    @recipient = share_form.recipient
    @subject = share_form.subject.presence || 'Your friend sent you this image'
    @url = image.url
    @content = share_form.content
    mail(to: @recipient, subject: @subject)
  end
end
