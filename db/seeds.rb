sources = [
    ["Name","Domain","Heading DOM","Sub-heading DOM"],
    ["TOI","timesofindia.indiatimes.com",".arttle h1"],
    ["TOI mobile","m.timesofindia.com","h1"],
    ["TOI blog","blogs.timesofindia.indiatimes.com","h2.media-heading"],
    ["Hindustan Times","hindustantimes.com","h1"],
    ["Hindustan Times mobile","m.hindustantimes.com","h2.news_head_30"],
    ["The Hindu","thehindu.com","h1.detail-title",".articleLead h2"],
    ["The Hindu mobile","m.thehindu.com",".wx-articleDisplay-title",".articleLead"],
    ["FirstPost","firstpost.com","h1.artTitle"],
    ["FirstPost mobile","m.firstpost.com",".geo_16"],
    ["Firstpost Biz","firstbiz.firstpost.com","h1.fpbiz_storyTitle"],
    ["Economic Times","economictimes.indiatimes.com","h1.title"],
    ["Wap.Business Standard","wap.business-standard.com","#article-title h2","div.summary"],
    ["Business Standard","business-standard.com","h1",".fs14 b"],
    ["IBNLive mobile","m.ibnlive.com","h1"],
    ["IBNLive","ibnlive.in.com","h1"],
    ["Rediff","rediff.com","h1#slideTitle"],
    ["Rediff","rediff.com","h1.arti_heading"],
    ["Rediff mobile","m.rediff.com","#arti_hd"],
    ["yahoo news","in.news.yahoo.com","h1.headline","h2.subheadline"],
    ["scoopwhoop","scoopwhoop.com",".art_title"],
    ["Deccan Herald","deccanherald.com","h1"],
    ["Deccan Chronicle","deccanchronicle.com","h1#page-title"],
    ["Caravan Magazine","caravanmagazine.in","#center #squeeze .left-corner h2","#center #squeeze .left-corner .subhheading a"],
    ["Daily Bhaskar","daily.bhaskar.com","h1.article-hd"],
    ["Mid-day","mid-day.com","h1",".article_detail .hightbx"],
    ["IndiaTVNews","indiatvnews.com",".topstorytitsub h1"],
    ["The news minute","thenewsminute.com","h1"],
    ["Faking news","fakingnews.firstpost.com","h2.posttitle"],
    ["Unrealtimes","theunrealtimes.com","h1.entry_title"],
    ["DNA India","dnaindia.com","h1.pageheading"],
    ["India Today","indiatoday.intoday.in","h1",".strtitlealias"],
    ["NDTV","ndtv.com","h1"],
    ["NDTV Mobile","m.ndtv.com","h1 div"],
    ["indianexpress","indianexpress.com","h1"],
    ["Tehelka","tehelka.com","h1#story_title a","#story_intro"],
    ["TelegraphIndia","telegraphindia.com","h1#hd"],
    ["Buzzfeed","buzzfeed.com","h1#post-title","p.description"],
    ["Financial Express","financialexpress.com","h1",".leadstory .summary"],
    ["Zee News","zeenews.india.com","h1"],
    ["reuters","reuters.com","h1"],
    ["Quartz","qz.com","h1"],
    ["BBC","bbc.co.uk","h1#story-header"],
    ["ANI News","aninews.in","h1"],
    ["Huffington Post","huffingtonpost.com","h1.story-heading"]
]

sources.each do |source|
  next if source[2].blank?
  subheading = ""
  subheading = source[3] if source.length > 3
  s = Source.create!({
                         domain: source[1],
                         heading: source[2],
                         subheading: subheading
                     })
  puts "Created source for #{s.domain}"
end