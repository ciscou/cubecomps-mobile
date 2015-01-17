class RecordsMailer < ActionMailer::Base
  def records(publisher)
    @publisher = publisher
    mail from: "noreply@cubecomps.com", to: "francismpp@gmail.com", subject: "[Cubecomps mobile] There are new records!"
  end
end
