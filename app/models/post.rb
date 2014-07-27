class Post < ActiveRecord::Base
  def self.remove(post, snoo)
    post_time = DateTime.strptime(post['created_utc'].to_s, "%s")
    if (DateTime.current.utc.to_f - post_time.to_f) < 60
      puts 'Post is less than 60s old. skip!'
      return false
    end

    snoo.remove('t3_' + post['id'])
    sleep(1)
    comment = snoo.comment(self.generate_comment(post), 't3_' + post['id'])
    begin
      comment_id = comment['json']['data']['things'].first['data']['id']
    end
    unless comment_id.blank?
      snoo.distinguish(comment_id)
      Post.create!({
                       :post_id => 't3_'+post['id'],
                       :comment_id => comment_id
                   })
      puts "Post by #{post['author']} deleted and left a distinguished comment: "
    end
  end

  def self.generate_comment(post)
    comment = <<END
Hi #{post['author']}, your post has been removed because it wasn't flaired. Please flair your post correctly and it will be re-instated automatically. Thanks!
END
    comment
  end

  def recon
    reddit = Reddit.login
    #Approve the post
    reddit.snoo.approve(self.post_id)
    sleep(1)
    # Report the post
    reddit.snoo.report(self.post_id)
    #Delete bot's comment
    sleep(1)
    reddit.snoo.delete(self.comment_id)
    puts "Approved and reported post id: #{self.post_id} and deleted bot's comment"
    self.destroy
  end
end