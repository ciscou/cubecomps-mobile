class RecordsMailer < ActionMailer::Base
  def records(publisher)
    @publisher = publisher
    mail to: "francismpp@gmail.com", subject: "[Cubecomps mobile] There are new records!"
  end
end
