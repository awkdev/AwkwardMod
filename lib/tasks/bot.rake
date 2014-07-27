namespace :bot do
  desc 'Fetch all unmoderated posts and removed flaired ones'
  task remove_unflaired: :environment do
    Reddit.process
  end

  desc 'Approve all flaired posts'
  task approve_flaired: :environment do
    Reddit.reconcile
  end
end