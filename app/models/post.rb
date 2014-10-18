class Post < ActiveRecord::Base
  def self.remove(post, snoo)
    # post_time = DateTime.strptime(post['created_utc'].to_s, "%s")
    # if (DateTime.current.utc.to_f - post_time.to_f) < 80
    #   puts 'Post is less than 80s old. skip!'
    #   return false
    # end

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

---

^(I am just a bot and cannot reply to your queries. Send a) [^*modmail*](http://www.reddit.com/message/compose?to=%2Fr%2Findia&subject=Flair+Bot) ^(if you have any doubts.)
END
    comment
  end

  def recon
    reddit = Reddit.login
    #Approve the post
    reddit.snoo.approve(self.post_id)
    sleep(1)
    # Report the post
    reddit.snoo.report(self.post_id, 'Flaired after bot-removal')
    #Delete bot's comment
    sleep(1)
    reddit.snoo.delete(self.comment_id)
    puts "Approved and reported post id: #{self.post_id} and deleted bot's comment"
    self.destroy
  end

  def self.match_title(post, page, source)
    post['title'] = post['title'].gsub(/\[NP\]/, '')
    heading = page.css(source.heading).first.try(:text)
    subheading = page.css(source.subheading).first.try(:text)
    if extract_chars(heading) == extract_chars(post['title'])
      true
    elsif !subheading.blank? && extract_chars(subheading) == extract_chars(post['title'])
      true
    elsif !subheading.blank? && extract_chars(heading+subheading) == extract_chars(post['title'])
      true
    else
      false
    end
  end

  def self.extract_chars(text)
    text.to_s.gsub(/[^\w\d\s]/, '')
  end
end