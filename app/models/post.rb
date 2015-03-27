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
Hi #{post['author']}, your post has been removed because it wasn't flaired. Please flair your post correctly and it will be re-instated automatically.

>**What is a Flair?**

>A flair basically categorizes your post in one of the pre-existing categories on /r/india. Once you make a submission, you'll notice a red button which says *Flair your post* . Click on it and choose a flair according to the submission's theme, then hit Save.

>* If you want a civil and focused discussion with NO off-topic comments, choose "[R]ediquette". We do not allow trolling and other unnecessary behaviour in [R] threads.
* If you are posting from a handheld device, append [NP] for non-political, [P] for political and [R] to the title of the post and our bot will flair it accordingly.
* **Example**: http://i.imgur.com/FKs9uVI.png

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
      subheading = page.css(source.subheading).first.try(:text) unless source.subheading.blank?
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
    text.to_s.gsub(/[^\w\d]/, '')
  end

  def self.match_tweet(post)
    # If its a twitter link, get the tweet and remove meta data from it
    tweet_id = post['url'].gsub(/^.*\/(\d+)/,'\1')
    twitter = Twitter::REST::Client.new do |config|
      config.consumer_key = Configurable.consumer_key
      config.consumer_secret = Configurable.consumer_secret
      config.access_token = Configurable.access_token
      config.access_token_secret = Configurable.access_token_secret
    end
    puts "Getting tweet ID #{tweet_id}"
    tweet = twitter.status(tweet_id)
    heading = tweet.text
    post['title'] = post['title'].gsub(/.*\son Twitter:(.*)/, '\1')
    extract_chars(heading) == extract_chars(post['title'])
  end
end