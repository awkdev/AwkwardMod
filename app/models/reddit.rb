class Reddit < ActiveRecord::Base
  attr_accessor :snoo

  def self.login
    params = Reddit.first
    # If we have modhash and cookie, use it to login or create new session
    if params.try(:modhash).blank? && params.try(:cookies).blank?
      bot_options = {
          :username => Configurable.username,
          :password => Configurable.password
      }
      puts 'No cookie found. Logging in'
    else
      bot_options = {
          :modhash => params.modhash,
          :cookies => params.cookies
      }
      puts 'Logging in via cookie'
    end
    # Name of the bot using Snoo Reddit API wrapper
    awkmod = Snoo::Client.new(bot_options)
    if awkmod.cookies.nil?
      if bot_options[:cookies].nil?
        puts 'Unable to login. Pls fix'
        exit!
      else
        awkmod = Snoo::Client.new({
                                      :username => Configurable.username,
                                      :password => Configurable.password
                                  })
        puts 'cookie didnt work. Logged in again'
      end
    end
    if params.blank?
      params = Reddit.create!({:modhash => awkmod.modhash, :cookies => awkmod.cookies})
    else
      params.modhash = awkmod.modhash
      params.cookies = awkmod.cookies
      params.save!
    end
    params.snoo = awkmod
    params
  end

  def get_unmoderated_links
    posts = snoo.get_listing(subreddit: Configurable.subreddits, page: 'about/unmoderated', limit: Configurable.post_limit)['data']['children'].map{|post| post['data']}
    self.update_attribute(:last_run, DateTime.current)
    posts
  end

  def self.process
    reddit = self.login
    if (DateTime.current.to_f - reddit.last_run.to_f)/60 < 1
      puts 'Ran too recently. Exit!'
      return false
    end
    posts = reddit.get_unmoderated_links
    posts.each do |post|
      Post.remove(post, reddit.snoo) if post['link_flair_text'].blank?
    end
  end

  def self.reconcile
    return 'No Posts found' if Post.count == 0
    posts = Post.where.not(:comment_id => nil).load
    reddit = self.login
    removed_posts = reddit.snoo.get_posts_by_id(posts: posts.collect(&:post_id).join(','), limit: Configurable.post_limit )['data']['children'].map{|post| post['data']}
    removed_posts.each do |post|
      posts.select{|p| p.post_id == 't3_'+post['id']}.first.delay.recon unless post['link_flair_text'].blank?
    end
    posts.select{|p| (DateTime.current.to_f - p.created_at.to_f)/60 > 120 }.each{|p| p.destroy}
  end
end