json.cache! [@competition, "categories"], expires_in: 5.minutes, race_condition_ttl: 10 do
  json.array! @competition.categories do |json, category|
    json.extract! category, :name
    json.rounds category.rounds do |json, round|
      json.extract! round, :competition_id, :category_id, :id, :name
    end
  end
end
