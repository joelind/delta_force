Factory.define :foo do |foo|
  foo.sequence(:period) { |n| n.days.ago.to_date }
  foo.association(:bar)
  foo.sequence(:x) { |n| n }
  foo.sequence(:y) { |n| 10 * n }
  foo.sequence(:z) { |n| 100 * n }
end
