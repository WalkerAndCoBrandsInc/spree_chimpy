namespace :spree_chimpy do
  namespace :merge_vars do
    desc 'sync merge vars with mail chimp'
    task :sync do
      Spree::Chimpy.sync_merge_vars
    end
  end

  namespace :orders do
    desc 'sync all orders with mail chimp'
    task complete: :environment do
      scope = Spree::Order.complete.updated_today

      puts "Exporting #{scope.count} orders"

      scope.find_in_batches do |batch|
        puts order.number
        batch.each do |order|
          begin
            Spree::Chimpy.enqueue(:order_add, order)
          rescue => exception
            puts exception
          end
        end
      end

      puts nil, 'done'
    end

    task incomplete: :environment do
      scope = Spree::Order.incomplete.updated_today

      puts "Exporting #{scope.count} orders"

      scope.find_in_batches do |batch|
        puts order.number
        batch.each do |order|
          begin
            Spree::Chimpy.enqueue(:cart_add, order)
          rescue => exception
            puts exception
          end
        end
      end

      puts nil, 'done'
    end
  end

  namespace :users do
    desc 'segment all subscribed users'
    task segment: :environment do
      if Spree::Chimpy.segment_exists?
        emails = Spree.user_class.where(subscribed: true).pluck(:email)
        puts "Segmenting all subscribed users"
        response = Spree::Chimpy.list.segment(emails)
        response["errors"].try :each do |error|
          puts "Error #{error["code"]} with email: #{error["email"]} \n msg: #{error["msg"]}"
        end
        puts "segmented #{response["success"] || 0} out of #{emails.size}"
        puts "done"
      end
    end
  end

  desc 'sync all users with mailchimp'
  task sync: :environment do
    emails = Spree.user_class.pluck(:email)
    puts "Syncing all users"
    emails.each do |email|
      response = Spree::Chimpy.list.info(email)
      print '.'

      response["errors"].try :each do |error|
        puts "Error #{error['error']["code"]} with email: #{error['email']["email"]} \n
              msg: #{error["error"]}"
      end

      case response[:status]
      when "subscribed"
        Spree.user_class.where(email: email).update_all(subscribed: true)
      when "unsubscribed"
        Spree.user_class.where(email: email).update_all(subscribed: false)
      end
    end
  end
end
