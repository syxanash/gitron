require 'sinatra'
require 'json'
require 'base64'
require './lib/Github'

require 'pp'

# Public: github.com API key used in order to have higher rate limit
GITHUB_API_KEY = 'ENTER YOUR GITHUB API KEY HERE!!!'.freeze

COOKIE_NAME = 'ach'.freeze

set :show_exceptions, false

before do
  # variables used to set various achievements

  @achievements = Array.new

  @achievement_list = {
    zuse:  'FOUND ZUSE',
    grid:  'THE GRID',
    iso:   'ISOMORPHIC',
    tron:  'TRON LIVES',
    faith: 'FAITH IN USERS',
    mcp:   'END OF LINE',
    purge: 'PURGE',
    betrayal: 'BETRAYAL'
  }

  # if all achievements have been unlocked
  # set the last achievement

  all_achievements = true

  @achievement_list.values.each do |item|
    next if achieved?(item)
    all_achievements = false
  end

  if all_achievements && !achieved?('THE CREATOR')
    @achievements.push('THE CREATOR')
    save(@achievements)
  end
end

not_found do
  erb :not_found, :layout => :layout2
end

error do
  @error_message = env['sinatra.error'].message
  erb :error
end

get '/errors/limit' do
  erb :error_rate_limit
end

before %r{^\/errors\/(input|reponame|ragequit)} do
  unless achieved?(@achievement_list[:zuse])
    @achievements.push(@achievement_list[:zuse])
    save(@achievements)
  end
end

get '/errors/input' do
  erb :error_input
end

get '/errors/reponame' do
  erb :error_program
end

get '/errors/ragequit' do
  erb :error_rage_quit
end

before '/*' do
  unless achieved?(@achievement_list[:grid])
    @achievements.push(@achievement_list[:grid])
    save(@achievements)
  end
end

get '/' do
  if params[:first_repo] && params[:second_repo]
    first_name, first_repo = get_github(sanitize_input(params[:first_repo]))
    second_name, second_repo = get_github(sanitize_input(params[:second_repo]))

    if first_name && first_repo && second_name && second_repo
      redirect "/#{first_name}/#{first_repo}/vs/#{second_name}/#{second_repo}"
    else
      redirect '/errors/input'
    end
  else
    erb :index
  end
end

get '/:first_name/:first_repo/vs/:second_name/:second_repo/?' do
  @players = Array.new

  # parse GET parameters

  first_name, first_repo = params[:first_name], params[:first_repo]
  second_name, second_repo = params[:second_name], params[:second_repo]

  # check if user enters the same repo twice

  if first_name == second_name && first_repo == second_repo
    redirect '/errors/ragequit'
  end

  @players.push(name: first_name, repo: first_repo)
  @players.push(name: second_name, repo: second_repo)

  begin
    github = Github.new(GITHUB_API_KEY)
  rescue RateLimitError
    redirect '/errors/limit'
  end

  @players.each_with_index do |player, i|
    begin
      github.set_repository(player[:name], player[:repo])

      player[:score] = github.score
      player[:avatar], player[:disk] = github.generate_avatar

      puts "#{i + 1} PLAYER SCORE: #{player[:score]}"
      puts "AVATAR: #{player[:avatar]}"
    rescue RepoNotFoundError
      redirect '/errors/reponame'
    end
  end

  pp @players

  # compare two scores to choose the higher for winner
  # if tie then randomly choose the winner
  # the winner is identified by an index between 0 and 1
  # this index is used to access to the item in @players
  # @winner will be also used in views file fight.erb

  if @players[0][:score] > @players[1][:score]
    @winner = 0
  elsif @players[0][:score] < @players[1][:score]
    @winner = 1
  else
    @winner = Random.rand(2)
  end

  puts "Winner is: #{@players[@winner][:repo]}"

  # check if new achievements have been unlocked

  # okay, the following code block is just pure shit
  # I'll update it on next release, I swear!

  loser = (@winner + 1) % 2

  @players.each_with_index do |player, i|
    if i == @winner
      if (player[:avatar] == 'rinzler' || player[:avatar] == 'tron_uprising') &&
        !achieved?(@achievement_list[:tron])
        @achievements.push(@achievement_list[:tron])
      elsif player[:avatar] == 'clu2' &&
        (@players[loser][:avatar] == 'rinzler_converted' ||
          @players[loser][:avatar] == 'tron' ||
          @players[loser][:avatar] == 'tron_uprising') &&
        !achieved?(@achievement_list[:betrayal])
        @achievements.push(@achievement_list[:betrayal])
      end

      # checking ISO avatars (for github members repos)
      if iso_avatar?(player[:avatar]) && !achieved?(@achievement_list[:iso])
        @achievements.push(@achievement_list[:iso])
      elsif (!iso_avatar?(player[:avatar]) &&
        iso_avatar?(@players[loser][:avatar])) && !achieved?(@achievement_list[:purge])
        @achievements.push(@achievement_list[:purge])
      end
    else # check loser of the current fight
      if player[:avatar] == 'mcp.gif' && !achieved?(@achievement_list[:mcp])
        @achievements.push(@achievement_list[:mcp])
      elsif player[:avatar] == 'jarvis' && !achieved?(@achievement_list[:faith])
        @achievements.push(@achievement_list[:faith])
      end
    end
  end

  # if new achievements have been unlocked save
  # the list inside the main cookie

  if @achievements.size != 0
    save(@achievements)
  end

  # yes, I warned you it was shit...

  erb :fight
end

helpers do
  def bake(key, content, expire = 290_304_000)
    response.set_cookie(
      key,
      value: content,
      expires: Time.now + expire,
      path: '/'
    )
  end

  def save(new_list)
    # save the current unlocked achievements list
    # and update the list with new achievements

    current_list = fetch
    current_list += new_list

    # save the list inside a json array and update the cookie

    json_content = current_list.to_json
    bake(COOKIE_NAME, Base64.encode64(json_content))
  end

  def achieved?(achievement)
    list = fetch

    list.include?(achievement)
  end

  def fetch
    achievements = Array.new

    cookie = request.cookies[COOKIE_NAME]
    json_array = Base64.decode64(cookie.to_s)

    achievements = JSON.parse(json_array) if json_array != ''

    achievements
  end

  def iso_avatar?(avatar)
    isos_avatar = %w(
      ophelia giles quorra ada calchas
      young_iso_male young_iso_female old_iso_male
      iso_female_1 iso_male_1 iso_male_2
      iso_male_3 iso_female_3
    )

    iso_avatar = false

    isos_avatar.each do |iso|
      next unless iso == avatar
      iso_avatar = true
    end

    iso_avatar
  end
end

# Public: Sanitize input from a github url specified via argument.
# Kinldy provided by github.com/leereilly/github-high-scores.
#
# url - url to sanitize
#
# Returns the url sanitized
def sanitize_input(url)
  url = url.downcase

  # Special rules for Github URLs starting with 'github.com'
  if url[0..9] == 'github.com'
    url = 'https://www.github.com' + url[9..url.size]

  # Special rules for Github URLs starting with 'www.github.com'
  elsif url[0..13] == 'www.github.com'
    url = 'https://www.github.com' + url[13..url.size]
  end

  # Special rules for Github URLs ending in 'git'
  if url[-4,4] == '.git'
    url = url[0..-5]
  end

  url = url.gsub('http://', 'https://')
  url = url.gsub('git@github.com:', 'https://www.github.com/')
  url = url.gsub('git://', 'https://www.')

  # If someone just passes in user/repo e.g. leereilly/leereilly.net
  tokens = url.split('/')
  if tokens.size == 2
    url = "https://www.github.com/#{tokens[0]}/#{tokens[1]}"
  end

  url
end

def get_github(sanitized_github_url)
  user = sanitized_github_url.split('/')[3]
  repo = sanitized_github_url.split('/')[4]

  return user, repo
end
