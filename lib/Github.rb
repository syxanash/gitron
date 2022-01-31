require 'octokit'

class RepoNotFoundError < StandardError; end
class RateLimitError < StandardError; end

# Public: Contains various methods for fetching info from
# Github repos.
class Github
  # Public: json file containing avatars file name.
  AVATAR_LIST = 'public/avatar_list.json'.freeze

  # array positions for avatar types
  OLD_GRID_AVATARS = 0
  NEW_GRID_AVATARS = 1
  ISOS_AVATARS = 2

  # Public: Initialize github client specifying the API key
  # via argument. API key will be used in order to
  # have higher rate limit.
  # Visit: https://developer.github.com/v3/#rate-limiting
  #
  # api_key - string of api key provided by github
  #
  # Returns nothing.
  # Raises RateLimitError if github.com API requests reaches limit.
  def initialize(api_key)
    @client = Octokit::Client.new(
      access_token: api_key,
      auto_traversal: true,
      per_page: 100
    )

    raise RateLimitError, 'rate limit exceeded!' if @client.rate_limit.remaining == 0
  end

  # Public: Set a repository to fetch public info from.
  # This is mandatory in order to use either score or generate_avatar
  #
  # owner - repo's owner
  # repo  - repository name
  #
  # Returns nothing.
  # Raises RepoNotFoundError if repository does not exist on github.com
  def set_repository(owner, repo)
    @my_repository = "#{owner}/#{repo}"

    unless @client.repository? @my_repository
      raise RepoNotFoundError, 'repository does not exist!'
    end

    # build repository information
    @repo_info = {
      size: @client.repository(@my_repository).size,
      forks: @client.repository(@my_repository).forks_count,
      stars: @client.repository(@my_repository).stargazers_count,
      date: @client.repository(@my_repository).created_at,
      branches: calc_total(@my_repository, 'branches'),
      releases: calc_total(@my_repository, 'releases'),
      contribs: calc_total(@my_repository, 'contribs')
    }
  end

# Thank you snowe wherever you are!
# https://stackoverflow.com/a/43374518
def calc_total(repo, repo_info)
  begin
    number_of_items_in_first_page = @client.send(repo_info, repo).size
    repo_sum = 0
    if number_of_items_in_first_page >= 100
        links = @client.last_response.rels

        unless links.empty?
            last_page_url = links[:last].href

            /.*page=(?<page_num>\d+)/ =~ last_page_url
            repo_sum += (page_num.to_i - 1) * 100 # we add the last page manually
            repo_sum += links[:last].get.data.size
        end
    else
        repo_sum += number_of_items_in_first_page
    end
  rescue Octokit::Forbidden
    # used in rare cases like torvalds/linux

    repo_sum = '∞'
  end

  repo_sum
end

  # Public: get branches and number of contributors for a repository
  #
  # Returns number of branches
  # Returns number of contributors
  def additional_disk_info
    raise "repository hasn't been set!" unless @my_repository

    return @repo_info[:branches], @repo_info[:contribs]
  end


  # Public: Calculate a score from public github repository
  # information.
  #
  # Returns the score calculated.
  def score
    raise "repository hasn't been set!" unless @my_repository

    issues ||= 0
    main_score ||= 0

    if @client.repository(@my_repository).has_issues?
      issues = @client.issues(@my_repository).size
    end

    # calculate score by adding repository size releases and
    # contributors. If contributors number is "infinity" then
    # use the forks number instead (thanks torvalds/linux)

    main_score = @repo_info[:size].to_i +
      @repo_info[:releases].to_i +
      (@repo_info[:contribs] == '∞' ?
        @repo_info[:forks].to_i : @repo_info[:contribs].to_i)

    if issues < main_score
      main_score -= issues
    end

    main_score
  end

  # Public: generate avatar based on public repository information.
  # Both disk and avatar name are values contained
  # in avatar_list.json file.
  #
  # Returns avatar file name.
  # Returns disk gif file name.
  def generate_avatar
    raise "repository hasn't been set!" unless @my_repository

    json_file_content = File.read(AVATAR_LIST)
    avatars = JSON.parse(json_file_content)

    # check if repo owner is github staff
    owner = @my_repository.split('/')[0]
    github_member = @client.user(owner).company == 'GitHub'

    grid ||= OLD_GRID_AVATARS

    # if github staff use ISOs avatar

    if github_member
      grid = ISOS_AVATARS
    elsif @repo_info[:date].to_s > '2010-12-29' # :D
      grid = NEW_GRID_AVATARS
    end

    avatar ||= ''
    disk_color ||= ''

    avatars.each do |score, item|
      if @repo_info[:stars] >= score.to_i
        if item.is_a?(Array)
          item[grid].each do |name, disk|
            avatar = name
            disk_color = disk
          end
        else
          item.each do |name, disk|
            avatar = name
            disk_color = disk
          end
        end

        break
      end
    end

    return avatar, disk_color
  end
end
