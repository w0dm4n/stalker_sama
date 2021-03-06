require 'slack-ruby-client'
require 'awesome_print'
require 'json'
require 'http'
require 'final_redirect_url'
require 'nokogiri'
require 'open-uri'
require 'rubycards'
require_relative 'user_database.rb'
include RubyCards

class SlackBot
  def initialize
    Slack.configure do |config|
      config.token = ENV['SLACK_API_TOKEN']
      config.logger = Logger.new(STDOUT)
      config.logger.level = Logger::WARN
      raise 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
    end

    @ud = UserDatabase.new

    @client = Slack::RealTime::Client.new

    @client.on :message do |data|
      on_react(data)
      on_every_message(data)
      on_direct_message(data) if data.channel[0] == 'D'
      on_channel_message(data) if data.channel[0] == 'C'
    end

    @client.on :hello do
      puts "Successfully connected, welcome '#{@client.self.name}' to the '#{@client.team.name}' team at https://#{@client.team.domain}.slack.com."
    end

    @client.on :close do |_data|
      puts 'Connection closing, exiting.'
    end

    @client.on :closed do |_data|
      puts 'Connection has been disconnected.'
    end

    Thread.new { @client.start! }
  end

  def send_message(chan, text)
    @client.typing channel: chan
    @client.message channel: chan, text: text
  end

  def on_channel_message(data)
    #data:
    #"type" => "message",
    #"channel" => "D9JE10EBG",
    #"user" => "U9GUFLZ9N",
    #"text" => "yo",
    #"ts" => "1520183877.000114",
    #"source_team" => "T9B6RUSKT",
    #"team" => "T9B6RUSKT"

    return unless data.text =~ /.*cluster/i || data.text =~ /.*stalker.*/i

    puts data.text
    on_direct_message(data)
  end

  def on_react(data)
    case data.text
    when /is.*weak.*\?/
      send_message(data.channel, 'Yes !')
    when /just pex/
      react(data, :tada)
    when /mang(er|é)/i
      react(data, :pizza)
      react(data, :amerelo)
    when /cadam/
      react(data, :madac)
    when /m’attendez pas/i
      react(data, :runner)
    when /malade/i
      react(data, :mask)
    when /chaud/i
      react(data, :burn) if rand(4) == 2
    when /faille.*temporelle/i
      react(data, :octopus)
    when /lovecraft/i
      react(data, :squid)
    when /fuck/i
      react(data, :face_with_symbols_on_mouth)
    when /trop de monde/i
      react(data, :monkey)
      react(data, :sheep)
      react(data, :rabbit2)
      react(data, :rat)
      react(data, :chipmunk)
    when /zetes ou/i
      react(data, :eyes)
    when /pas moi/i
      react(data, :eyes)
    when /is faster than Usain Bolt/
      react(data, :ultra_fast_parrot)
    when /has left, his weakness has no limits/
      react(data, :shame)
    when /diseppears after/
      react(data, :nuclear_explosion) if rand(2) == 1
    when /caf[eé]/i
      react(data, :coffee)
    when /rage quit/i
      react(data, :rage)
    when /(shell|terminal|iterm|bash|zsh)/i
      react(data, :terminal)
    when /ah/i
      react(data, :ah)
    end

    #User specific reactions:
    case data.user
    when /UA3BFSJ3X/  # frmarinh
      react(data, :money_with_wings) if rand(6) == 1
    when /U9CQUF9BR/  # nboulaye
      react(data, :terminal) if rand(8) == 1
    when /U9G62CJDQ/  # bbrunell
      react(daat, :weak) if rand(8) == 1
    when /U9B593R1N/  # bal-khan
      react(data, :banana) if rand(6) == 1
    when /U9GUFLZ9N/  # alelievr
      react(data, :unity) if rand(3) == 1
    when /U9B3RJWSU/  # ocarta-l
      react(data, :dark_sunglasses) if rand(10) == 1
      react(data, :iex) if rand(10) == 1
    when /U9BPLMTAP/  # hmoussa
      react(data, :ghost) if rand(6) == 1
    when /U9B4EL3NC/  # flevesqu
      react(data, :octopus) if rand(6) == 1
      react(data, :cthulhu) if rand(6) == 1
      react(data, :tantacles) if rand(6) == 1
    when /U9BTEQF7U/  # amerelo
      react(data, :amerelo) if rand(10) == 1
      react(data, :rust) if rand(10) == 1
    when /U9JVBA32S/  # cadam
    when /U9CBJLGDT/  # vbauguen
      react(data, :patapon_animated) if rand(10) == 1
  when /UA6CRCFCZ/  # bciss
    react(data, :afro) if rand(4) == 1
    when /U9JMHP8HJ/  # dmoureu-
    when /U9JLL19KK/  # amoreilh
    when /U9N1Q4D9V/  # vdaviot
    when /U9X6WU879/  # jblondea
    when /U9VC4R1TK/  # mconnat
    when /UA1SCLD7U/  # jguyet
    end
  end

  def on_every_message(data)
  case data.text
    when /\=\=/
      send_message(data.channel, (rand(2) == 1) ? "true" : "false")
  end


  end

  def on_direct_message(data)
    return unless data.subtype.nil?

    ap data
    case data.text
    when /(\W+hi|^hi|\W+hey|^hey|^hello|\W+hello)\W+/i
      send_message(data.channel, "Hi <@#{data.user}> !")
    when /random gif/i
      random_gif(data)
    when /random commitstrip/i
      random_commitstrip(data)
    when /random commit/i
      random_commit(data)
    when /random quote/i
      random_quote(data)
    when /random card/i
      random_card(data)
    when /where.*you/i
      send_message(data.channel, 'In your back !')
    when /is.*weak.*\?/
      send_message(data.channel, 'Yes !')
    when /who.*connected/i
      react(data, :eyes)
      send_message(data.channel, @ud.get_users.map { |u| "#{u[:login42]} @ #{u[:last_seat]}" if u[:connected] }.compact.join("\n"))
    else
      q = data.text.sub(/.*(stalker[s]?|cluster[s]?)\s*[\?\.,!:]*/i, '')
      react(data, :thinking_face)
      send_message(data.channel, ask_google(q))
    end
  end

  def ask_google(query)
    return 'Nope sorry' if query.strip.empty?
    puts "query: #{query}"
    results = JSON.parse HTTP.get('https://www.googleapis.com/customsearch/v1', params: {
                                                                                          q: query,
                                                                                          key: ENV['GOOGLE_API_KEY'],
                                                                                          cx: ENV['GOOGLE_CSE_ID']
                                                                                        })
    result = results['items'].first if results['items']

    return 'Daily search limit exedeed !' if results['error'] && results['error']['code'] == 403

    result ? "#{result['title']}\n#{result['link']}" : 'Wait what ?'
  end

  def react(data, name)
    @client.web_client.reactions_add(name: name, channel: data.channel, timestamp: data.ts, as_user: true)
  end

  def random_card(data)
    hand = Hand.new
    deck = Deck.new

    deck.shuffle!
    hash = { 11 => 'jack', 12 => 'queen', 13 => 'king', 14 => 'ace' }
    hand.draw(deck, 2)
    card = hand.cards.first
    url = "https://raw.githubusercontent.com/hayeah/playing-cards-assets/master/png/#{card.to_i < 11 ? card.to_i.to_s : hash[card.to_i]}_of_#{card.suit.downcase}.png"
    card = hand.cards.last
    url2 = "https://raw.githubusercontent.com/hayeah/playing-cards-assets/master/png/#{card.to_i < 11 ? card.to_i.to_s : hash[card.to_i]}_of_#{card.suit.downcase}.png"
    send_message(data.channel, "#{url}\n#{url2}")
  end

  def random_gif(data)
    nokogiri_object = nokogiri('http://lesjoiesducode.tumblr.com/random')
    gif_url = nokogiri_object.xpath('//*/div[1]/p/img').first.values.detect { |i| i =~ /http/ }
    text = strip(nokogiri_object.xpath('//*/h1').first.children)
    send_message(data.channel, "*#{text}*\n#{gif_url}")
  end

  def random_commit(data)
    nokogiri_object = nokogiri('http://whatthecommit.com/')
    text = strip(nokogiri_object.xpath('//*/p').first)
    send_message(data.channel, "*#{text}*")
  end

  def random_quote(data)
    nokogiri_object = nokogiri('http://www.litquotes.com/Random-Quote.php')
    text = strip(nokogiri_object.xpath('//b').first)
    book = strip(nokogiri_object.xpath('//i').first)
    author = strip(nokogiri_object.xpath('//p/a').first)
    send_message(data.channel, "*#{text}*\n_#{book}_ by #{author}")
  end

  def random_commitstrip(data)
    nokogiri_object = nokogiri('http://www.commitstrip.com/fr/random')
    img_url = nokogiri_object.xpath('//div/p/img').first.values.detect { |i| i =~ /http/ }
    text = strip(nokogiri_object.xpath('//header[contains(@class, \'entry-header\')]/h1').first.children)
    send_message(data.channel, "*#{text}*\n#{img_url}")
  end

  def nokogiri(website)
    url = ''
    while url == ''
      url = (FinalRedirectUrl.final_redirect_url(website).to_s rescue '')
    end
    Nokogiri::HTML(open(url).read)
  end

  def strip(data)
    data.text.strip
  end
end
