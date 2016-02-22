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

    raise RepoNotFoundError, 'repository does not exist!' unless @client.repository? @my_repository
  end

  # Public: get branches and number of commits for a repository
  #
  # Returns number of branchesPu
  # Returns number of commits
  def additional_disk_info
    raise "repository hasn't been set!" unless @my_repository

    # get the number of branches for a repository
    branches = @client.branches(@my_repository).size

    # get the number of commits, if number is higher than 100
    # than will be returned the string 100+

    commits_number = @client.commits(@my_repository).size
    commits_string = commits_number >= 100 ? '100+' : commits_number

    return branches, commits_string
  end


  # Public: Calculate a score from public github repository
  # information.
  #
  # Returns the score calculated.
  def score
    raise "repository hasn't been set!" unless @my_repository

    issues ||= 0
    score ||= 0

    if @client.repository(@my_repository).has_issues?
      issues = @client.issues(@my_repository).size
    end

    player = {
      size: @client.repository(@my_repository).size,
      commit: @client.commits(@my_repository).size,
      forks: @client.repository(@my_repository).forks_count
    }

    # calculate score

    positive = player[:size] + player[:commit] + player[:forks]

    if issues < positive
      score = positive - issues
    end

    score
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

    stars = @client.repository(@my_repository).stargazers_count
    date = @client.repository(@my_repository).created_at

    # check if repo owner is github staff

    owner = @my_repository.split('/')[0]
    github_member = @client.organization_member?('github', owner)

    grid ||= OLD_GRID_AVATARS

    # if github staff use ISOs avatar

    if github_member
      grid = ISOS_AVATARS
    elsif date.to_s > '2010-12-29' # :D
      grid = NEW_GRID_AVATARS
    end

    avatar ||= ''
    disk_color ||= ''

    avatars.each do |score, item|
      if stars >= score.to_i
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
