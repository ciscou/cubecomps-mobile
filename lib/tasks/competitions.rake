namespace :competitions do
  task archive_old: :environment do
    Competitions.new.archive_old!
  end

  task publish_records: :environment do
    RecordsPublisher.new.run
  end
end
