class Tree < ActiveRecord::Base
  belongs_to :user

  has_many :branches, :dependent => :destroy
  has_many :categories, :through => :branches

  @@static_categories = ["Adds other software","Alcohol","Allows remote connect","Allows remote control","Anonymizer","Any","Art / Culture","Autostarts/Stays Resident","BitTorrent protocol","Blogs / Personal Pages","Botnets","Browser Plugin","Browser Toolbar","Bundles Software","Business / Economy","Business Applications","Child Abuse","Cloud Services","Communication Standard","Computers / Internet","Content Provider and Sharing","Critical Risk","Cryptocurrency","Download Manager","eDonkey","Education","Email","Encrypts communications","Entertainment","Facebook Business","Facebook Education","Facebook Entertainment","Facebook File Sharing","Facebook Friends & Family","Facebook Games","Facebook Lifestyle","Facebook Popular","Facebook Sports","Facebook Utilities","Facebook Widgets","Fashion","File Storage and Sharing","Financial Services","Friendster Widgets","FTP Protocol","Gambling","Games","General","Gnutella protocol","Google Plus Widgets","Google Talk protocol","Government / Military","Greeting Cards","Hacking","Hate / Racism","Health","High Bandwidth","High Risk","Illegal / Questionable","Illegal Drugs","IM Aggregator","Inactive Sites","Instant Chat","Instant Messaging","IPTV","IRC protocol","Jabber protocol","Job Search / Careers","Lifestyle","Lingerie and Swimsuit / Suggestive","LinkedIn Widgets","Linux Installer","Logs e-mail","Logs IM","Low Risk","Mac Installer","Media Sharing","Media Streams","Medium Risk","Micro blogging","Mobile Software","MySpace Entertainment","MySpace Games","MySpace Lifestyle","MySpace Popular","MySpace Sports","MySpace Utilities","MySpace Widgets","Nature / Conservation","Network Protocols","Network Utilities","News / Media","Newsgroups / Forums","Ning.com Widgets","nolog app","Non-profits & NGOs","Nudity","Opens ports","Orkut Entertainment","Orkut Games","Orkut Lifestyle","Orkut Popular","Orkut Sports","Orkut Utilities","Orkut Widgets","Oscar protocol","P2P File Sharing","Personals / Dating","Phishing","Political / Legal","Pornography","Port agility","Real Estate","Recreation","Religion","Remote Administration","Restaurants / Dining / Food","SCADA Protocols","Search Engines / Portals","Sends mail","Sex","Sex Education","Share Files","Share links","Share Music","Share photos","Share videos","Shopping","SMS Tools","Social Networking","Social Plugins","Software Downloads","Software Update","Spam","Sports","Spyware / Malicious Sites","SSL Protocol","Stealth Tactics","Streaming Media Protocols","Supports File Transfer","Supports IM","Supports Streaming","Supports video/webcam","Supports VoIP","Tasteless","Torrent Trackers","Translation","Transmits Information","Travel","Tunnels","Twitter Clients","UDP Protocol","Uncategorized","Unknown Traffic","URL Filtering","Used for Web-Based Support","Vehicles","Very Low Risk","Video Conferencing","Violence","Virtual Worlds","Voice Mail","VoIP","Weapons","Web Advertisements","Web Based Instant Messaging","Web Browser","Web Browser Acceleration","Web Conferencing","Web Content Aggregators","Web Desktop","Web Services Provider","Web Spider","Windows Messenger protocol","Yahoo Messenger protocol"]
  @@static_links = ["adobe.com","Akamaihdelivery","alibaba.c","aliexpress.c","alipay.com","amazon.co","amazon.co","amazon."," apple.com","ask.com","baidu.com","bbc.co.uk","bing.com","blogger.com","blogspot.c","bp.blogspot.c","Chinadaily.com","Clkmon.co","cnn.com","craigslist.o","dailymail.co.","dailymotion.c","ebay.com","ebay.d","espn.go.co","facebook.c","fc2.com","gmw.com","go.com","godaddy.com","google.co","google.co","hao123.com","huffingt","ifeng.co","imdbabase","imgur.com","indiatimes.c","instagram.cage sharing","kickass.ing","linkedin.c","live.c engine","mail.ru","microsoft.c and technology","msn.com","neobux.com","netflix.com","odnoklassniktworking","PayPal.com","people.com","pinterest.c","pornhub.com","qq.com","rakuten.co.j","reddit.com","sina.com.c","sohu.com","soso.co","stackoverflo","ening service","taobao.com","thepiratebaysharing","tmall.com","tumblr.com","twitter.com","vk.com","vube.com","weibo.coicroblogging","wikipedia.com","wordpress.com","wordpress.ishing platform","xhamster.com","xinhuanet.com","xnxx.com","xvideos.com","yahoo.co.","yahoo.com","yandex.ru","youku.com","youtube.com"]
  @@static_leaf_names = ["360 Safeguard","About.com","Adcash","Adobe Systems","Akamai Technologies","Alibaba Group","AliExpress","Alipay","Amazon Japan","Amazon.com","Amazon Germany","Apple Inc.","Ask.com","Baidu","BBC","Bing","Blogger","Blogspot","Blogspot","China Daily","RevenueHits","CNN","Craigslist","Daily Mail","Dailymotion","eBay","eBay Germany","ESPN.com","Facebook","FC2, Inc.","Guangming Online","Go.com","GoDaddy","Google Canada","Google Indonesia","Google India","Google Japan","Google UK","Google","Google Australia","Google Brazil","Google Hong Kong","Google Mexico","Google Turkey","Google Germany","Google Spain","Google France","Google Italy","Google Poland","Google Russia","Google User Content","Hao123","The Huffington Post","Ifeng News","Internet Movie Database","Imgur","Indiatimes","Instagram","KickassTorrents","LinkedIn","Windows Live","Mail.Ru","Microsoft","MSN","Neobux","Netflix","Odnoklassniki","PayPal","People's Daily","Pinterest","Pornhub","Tencent QQ","Rakuten","Reddit","Sina Corp","Sohu","Soso.com","Stack Overflow","t.co URL Shortening Service","Taobao","The Pirate Bay","Tmall","tumblr","Twittera","VKontakte","Vube","Sina Weibo","Wikipedia","WordPress.com","Wordpress.org","xHamster","Xinhua News","Xnxx","XVideos","Yahoo! Japan","Yahoo!","Yandex","Youku","YouTube"]

  def self.create_new(user_id, name)
    Rails.logger.info "[DEBUG INFO] ############## Tree - create_new - user_id = #{user_id}, name = #{name} ##############"
    tree = Tree.create(:user_id => user_id, :name => name)
    tree.branches.create(:tree_id => tree.id, :category_id => 1)
    return tree
  end


  def branch_category(category_id)
    Rails.logger.info "[DEBUG INFO] ############## Tree - branch_category - category_id = #{category_id} ##############"

    branch = self.branches.where(:category_id => category_id).first

    if branch.blank?
      category = Category.find(category_id)
      if category.present?
        branch = self.branch_category(category.category_id)
        if branch.present?
          branch = self.branches.create(:tree_id => self.id, :category_id => category_id, :branch_id => branch.id)
        end
      else
        Rails.logger.info "[DEBUG INFO] category '#{category_id}' dose not exists"
      end
    end

    branch
  end

  def leaf_exists(leaf_id)
    self.branches.joins(:leafs).where('leafs.id' => leaf_id).exists?
  end

  def branch_fully branch_id
    Rails.logger.info "[DEBUG INFO] ############## Tree - branch_fully - branch_id = #{branch_id} ##############"

    branch = Branch.find(branch_id)

    if branch[:tree_id] == self.id
      Rails.logger.info "[DEBUG INFO] branch '#{branch_id}' already exists on tree #{self.ids}"

      return branch
    end

    my_branch = nil

    if branch.present?
      category_id = branch.category.id
      my_branch = branch_category(category_id)
      if my_branch.present?

        branch.leafs.each do |l|
          # leaf = my_branch.leafs.create(:branch_id => my_branch.id, :link_id => l.link.id, :name => l.name)
          leaf = leaf_link(l.link, l.name)
        end

        branch.branches.each do |b|
          my_branch = branch_fully(b.id)
        end

      else
        Rails.logger.info "[DEBUG INFO] failed to branch_category - category_id = '#{category_id}'"
      end
    else
      Rails.logger.info "[DEBUG INFO] branch '#{branch_id}' dose not exists"
    end

    my_branch
  end

  def link_exists(link_id)
    self.branches.joins(leafs: :link).where('links.id' => link_id)
    # Leaf.joins(:link, branch: :tree).where("links.id = ? AND trees.id = ?", link_id, self.id)
  end

  def leaf_link(link, link_name)
    Rails.logger.info "[DEBUG INFO] ############## Tree - leaf_link - link_id = #{link.id}, link_name = '#{link_name}' ##############"

    leaf = nil

    if self.link_exists(link.id).exists?
      Rails.logger.info "[DEBUG INFO] tree already has leaf with link_id = #{link.id}"
    else
      Rails.logger.info "[DEBUG INFO] adding leaf (link_id = #{link.id})"

      branch = self.branch_category(link.category_id)

      if branch
        leaf = branch.leafs.create(:branch_id => branch.id, :link_id => link.id, :name => link_name)
      else
        Rails.logger.info "[DEBUG INFO] failed to create branch"
      end
    end

    # Rails.logger.info "[DEBUG INFO] #{leaf.as_json}"
    leaf
  end

  def self.generate_random(user_id, minDepth, maxDepth, minBranchesPerDepth, maxBranchesPerDepth, minLeafsPerBranch, maxLeafsPerBranch)

    Rails.logger.info "[DEBUG INFO] ############## Tree - generate_random ##############"

    depth = rand(minDepth..maxDepth)
    category_parent_ids = [1]
    i = 0

    tree = Tree.create_new(user_id, "Test Tree - #{rand(1..10000)}")

    for d in 1..depth
      Rails.logger.info "[DEBUG INFO] depth ==============> #{d}"
      tmp_category_parent_ids = []

      category_parent_ids.each { |category_parent_id|
        for b in 0...rand(minBranchesPerDepth..maxBranchesPerDepth)
          category = self.get_random_static_category(category_parent_id)
          Rails.logger.info "[DEBUG INFO] branch_category - category_id = #{category[:id]} - category_name = #{category[:name]} - category_parent_id = #{category[:category_id]}"
          tree.branch_category(category[:id])

          if d == depth
            for l in 0...rand(minLeafsPerBranch..maxLeafsPerBranch)
               link  = self.get_random_static_link(category[:id])

               r = rand(0..(@@static_leaf_names.length-1))
               link_name = @@static_leaf_names[r]
               # link_name = link[:url]
               Rails.logger.info "[DEBUG INFO] \tleaf_link - link_id = #{link[:id]} - link_name = #{link_name} - category_id = #{category[:id]}"
               tree.leaf_link(link, link_name)
            end
          end

          tmp_category_parent_ids << category[:id]
        end
      }

      category_parent_ids = tmp_category_parent_ids
    end

    return tree

  end


  def as_json (options = nil)
    super(
      only: [:id, :name],
      methods: [:branches]
    )
  end

  private
  def category_params
    params.require(:category).permit(:name, :category_id)
  end

  def self.get_random_static_category(category_parent_id)
    r = rand(0..(@@static_categories.length-1))
    category_name = @@static_categories[r]

    category = Category.create_if_not_exists(category_name, category_parent_id)
  end

  def self.get_random_static_link(link_category_id)
    r = rand(0..(@@static_links.length-1))
    link_url = @@static_links[r]

    link = Link.create_if_not_exists(link_url, link_category_id, nil)
  end
end
