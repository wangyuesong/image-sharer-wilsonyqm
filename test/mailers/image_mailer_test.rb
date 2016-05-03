require 'test_helper'

class ImageMailerTest < ActionMailer::TestCase
  test 'share image with valid email' do
    image = Image.create!(title: 'share image test', url: 'http://something.com', tag_list: 'some, thing, here')
    params = {
      subject:   'shareform',
      recipient: 'qiaomu@gmail.com',
      content:   'some content'
    }
    share_form = ImagesController::ShareForm.new(params)
    email = ImageMailer.send_email(image, share_form).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal ['wilsonyqm@gmail.com'], email.from
    assert_equal ['qiaomu@gmail.com'], email.to
    assert_equal 'shareform', email.subject
    outputs = [email.text_part.body.to_s, email.text_part.body.to_s]
    outputs.each do |output|
      assert_includes output, "The content is: #{params[:content]}"
      assert_includes output, params[:recipient]
      assert_includes output, image.url
      assert_includes output, "You're welcome to check our application on: #{ Rails.application.routes.url_helpers.root_url(host: 'localhost:3000') }"
    end
  end

  test 'share image with empty subject' do
    image = Image.create!(
      title: 'share image test',
      url: 'http://something.com',
      tag_list: 'some, thing, here'
    )
    params = {
      subject: '',
      recipient: 'qiaomu@gmail.com',
      content: 'some content'
    }
    share_form = ImagesController::ShareForm.new(params)
    email = ImageMailer.send_email(image, share_form).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal 'Your friend sent you this image', email.subject
    assert_equal ['wilsonyqm@gmail.com'], email.from
    assert_equal ['qiaomu@gmail.com'], email.to
    outputs = [email.text_part.body.to_s, email.text_part.body.to_s]
    outputs.each do |output|
      assert_includes output, "The content is: #{params[:content]}"
      assert_includes output, params[:recipient]
      assert_includes output, image.url
      assert_includes output, "You're welcome to check our application on: #{ Rails.application.routes.url_helpers.root_url(host: 'localhost:3000') }"
    end
  end

  test 'share image with empty content' do
    image = Image.create!(
      title: 'share image test',
      url: 'http://something.com',
      tag_list: 'some, thing, here'
    )
    params = {
      subject: 'some subject',
      recipient: 'qiaomu@gmail.com',
      content: ''
    }
    share_form = ImagesController::ShareForm.new(params)
    email = ImageMailer.send_email(image, share_form).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
    outputs = [email.text_part.body.to_s, email.text_part.body.to_s]
    assert_equal 'some subject', email.subject
    assert_equal ['wilsonyqm@gmail.com'], email.from
    assert_equal ['qiaomu@gmail.com'], email.to
    outputs.each do |output|
      assert_not_includes output, "The content is: #{params[:content]}"
      assert_includes output, params[:recipient]
      assert_includes output, image.url
      assert_includes output, "You're welcome to check our application on: #{ Rails.application.routes.url_helpers.root_url(host: 'localhost:3000') }"
    end
  end
end
